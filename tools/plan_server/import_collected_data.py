"""Build reproducible app imports and a review report from the team's collection.

No downloads or promotion to the active RAG corpus. Synthetic, pending-rights,
infrastructure and weather records are never disguised as current advice.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path

import insights
import places

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_PACKAGE = ROOT / 'Data Collection/rag-data-preparation/rag-data-preparation'
OUTPUT = ROOT / 'tools/plan_server/collected_data'
ASSET = ROOT / 'terra_nt/assets/data/travel_insights_collected.json'


def read_rows(path):
    return [json.loads(line) for line in path.read_text(encoding='utf-8').splitlines() if line.strip()]


def keyed(rows, key):
    result = {}
    for row in rows:
        value = row[key]
        if value in result:
            raise ValueError(f'Duplicate {key}: {value}')
        result[value] = row
    return result


def supported_source(row, sources):
    refs = [sources[s] for s in row['source_ids']]
    return bool(refs) and all(s.get('access_status') == 'confirmed'
                              and 'display' in s.get('allowed_uses', [])
                              and 'storage' in s.get('allowed_uses', []) for s in refs)


def link_names(entity):
    # Exact declared locality aliases only, never nearest-point/road matching.
    names = [entity['name'], *entity.get('aliases', [])]
    if any(n.casefold() == 'darwin city' for n in names):
        names.append('Darwin')
    return list(dict.fromkeys(names))


def envelope(row, entity, source, kind, data, details):
    observed, expires = row.get('valid_from'), row.get('valid_until')
    if not observed or not expires or insights.timestamp(expires) <= insights.timestamp(observed):
        raise ValueError(f"Historical interval required: {row['record_id']}")
    return dict(id=row['record_id'], kind=kind, title=entity['name'],
                place_names=link_names(entity), details=details,
                source_url=source['url'], source_name=source['publisher'],
                observed_at=observed, expires_at=expires, data_mode='real',
                data=dict(data, historical=True, entity_id=entity['entity_id'],
                          source_ids=row['source_ids'], verification_status=row['verification_status']))


def build(package):
    sources = keyed(read_rows(package / 'sources.jsonl'), 'source_id')
    entities = keyed(read_rows(package / 'entities.jsonl'), 'entity_id')
    facts = read_rows(package / 'facts.jsonl')
    fuel = read_rows(package / 'observations/fuel_prices.jsonl')
    weather = read_rows(package / 'observations/weather.jsonl')
    coverage = json.loads((package / 'observations/coverage.geojson').read_text())['features']
    access = json.loads((package / 'observations/access_events.geojson').read_text())['features']
    offers = read_rows(package / 'observations/accommodation_offers.jsonl')
    ratings = read_rows(package / 'observations/ratings.jsonl')
    mappings = read_rows(package / 'mappings.jsonl')
    keyed(facts, 'fact_id'); keyed(fuel, 'record_id')
    records_to_check = [*entities.values(), *facts, *fuel, *weather, *offers, *ratings,
                        *(f['properties'] for f in coverage + access)]
    for row in records_to_check:
        if row.get('schema_version') != '1.0':
            raise ValueError('Unsupported schema_version')
        for source in row.get('source_ids', []):
            if source not in sources:
                raise ValueError(f'Unknown source {source}')
        if row.get('entity_id') and row['entity_id'] not in entities:
            raise ValueError(f"Unknown entity {row['entity_id']}")
    records, excluded = [], Counter()
    for row in fuel:
        entity = entities[row['entity_id']]
        if row['data_mode'] != 'real' or entity['data_mode'] != 'real':
            excluded['synthetic_fuel'] += 1; continue
        if not supported_source(row, sources) or not supported_source(entity, sources):
            excluded['fuel_rights_not_confirmed'] += 1; continue
        price = row['price_cents_per_litre']
        if type(price) not in (int, float) or not math.isfinite(price) or price <= 0 or row.get('currency') != 'AUD':
            raise ValueError('Invalid AUD fuel price')
        source = sources[row['source_ids'][0]]
        records.append(envelope(row, entity, source, 'fuel',
            dict(price_cents_per_litre=price, fuel_type=row['fuel_type']),
            f"Historical pump-price snapshot, {row['reported_at'][:10]}. "
            "Not a current price or a cheapest-stop recommendation. Stock, hours and access are unknown. "
            + source['attribution_text']))
    for entity in entities.values():
        if 'accommodation' not in entity['entity_types']:
            continue
        if entity['data_mode'] != 'real' or not supported_source(entity, sources):
            excluded['accommodation_not_cleared_for_display'] += 1; continue
        if not entity.get('valid_from') or not entity.get('valid_until'):
            excluded['accommodation_without_historical_interval'] += 1; continue
        source = sources[entity['source_ids'][0]]
        records.append(envelope(entity, entity, source, 'accommodation', {},
            'Historical 2020 provider listing. The business may have changed or closed. '
            'No guest rating, room price or availability was supplied. Confirm directly. '
            + source['attribution_text']))
    payload = dict(schema_version='1.0', records=records)
    insights.parse_dataset(json.dumps(payload, allow_nan=False))
    # Validate exports with the actual server parser, without changing active docs.
    exports, export_errors = [], []
    for path in sorted((package / 'exports/current-loader').glob('*.md')):
        try:
            exports.append(places.load_place_doc(path))
        except ValueError as error:
            export_errors.append(str(error))
    contexts = {}
    for region in ('top_end', 'red_centre', 'full_nt'):
        block, omitted = places.context_block(exports, region)
        contexts[region] = dict(characters=len(block), omitted=omitted)
    files = sorted(f for f in package.rglob('*') if f.is_file())
    report = dict(dataset_version=json.loads((package/'manifest.json').read_text())['dataset_version'],
        counts=dict(sources=len(sources), entities=len(entities), facts=len(facts), fuel=len(fuel),
                    coverage=len(coverage), weather=len(weather), access_events=len(access),
                    offers=len(offers), ratings=len(ratings), mappings=len(mappings)),
        app_records=len(records), app_kinds=dict(Counter(r['kind'] for r in records)),
        excluded=dict(excluded), verified_records=sum(r.get('verification_status') == 'verified' for r in records_to_check),
        loader_exports=len(exports), loader_errors=export_errors, regional_contexts=contexts,
        pending_sources=[s['source_id'] for s in sources.values() if s.get('access_status') != 'confirmed'],
        prompt_records_now=insights.context_block(records, ['Darwin', 'Katherine', 'Alice Springs'])[1],
        input_hashes={str(f.relative_to(package)):hashlib.sha256(f.read_bytes()).hexdigest() for f in files})
    return payload, report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, default=DEFAULT_PACKAGE)
    args = parser.parse_args()
    payload, report = build(args.package)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    text = json.dumps(payload, ensure_ascii=False, separators=(',', ':'), allow_nan=False) + '\n'
    if len(text) > 500_000:
        raise ValueError('Dataset exceeds the app import text limit; split it before publishing')
    ASSET.write_text(text, encoding='utf-8')
    (OUTPUT/'travel_insights.json').write_text(text, encoding='utf-8')
    (OUTPUT/'integration-report.json').write_text(json.dumps(report, indent=2, ensure_ascii=False)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k != 'input_hashes'},indent=2))


if __name__ == '__main__':
    main()

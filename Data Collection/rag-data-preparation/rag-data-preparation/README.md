# Terra NT smart-travel RAG data preparation package

Version 0.1.0 (pilot draft), prepared 2026-10-17 (Australia/Darwin), following `SMART-TRAVEL-RAG-TEAM-HANDOFF.md`. Schema version `1.0`. **No record is independently reviewed; nothing here is cleared for production ingestion.** No app, server or API contract was changed.

## Scope
- Stage A (source feasibility): partly done. See `gaps-and-access.md`.
- Stage B pilot corridor: **Darwin to Katherine along the Stuart Highway**, with the Kakadu Highway junction at Pine Creek, and the Nitmiluk and Leliyn side roads. Routing assumptions are not yet documented; no road geometry was collected.
- Also carried over from the earlier dataset: 12 place records, plus 11 new places and 3 roadside/Territory stops (Red Centre, Barkly, 4WD), all rebuilt as entity + fact records. These are outside the pilot corridor and are marked as such by their `region` and the corridor list above.

## Contents and counts
| Item | Count |
|---|---|
| Source registry rows (`sources.jsonl`) | 56 |
| Entities (`entities.jsonl`) | 26 |
| Facts (`facts.jsonl`) | 140 |
| Identity mappings (`mappings.jsonl`) | 0 (explicit gap) |
| Access events (`observations/access_events.geojson`) | 3 real features |
| Fuel, coverage, offers, ratings, weather observations | 0 each (explicit gaps) |
| Knowledge documents (`knowledge/`) | 26 + `_manifest.jsonl` |
| Evaluation cases (`evaluation/cases.jsonl`) | 20 (synthetic fixtures in `evaluation/fixtures/`) |
| Current-loader Markdown exports (`exports/current-loader/`) | 23 |

## Extensions beyond the handoff schema (all additive)
- `entities.jsonl`: `coordinate_basis` (`secondary_source_unverified` or `approximate_unverified`). Approximate coordinates are kept at the precision actually known (2 decimals); loader exports pad to 4 decimals only for format, which does not add accuracy.
- `sources.jsonl`: a `permissions` object (display, backend_storage, offline_redistribution, embeddings, derived_summaries, images), all `unknown` for page sources.
- `source_updated_at` may be a date-only string; none are set except where a page states one in its fact scope.

## Real versus synthetic
Real records are in the root files and `observations/`. Synthetic records exist only under `evaluation/fixtures/` and carry `data_mode: synthetic_demo` and `source_ids: ["synthetic-fixture"]`. None use a real business name.

## Timestamps
`retrieved_at` is `2026-10-17T00:00:00Z` for every record: the retrieval day is known, the time of day was not recorded. `review_due_at` is a team deadline (monthly 2026-11-17 for access, facilities, permits, prices, safety; quarterly 2027-01-17 for descriptions).

## Import instructions
- JSONL: one UTF-8 JSON object per line, LF newlines. GeoJSON files are FeatureCollections with envelope fields inside each Feature's `properties`.
- Join `facts.entity_id` to `entities.entity_id`; `source_ids` to `sources.source_id`; knowledge docs cite fact IDs in square brackets.
- Do not load `evaluation/fixtures/` into production indexes.
- `exports/current-loader/` follows only the current loader's front matter (`name`, `aliases`, `lat`, `lng`, `region`, `tags`, `authority`, `checked`, `sources`). Copy into `tools/plan_server/rag/` only after review; restart the planner server afterwards. Regions fit the 12,000-character cap only because bodies are trimmed to the highest-priority facts. Full detail is in `knowledge/`.
- `karlu-karlu-devils-marbles` and `daly-waters` sit between regions (Barkly); their loader exports use `red_centre` and `top_end` respectively. This is a placeholder choice for the product owner.

## Do not
Do not treat the package as proof a road, track, pool or business is open. Do not mix synthetic and real records. Do not merge entities by similar name.

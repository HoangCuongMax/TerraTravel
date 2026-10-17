# Validation report

Run: 2026-10-17 by the package builder script (self-check). **Independent reviewer: none assigned yet; no record is marked `verified`.**

Result: 31 passed, 0 failed.

| Check | Result | Detail |
|---|---|---|
| sources: required fields present | PASS | 56 rows |
| sources: unique IDs | PASS |  |
| sources: enums valid | PASS |  |
| entities: envelope fields present | PASS | 26 rows |
| entities: unique IDs | PASS |  |
| entities: enum values valid | PASS |  |
| entities: NT bounds (first-pass only) | PASS |  |
| entities: parent references resolve | PASS |  |
| entities/facts: source IDs resolve | PASS |  |
| facts: envelope fields present | PASS | 140 rows |
| facts: unique IDs | PASS |  |
| facts: entity references resolve | PASS |  |
| facts: value matches declared type | PASS |  |
| facts: null values carry unknown_reason | PASS |  |
| facts: numbers carry a unit | PASS |  |
| mappings: empty with explicit gap | PASS | see gaps-and-access.md |
| access_events: valid FeatureCollection, envelope in properties | PASS | 3 features |
| access_events: affected entities resolve | PASS |  |
| real/synthetic separation: no synthetic rows in real files | PASS |  |
| fixtures: all rows synthetic_demo | PASS | 21 rows |
| fixtures: fuel prices positive | PASS |  |
| fixtures: ratings within scale | PASS |  |
| evaluation: 20 minimum cases present | PASS |  |
| evaluation: arithmetic of cases 1 and 2 | PASS |  |
| knowledge: one document per entity | PASS | 26 docs |
| knowledge: manifest fact IDs resolve | PASS |  |
| knowledge: every cited fact ID exists | PASS |  |
| loader exports: 4-decimal coordinates and supported keys | PASS |  |
| loader exports: region top_end within 12,000-char cap | PASS | 12 files, 10997 chars, max file 1068 |
| loader exports: region red_centre within 12,000-char cap | PASS | 11 files, 10089 chars, max file 1088 |
| loader exports: each file under 1,500 chars | PASS |  |

## Limitations

- Checks prove structure and internal consistency only. They do not prove that facts, coordinates or rights are correct.
- NT bounds are a first-pass screen. Approximate coordinates (2 decimals) and three secondary-source coordinates are marked `coordinate_basis` and need visual review against authoritative locations.
- `source_locator` values are descriptive section names, not DOM anchors or page numbers.
- No spot-check by a second person has been done. Pilot recommendation traces (source → fact → entity → suggestion) are not yet reviewed.
- The current loader (`places.py`) was not provided, so exports were checked against the README rules only, not the real parser.


## Fuel historical load (2026-10-17)

- Source: MyFuel NT November 2024 extract, CC-BY
- Day: 2024-12-01
- Corridor fuel stations: 96 entities
- Observations: 313 historical + 2 synthetic
- Prices in cents per litre; products kept separate (no diesel/petrol mix in ranking)
- verification_status: unverified (pending independent review of entity matching)
- Live feed: still pending — not loaded

## Historical gap fill validation (2026-10-17)

- ACCC sites: NT lat/lng filter applied; Point features only; model_date 2025-01-31; CC-BY 2.5 AU
- RemoteConnect: all 188 points loaded with proximity caveat; source access_status pending
- NT Tourism accommodation 2020: 157 entities; no offer prices; CC-BY
- coverage_class for ACCC sites with LTE/NR set predicted_available at **site point only** — not corridor polygons
- Independent review still required before verified status

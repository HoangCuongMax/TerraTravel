# Data Collection integration

Updated 17 October 2026 (Australia/Darwin).

The existing Flutter app now includes an opt-in view of collected historical records. Open a generated or saved itinerary, select **Trip insights → View collected records**. This reads a bundled asset, works without a new service or API key, and replaces only the session insight dataset. **Clear data** returns to the empty state; public listing search and fictional demo preview remain available.

## What was imported

Source package: [`Data Collection/rag-data-preparation/rag-data-preparation/`](../Data%20Collection/rag-data-preparation/rag-data-preparation/README.md), dataset `0.4.0-weather`. The nested directory is intentional: it is the folder delivered by the team. Original files were preserved.

| Domain | Supplied | App integration and treatment |
|---|---:|---|
| Source registry | 62 | Joined by source ID; source access and allowed-use fields control export eligibility. These are declarations in the supplied registry, not an independent legal review. |
| Entities | 281 | Used to resolve names and declared locality aliases. Darwin City also matches Darwin. No inferred nearest-town join and no replacement of existing map coordinates. |
| Fuel observations | 315 | 313 historical real price observations exported; 2 synthetic fixtures excluded. Prices retain the 1 December 2024 observation/expiry interval. No current savings recommendation. |
| Accommodation | 157 historical provider entities | Exported as 2020 listings with source attribution. No invented review scores, bookable prices, or availability. |
| Coverage features | 629 | Counted and reference-checked; not converted into service coverage. These include 441 ACCC infrastructure sites and 188 RemoteConnect points. Infrastructure proximity is not measured signal; RemoteConnect access remains pending. |
| Weather | 19 | Counted and reference-checked, retained in the preparation package. Not loaded into the current four-kind insight contract or evergreen place knowledge. Forecasts need expiry-aware refresh; climate normals are not forecasts. |
| Structured facts | 140 | Reference-checked; retained for review. No records are independently verified. |
| Access events | 3 | Reference-checked, retained as supplied snapshots; not promoted into current road/pool status. |
| Accommodation offers / ratings / identity mappings | 0 / 0 / 0 | Explicit gaps. Existing app POI IDs remain unchanged. |
| RAG Markdown exports | 23 | Parsed with the real `places.py` loader. Not copied into the active corpus because source rights and independent review are pending. |

Four accommodation-related draft entities were excluded from the app export because their source permissions are not cleared. The generated app file contains **470 records** (313 fuel + 157 accommodation). The banner and each historical card explain their status. Matching uses exact entity/place aliases from the package, not corridor geometry; a matched listing is not a verified road detour or reachable fuel stop.

## RAG behaviour

The active place corpus at `tools/plan_server/rag/` is preserved. The collection's draft place exports parse successfully, but schema compatibility alone does not establish correct facts or reuse permission. Top End uses 10,204 characters and Red Centre 9,341 with no omitted records. Full NT reaches 11,744 characters and omits nine whole records under the current 12,000-character cap. See the integration report for filenames. A retrieval/context-budget improvement and review are needed before promoting the full collection.

Historical records have an explicit `data.historical` marker. The backend `insights.retrieve` excludes them even if someone extends their expiry date. The app also suppresses fuel-saving comparisons for historical records. Old prices cannot become today's fuel recommendation simply by editing the import interval.

The server already accepts the same runtime format through `TRAVEL_INSIGHTS_FILE`. For contract testing you can point it at `tools/plan_server/collected_data/travel_insights.json`, then restart the server using the usual instructions. **This historical dataset contributes no live prompt evidence.** It is not automatically enabled as current planning evidence.

## Files and team instructions

- [Importer](../tools/plan_server/import_collected_data.py): Python standard library plus the existing local parsers; no downloads or new dependencies.
- [App asset](../terra_nt/assets/data/travel_insights_collected.json): bundled historical dataset loaded by the new button.
- [Backend/manual import copy](../tools/plan_server/collected_data/travel_insights.json): same dataset, also fits the existing Import JSON character limit.
- [Integration report](../tools/plan_server/collected_data/integration-report.json): actual counts, excluded rows, pending sources, parser results, context omissions and SHA-256 hashes of input files.
- [Original data inventory](../Data%20Collection/DATA-INVENTORY.md): collection team's rationale and gaps. Its earlier README/validation counts are dated; use the integration report for this package's actual counts.

From the repository root, regenerate after changing the preparation package:

```sh
python3 tools/plan_server/import_collected_data.py
```

The importer fails on duplicate core IDs, missing referenced sources/entities, unsupported schema, invalid fuel prices/intervals and an export too large for the runtime contract. It does not certify every value or source claim. It exports only real historical fuel/accommodation records with sources declaring confirmed display and storage uses. It retains source IDs, entity ID, unverified status, original validity dates and attribution. It never copies synthetic evaluation fixtures into the shipped records.

Before expanding production ingestion, assign a separate reviewer, confirm source permissions, populate explicit app mappings, check coordinates and time-sensitive facts, and resolve full-NT retrieval omissions. Do not relabel historical observations as current or treat network-site points as coverage polygons. To add weather or infrastructure display, first extend the app/server data contract to represent those concepts accurately.

## Verification

The collected-data pipeline and historical isolation have regression tests in `tools/plan_server/test_collected_data.py`. Flutter tests cover asset parsing, original dates, synthetic exclusion, local loading, the historical banner, clear behaviour, and the existing insight flows. Run Flutter commands from `terra_nt/`.

```sh
# Run from tools/plan_server/
python3 -m unittest test_collected_data test_insights test_connected_start

# Run from terra_nt/
flutter test test/features/insights
flutter analyze
```

Device verification evidence and its limits are recorded below after running the updated normal app. This is an additive data integration; it does not rebuild the app as a separate product.

### Results from this integration

- Backend/import regression suite: 12 passed, including a mutant check that failed when the historical-exclusion gate was removed, then passed after restoration.
- Insight Flutter suite: 15 passed. Flutter analyzer: no issues.
- Normal `lib/main.dart` built and ran on iPhone 17 Pro, iOS 26.5, in Light appearance. Opened the saved itinerary, loaded collected records, scrolled actual fuel cards, checked dates/source/expiry, returned with Back, reopened insights, cleared the session dataset, then reloaded it. No new Flutter exceptions or overflow appeared in the run output during these checks.
- [Screenshots and step descriptions](application-walkthrough/2026-10-17/08-collected-data/README.md) added to the existing walkthrough.
- Physical-device rotation/gesture verification was not performed; simulator checks and widget tests do not replace it. No claim is made that the entire existing app suite is green.

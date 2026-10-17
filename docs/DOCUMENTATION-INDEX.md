# Terra NT — documentation index and team instructions

Updated: 17 October 2026 (Australia/Darwin).

This is the starting point for understanding, running, improving and preparing data for the existing Terra NT Flutter app. Links are relative to this file so they work in the repository on another teammate’s computer and on GitHub. Share this file with access to the repository; sending this Markdown file alone does not include the linked documents.

## Project overview and latest update

Terra NT is the existing Flutter travel planner for the Northern Territory. Its main areas are Explore, Plan AI, Saved Routes and Profile. Smart travel improvements add source-linked fuel, connectivity, accommodation and roadhouse information. The broader RAG programme includes data preparation, provenance, retrieval and evaluation; some parts remain pending.

**This is the overall project file:** use it as the central directory for app information, setup, team instructions, data, screenshots and current limitations. Detailed specifications stay in their linked owner documents.

Latest integration, 17 October 2026:

- **In the app:** open a saved/generated itinerary → Trip insights → View collected records. This loads 470 bundled historical records: 313 fuel-price observations from 1 December 2024 and 157 accommodation listings from 2020. Dates and attribution remain visible; these are not live recommendations.
- **Data/RAG review:** the supplied collection also contains 629 infrastructure/proximity points, 19 weather records, 140 facts and 3 access events. The 23 draft place exports parse with the backend loader but remain outside the active corpus pending review and source permissions. Full-NT retrieval would omit nine records under the current context cap.
- **Verification:** 15 targeted Flutter insight tests and 12 backend/import tests passed; Flutter analysis was clean. Loading, scrolling, Back, clearing and reloading were checked in the simulator. Physical-device verification remains outstanding.
- **Screenshots:** the walkthrough now contains 51 captures, including two for the collected-data integration. Each stage includes filenames, step descriptions and previews.

See [Data Collection integration](DATA-COLLECTION-INTEGRATION.md) for the detailed results and remaining work.

## 1. Read these first

1. Read [CLAUDE.md](../CLAUDE.md) for architecture, stack, data contracts and engineering rules. Read the dated exceptions near the beginning before applying an older rule later in the file. In particular, light mode is now authorised and is the launch default.
2. Read [README.md](../README.md) to understand how to run the Flutter app and supply local configuration. Flutter commands run from `terra_nt/`, not the repository root.
3. Read [Online data and connection status](ONLINE-DATA-STATUS.md) for what is actually connected, what remains incomplete and the planning-server repair.
4. Read [Trip insights implementation](TRIP-INSIGHTS-IMPLEMENTATION.md) and [Light mode](LIGHT-MODE.md) for the recent app improvements.
5. Read [Data Collection integration](DATA-COLLECTION-INTEGRATION.md) for the supplied dataset, what is now available in the app, and the remaining RAG/data-review work. Read the role-specific instructions below before starting work.
6. Open the [application screenshot walkthrough](application-walkthrough/2026-10-17/README.md) for numbered captures, step descriptions and previews of the existing app.

These documents describe different things: project rules, implemented behaviour, proposals and historical evidence. A proposed data field or feature is not proof it has been implemented. Confirm the current code and dated verification evidence when making a claim.

## 2. Main project documents

| Document | What it contains | Instructions for using it |
|---|---|---|
| [CLAUDE.md](../CLAUDE.md) | Main engineering guide: architecture, packages, layers, models, tokens, operating decisions and verification rules. | Read before modifying code or architecture. The dated operator exceptions override older conflicting clauses. Edit this source file when project instructions need changing. |
| [AGENTS.md](../AGENTS.md) | Generated copy of the project instructions for Codex. | AI coding agents read this file. Keep its content aligned with CLAUDE.md, preserving the generated header. Do not maintain a separate competing set of rules. |
| [README.md](../README.md) | Main build/run instructions, configuration, map/routing behaviour and phone demo setup. | Start here to run the app. Use the normal `lib/main.dart` entry point and the existing app shell. |
| [Task index](TASKS_INDEX.md) | Task tracking and recorded execution order. | Check before picking up work. Read the corresponding task under `tasks/`; its Execution block takes precedence over the summary table. Check code and recent evidence before assuming an older task status is current. |
| [30 September app review](../reports/reviews/2026-09-30/report.md) | Review of the running app, defects and improvement directions. | Use as the project’s established review reference alongside current behaviour and subsequent user decisions. Findings may have been fixed since the review. |
| [Historical PRD](PRD.md) | Original product specification and earlier decisions. | Use for history and context. It is not the current acceptance authority; project decision D21 makes the running app and review the reference. |

## 3. Smart suggestions and RAG documents

Start with [Data Collection integration](DATA-COLLECTION-INTEGRATION.md) for the 17 October collected dataset, app loading instructions, actual counts, import commands and remaining review gaps.

| Document | What it contains | Instructions for using it |
|---|---|---|
| [Data Collection integration](DATA-COLLECTION-INTEGRATION.md) | Actual supplied-package counts, 470-record app integration, import/regeneration instructions, RAG validation, exclusions and verification evidence. | Start here for the latest data update. Distinguish historical records, pending knowledge and live feeds. |
| [Smart travel and RAG team handoff](SMART-TRAVEL-RAG-TEAM-HANDOFF.md) | Captured product ideas; proposed data types; fuel, coverage, hotel and roadhouse data requirements; source discovery; provenance; validation; delivery structure; evaluation cases. | Primary assignment for the teammate preparing data. Start with source/access feasibility, then prepare a reviewed corridor pilot. Keep synthetic examples separate from real records. Proposed schemas do not automatically change the app or server contracts. |
| [Trip insights implementation](TRIP-INSIGHTS-IMPLEMENTATION.md) | Current insight cards, runtime JSON package, import behaviour, backend retrieval and remaining work. | Read before preparing a package that must load into the app. Follow its compact runtime format; the richer JSONL/GeoJSON preparation package is not directly importable without transformation. See Online Data Status for later online lookup additions. |
| [RAG source register](RAG-SOURCE-REGISTER.md) | Authority/source links, review procedure, freshness responsibilities and known corpus gaps. | Check the relevant authority for each fact. Treat a source link as a reference, not proof that live status was fetched. |
| [Current place knowledge-base instructions](../tools/plan_server/rag/README.md) | Existing Markdown place-record format, region/tag rules, limits and source requirements. | Follow when editing files loaded by the existing place-corpus parser. Validate supported front matter and the regional context budget before delivery. |
| [Older RAG data brief](RAG-DATA-BRIEF.md) | Earlier teammate instructions and broader destination list. | Historical supporting material. Its “two example files” description is outdated. Resolve collection/format questions using the current RAG README, source register and newer team handoff. Do not turn historical closure or price snapshots into live claims. |
| [Planner API contract](PHASE-3-CONTRACT.md) | App/server request and response schema, errors, authentication and planning behaviour. | Read before changing either side of the planning endpoint. Check current code for documented drift; coordinate any contract change across backend, app and tests. |
| [Trip insights verification](TRIP-INSIGHTS-VERIFICATION.md) | Initial test evidence, baseline failures, simulator checks and limits. | Use as dated evidence of the initial implementation. Read newer Online Data Status and Light Mode findings for later changes; initial counts are not a current full-suite guarantee. |

### Collected data and generated files

| File / folder | What it contains | Instructions |
|---|---|---|
| [Original data inventory](../Data%20Collection/DATA-INVENTORY.md) | Team explanation of sources, collection rationale and missing data. | Read alongside the integration report; some older package notes retain earlier counts. |
| [Delivered package README](../Data%20Collection/rag-data-preparation/rag-data-preparation/README.md) | Preparation formats and original delivery instructions. | Original collection preserved. Its review restrictions and dated scope notes matter; it is not proof of production readiness. |
| [Package manifest](../Data%20Collection/rag-data-preparation/rag-data-preparation/manifest.json) | Supplied dataset version and declared counts. | Compare against the generated integration report after changing inputs. |
| [Sources](../Data%20Collection/rag-data-preparation/rag-data-preparation/sources.jsonl) / [entities](../Data%20Collection/rag-data-preparation/rag-data-preparation/entities.jsonl) / [facts](../Data%20Collection/rag-data-preparation/rag-data-preparation/facts.jsonl) | Source permissions, place identities, typed assertions and provenance. | Resolve references by stable IDs; do not invent verification or permissions. |
| [Observations](../Data%20Collection/rag-data-preparation/rag-data-preparation/observations/) | Fuel, infrastructure/proximity, weather and access snapshots; empty offers/ratings files record gaps. | Retain original dates, units and uncertainty. Infrastructure points are not coverage polygons. |
| [Knowledge documents](../Data%20Collection/rag-data-preparation/rag-data-preparation/knowledge/) / [loader exports](../Data%20Collection/rag-data-preparation/rag-data-preparation/exports/current-loader/) | Rich preparation knowledge and 23 compact draft place exports. | Review before promotion; do not copy into the active RAG folder merely because parsing succeeds. |
| [Evaluation cases](../Data%20Collection/rag-data-preparation/rag-data-preparation/evaluation/cases.jsonl) / [gaps and access](../Data%20Collection/rag-data-preparation/rag-data-preparation/gaps-and-access.md) | Supplied evaluation scenarios and missing-source/access notes. | Synthetic fixtures are for evaluation; keep them separate from real app records. |
| [Importer](../tools/plan_server/import_collected_data.py) | Reproducible conversion and integration checks. | Run `python3 tools/plan_server/import_collected_data.py` from the repository root after changing inputs. Read the generated report before shipping. |
| [Bundled app dataset](../terra_nt/assets/data/travel_insights_collected.json) / [backend import copy](../tools/plan_server/collected_data/travel_insights.json) | The same 470-record historical runtime package. | Regenerate through the importer. The app button loads the bundled copy; historical rows are excluded from current planner evidence. |
| [Integration report](../tools/plan_server/collected_data/integration-report.json) | Actual counts, exclusions, pending sources, parser results, context omissions and input hashes. | Primary machine-readable evidence for this ingestion. Does not certify source claims independently. |

### Application screenshots and walkthrough

Start at the [walkthrough guide](application-walkthrough/2026-10-17/README.md), or use the [complete ZIP folder](application-walkthrough/terra-nt-walkthrough-2026-10-17.zip). The 51 screenshots are actual app captures; the guide explicitly lists uncaptured states.

| Stage | Guide and screenshots |
|---|---|
| Account access | [Sign-in, registration and reset guidance](application-walkthrough/2026-10-17/01-account/README.md) |
| Explore | [Map, selected place and search states](application-walkthrough/2026-10-17/02-explore/README.md) |
| Planning | [All 15 questions in the 4×4 flow, endpoint pickers and generation](application-walkthrough/2026-10-17/03-planning/README.md) |
| Itinerary | [Detailed activities, stop details, skip, edit and restore](application-walkthrough/2026-10-17/04-itinerary/README.md) |
| Insights | [Import, sources and fictional fuel/coverage/stay/roadhouse examples](application-walkthrough/2026-10-17/05-insights/README.md) |
| Saved routes | [Route list, actions and rename dialog](application-walkthrough/2026-10-17/06-saved-routes/README.md) |
| Profile | [Light, appearance choices and Dark](application-walkthrough/2026-10-17/07-profile/README.md) |
| Collected-data update | [Historical banner and actual fuel record](application-walkthrough/2026-10-17/08-collected-data/README.md) |

## 4. Appearance, online services and device setup

| Document | What it contains | Instructions for using it |
|---|---|---|
| [Light mode](LIGHT-MODE.md) | Light/dark palettes, Profile appearance selector, default behaviour and verification. | Light is the fresh-launch default. Profile offers Dark, Light and System. Appearance is session-only; no new persistence key was added. Keep colours centralised in `core/theme/` and preserve readability in both modes. |
| [Online data and connection status](ONLINE-DATA-STATUS.md) | Connected map/listing features, free-source links, missing feeds, connectivity checks and the later planner repair. | Read before saying a feature is live. Distinguish online map listings from live fuel prices, guest ratings, coverage predictions or room inventory. Read the later repair section as well as the earlier failed connectivity checks. |
| [Planning server README](../tools/plan_server/README.md) | Backend dependencies, model selection, authentication, geocoding, configuration, tunnel and startup instructions. | Required for whoever runs the AI planner. Keep credentials server-side and Firebase authentication enabled for a public tunnel. |
| [iOS setup](IOS-SETUP.md) | iPhone/simulator build and setup instructions. | Use for iOS-specific setup. Check the installed Flutter SDK against the project’s pinned version. |
| [Device-tour requirements](DEVICE-TOUR.md) | Real-device checks for layout, safe areas, Back and drag behaviour. | Read before changing those behaviours. A green widget test or simulator screenshot does not replace the required physical-device tour. Verify both absence of exceptions and correct behaviour. |

## 5. Instructions by role

### App developer

1. Read CLAUDE.md, README.md, Online Data Status and the relevant implementation document.
2. Inspect the existing feature code. Improve the current app: preserve its Explore, Plan AI, Saved Routes and Profile flow unless a change is explicitly requested.
3. Keep algorithms in the pure-data/helper tier, shared state in Riverpod notifiers and presentation in widgets. Use existing repository boundaries and theme tokens.
4. If the planning payload changes, coordinate with the backend developer using the API contract.
5. Run the analyzer and relevant functional/widget tests from `terra_nt/`. Record existing failures separately from new failures. Complete the required device tour for affected behaviour.
6. Update the relevant implementation/status document with what changed, what was verified and what remains incomplete.

### Teammate preparing data

1. Read Data Collection Integration, then the Smart Travel and RAG Team Handoff, source register and current knowledge-base README. Inspect the delivered package and actual integration report before collecting duplicates.
2. Establish which sources permit the intended access, storage, display and refresh. A public website is not automatically a reusable API.
3. Prepare the source registry and gap report first. Do not collect large volumes before the pilot schema is reviewed.
4. Deliver source-linked, typed records with explicit units, timestamps, unknown values and supporting evidence. Preserve entity IDs and aliases.
5. Use the richer preparation formats for the reviewed data package. Separately project it into the compact runtime JSON format when it needs to load into Trip insights.
6. Provide validation results, evaluation cases, a change log and unresolved data-access gaps. Never relabel invented/demo values as real data.

### Backend developer / person running the planner

1. Read the planning server README, API contract and Online Data Status.
2. Configure the existing server environment locally. Do not put API secrets in Markdown, the app bundle or version control.
3. Use the connected-start helper below for a local demo. Verify the endpoint requires authentication before pointing an app at it.
4. Rebuild the app whenever PLAN_API_URL changes; it is compiled into the build.
5. Test a real authenticated request from the app. A listening process or HTTP 401 probe alone does not prove generation succeeds.
6. Keep the model/data services and tunnel running for the demo. A temporary tunnel is not permanent hosting.

### Reviewer / tester

1. Read the implementation/status documents and identify which capabilities are actually implemented.
2. Check both light and dark appearance, including narrow widths, enlarged text and source/error states.
3. Test online success, unavailable services, stale records, malformed data and offline fallback. Confirm demo data stays visibly labelled.
4. For layout/navigation/gesture changes, follow DEVICE-TOUR.md and record any checks that could not be completed.
5. Record commands, outcomes, baseline failures and remaining risks. Do not state that all tests pass when only a targeted subset was run.

## 6. Run the existing app with its planner

These commands assume the dependencies described in the linked README files are already installed. Run from the repository root unless a command explicitly changes directories.

Start the authenticated planner and HTTPS demo tunnel on the configured macOS development machine:

```sh
tools/plan_server/.venv/bin/python tools/plan_server/start_connected.py
```

The helper uses the existing backend configuration, verifies authentication is required and updates PLAN_API_URL in `terra_nt/.env`. Keep that terminal running. If port 8787 is already occupied, check whether the existing planner/tunnel are the intended running pair before starting another instance.

In a second terminal, build/run the original app:

```sh
cd terra_nt
flutter run --dart-define-from-file=.env
```

On the current machine, the project’s pinned SDK is available at:

```text
/Users/maxhoang/Development/flutter-sdk-3.47.1/flutter/bin/flutter
```

Use that executable if the `flutter` on PATH is older than the required SDK. Teammates should use their own installation of the project-compatible SDK rather than copy a machine-specific path blindly.

A temporary HTTPS tunnel gets a new address when restarted. Run the helper and rebuild the app after a restart. Keep authentication enabled; do not expose a `--no-auth` server publicly.

Relevant implementation files, linked for convenience:

- [Normal Flutter entry point](../terra_nt/lib/main.dart)
- [Connected planner startup helper](../tools/plan_server/start_connected.py)
- [Planner server](../tools/plan_server/server.py)
- [App configuration example](../terra_nt/.env.example)
- [Trip insights screen](../terra_nt/lib/features/insights/trip_insights_screen.dart)
- [Public map-listing client](../terra_nt/lib/data/repositories/travel_data_client.dart)

## 7. Current capability boundaries

As recorded on 17 October 2026:

- The existing app supports light/dark/system appearance, with Light as the launch default.
- Trip insights supports the bundled 470-record historical collection, session JSON imports, explicitly fictional demos and a public OpenStreetMap place-lookup integration. The public lookup encountered service errors in live checks; its implementation and mock-tested behaviour are not proof of service availability.
- MyFuel NT, official mobile coverage and Tourism NT accommodation are linked for direct checks. Automatic live fuel-price comparisons, route coverage warnings, licensed guest ratings and live room inventory are not fully connected.
- The Gemini planning backend was repaired and verified through the original app: a seven-day Darwin-to-Katherine test generated a five-stop itinerary. Its laptop-hosted server/tunnel must remain running.
- The full production RAG system remains broader than the implemented region-filtered knowledge corpus and structured retrieval foundation. Read the handoff and implementation documents for remaining work.
- There are recorded baseline test failures and outstanding physical-device checks. Consult the latest verification evidence before release.

## 8. How to keep this index useful

When adding a feature or changing setup:

1. Update the document that owns those details rather than copying the same specification into several files.
2. Add or amend its link and instructions here.
3. Date status/evidence updates and clearly distinguish proposals from implemented behaviour.
4. Preserve history, but mark superseded instructions so a teammate does not follow them as current requirements.
5. Check relative links before sharing. Never add secret values, temporary credentials or personal account data.

For a new teammate, the minimum reading set is CLAUDE.md → README.md → ONLINE-DATA-STATUS.md → the document for their role. For data preparation and integration, continue with DATA-COLLECTION-INTEGRATION.md and SMART-TRAVEL-RAG-TEAM-HANDOFF.md. For planner operation, continue with tools/plan_server/README.md.

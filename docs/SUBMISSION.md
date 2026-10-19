# Terra NT — submission handoff

Prepared 19 October 2026, Australia/Darwin.

## Assessor entry points

1. Read the [root README](../README.md) for the app overview, toolchain, setup and demo modes.
2. Browse the [51-screen walkthrough](application-walkthrough/2026-10-17/README.md) for current screen/step evidence. The guide records uncaptured states and distinguishes fictional from historical data.
3. Open the [presentation deck](presentation-output/Terra-NT-Team-Presentation.pptx) and [speaker script](presentation-output/Terra-NT-Team-Speaker-Script.md). These are dated presentation artifacts; later integration/status documents describe subsequent changes.
4. Use the [complete documentation index](DOCUMENTATION-INDEX.md) for data, architecture, API contracts and detailed team instructions.

## What is included

- Existing Flutter application, native projects, bundled artwork/fonts, runtime data and tests.
- Python planning server, its active place corpus, local rehearsal stub and test fixtures.
- Original data preparation package, provenance, evaluation cases and generated historical runtime exports.
- Current screenshot walkthrough, design references, established September review evidence, research and task history.
- Setup instructions, configuration example, presentation files and known limitations.

No new application features or runtime behaviour were changed by this repository-cleanup task.

## Cleanup performed

- Removed the duplicate walkthrough ZIP from the tracked tree; the individual screenshots and guides already contain its contents. GitHub's repository Download ZIP provides a submission archive.
- Removed obsolete development capture batches under `reports/screens/` and `reports/shots/` from the tracked tree. Local originals remain in place and are ignored, so this cleanup is recoverable.
- Removed local Zed editor settings and the `.claude/` agent configuration/command folder from version control; retained root engineering instructions and useful development tools.
- Preserved the current 51-screen walkthrough, original design reference captures and the 30 September review because the project explicitly uses that review as a reference.
- Replaced the generated Flutter README and short root README with project-specific setup and assessment instructions.
- Updated the overall documentation index and historical image-link descriptions.
- Added ignore rules for local environment/credential files, archived captures and duplicate exports.

The tracked file payload is approximately **82 MB**, reduced from approximately **198 MB** before cleanup (file contents, excluding Git metadata).

Existing Git history is preserved. Files removed from the latest tree still exist in prior commits; this was not a history rewrite or force push. A full clone can therefore remain larger than a Download ZIP of the submission branch.

## Verification — 19 October 2026

Commands were run from the appropriate application/server directory. Flutter used the project's installed 3.47.1 / Dart 3.13.1 SDK; the supported backend run used the existing Python 3.13 virtual environment.

| Check | Result |
|---|---|
| `flutter analyze --no-pub` from `terra_nt/` | Passed: no issues |
| `flutter test --no-pub` from `terra_nt/` | 969 passed; 9 failed |
| Python 3.13 `.venv/bin/python -m unittest discover` from `tools/plan_server/` | 32 passed; 3 failed (35 total) |
| Targeted `flutter test --no-pub test/features/insights` | 15 passed |
| Targeted backend/import checks (`test_collected_data`, `test_insights`, `test_connected_start`) | 12 passed |
| Primary handoff/README/walkthrough local links | 267 checked; no missing or ignored targets |
| Python 3.9 system interpreter comparison | Unsupported for the documented backend toolchain; also produces 2 TemporaryDirectory API errors |

The failures were present when the cleanup began. Tests were not removed, skipped or weakened to make the submission appear green. These results are not a production-release sign-off.

### Flutter failures to address

| File under `terra_nt/test/` | Failing test |
|---|---|
| `core/util/util_test.dart` | route sampler clamps endpoints and samples the correct segment |
| `core/util/util_test.dart` | route sampler walks every segment during a full sweep |
| `app/crash_reporting_test.dart` | offline tile image failures are handled; other errors reach Firebase |
| `integration/explore_map_test.dart` | no essential action sits behind the system insets |
| `integration/explore_map_test.dart` | keeps local markers, controls and attribution offline |
| `features/auth/welcome_tile_warmup_test.dart` | the warm-up map is laid out, which is what loads tiles |
| `features/itinerary/result_screen_test.dart` | draws continuously and reveals numbered pins in stop order |
| `shared/map/route_reveal_test.dart` | clips within a long leg by distance rather than stop count |
| `shared/map/terra_map_test.dart` | disables and enables map interaction |

### Backend failures to address

All are in `tools/plan_server/test_server.py`:

- `GeocoderTest.test_place_documents_first_then_nominatim_cached`: expects the former `uluru.md` filename; the active document is `uluru-kata-tjuta.md`.
- `PromptTest.test_full_nt_takes_every_document_under_the_cap`: expects the former ASCII park heading; the active document uses the dual name with diacritics.
- `PromptTest.test_prompt_files_are_the_contract_verbatim`: the system prompt's later evidence/freshness instructions are not reproduced in the historical contract block.

Resolve each against the current intended behaviour before changing a test or product. The cleanup deliberately does not claim to resolve runtime, map or contract drift.

## Demo and release boundaries

- First sign-in requires Firebase access; no test password or administrative credentials are supplied in Git.
- Leaving `PLAN_API_URL` empty selects seeded planning; it does not bypass Firebase sign-in.
- Online planning needs a running backend and reachable configured URL. A temporary tunnel may fail or change address. No current connectivity guarantee is made by earlier demo evidence.
- Collected prices/provider listings are historical; other collected records remain partly staged. See [Data Collection integration](DATA-COLLECTION-INTEGRATION.md).
- Live fuel, measured route connectivity, guest ratings and room inventory remain incomplete.
- Physical-device verification and release signing/install checks remain outstanding. See [DEVICE-TOUR.md](DEVICE-TOUR.md) and [iOS setup](IOS-SETUP.md).
- Presentation slides and historical reports can describe earlier states; current capability statements belong to the README, data integration guide and online-status document.

## Before handing in

- Submit the branch containing this handoff, rather than the unrelated older `main` snapshot.
- Use the repository's GitHub Download ZIP if the assessment requires a file upload; include the whole project, not just this README.
- Supply demo-account access privately if required by the assessor; never place passwords or API keys in the submission repository.
- Confirm any course-specific filename, deadline, team declaration and submission rubric separately. No exact rubric or final deadline was supplied for this cleanup.

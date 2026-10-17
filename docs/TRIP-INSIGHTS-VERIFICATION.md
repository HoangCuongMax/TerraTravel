# Trip insights verification — 17 October 2026

Status: implementation verified with tests and an iOS simulator preview. Release acceptance remains pending the physical-device tour required by docs/DEVICE-TOUR.md and resolution of existing suite failures.

## Results

- Pinned Flutter 3.47.1 / Dart 3.13.1 analyzer: no issues.
- New insights tests: 8 passed. Calculations, invalid imports, preserving prior data, alias/carrier/demo filtering, expiry, controller disposal, all four cards at 320 logical pixels and 1.5 text scale, and no current saving claim for expired real observations.
- New Result navigation test: 1 passed; Back preserves the route.
- Python 3.13 parser/retrieval/planner integration tests: 4 passed.
- Dataset CLI: 4 valid synthetic records.
- Mutation control: reversing the fuel-saving subtraction made its test fail; source restored and tests passed afterward.
- Full Flutter suite before the last two standalone widget cases: 955 passed, 9 failed. Temporary baseline with this feature integration/new tests removed: 948 passed, the same 9 failed. Failure-name comparison matched exactly.
- Full backend suite before the last integration test: 23 passed, 3 failed. Temporary baseline without this feature: 20 passed, the same 3 failed. The fourth new backend integration test passed independently afterward.
- Normal app entry point (`lib/main.dart`) iOS simulator build: passed; produced `terra_nt/build/ios/iphonesimulator/Runner.app`.
- git diff --check: clean.

## Existing Flutter failures reproduced without the feature

- `app/crash_reporting_test.dart: offline tile image failures are handled; other errors reach Firebase`
- `core/util/util_test.dart: route sampler clamps endpoints and samples the correct segment`
- `core/util/util_test.dart: route sampler walks every segment during a full sweep`
- `features/auth/welcome_tile_warmup_test.dart: the warm-up map is laid out, which is what loads tiles`
- `features/itinerary/result_screen_test.dart: draws continuously and reveals numbered pins in stop order`
- `integration/explore_map_test.dart: keeps local markers, controls and attribution offline`
- `integration/explore_map_test.dart: no essential action sits behind the system insets`
- `shared/map/route_reveal_test.dart: clips within a long leg by distance rather than stop count`
- `shared/map/terra_map_test.dart: disables and enables map interaction`

## Existing backend failures reproduced without the feature

- GeocoderTest.test_place_documents_first_then_nominatim_cached
- PromptTest.test_full_nt_takes_every_document_under_the_cap
- PromptTest.test_prompt_files_are_the_contract_verbatim

These reflect earlier modified corpus/geocoder/prompt worktree expectations. Existing failures were not silently changed to make the new feature pass. The default Python 3.9 additionally fails on existing TemporaryDirectory arguments; use Python 3.13. The default PATH Flutter SDK is also older than the pinned project SDK.

## Simulator tour

Built and ran tool/trip_insights_preview.dart on iPhone 17 Pro / iOS 26.5. Observed empty state; explicit demo opt-in; fuel comparison changing from AUD 12.00 at 40 L to AUD 13.50 at 45 L; invalid JSON import showing an error while retaining the dataset; landscape layout with content outside the cutout. Coverage and accommodation examples appeared in the accessibility tree. Final screen copy was rebuilt and observed. No Flutter exceptions appeared in these checked flows.

Some computer-use scroll/drag commands returned noWindowsAvailable, so this is not a complete gesture tour. No physical phone is connected. Physical Back/edge gestures, keyboard-visible Back and physical safe-area acceptance remain pending. Widget navigation/disposal tests and the simulator supplement that requirement.

## Limits

No approved provider feeds are configured. Source dates/expiry are imported assertions, not independently verified facts. No road-corridor/coverage geometry calculations, verified reachable refuelling, live hotel inventory or full hybrid/vector RAG are implemented. See TRIP-INSIGHTS-IMPLEMENTATION.md for import instructions and remaining work.

# Trip insights — implementation and data import

17 October 2026. This implements a first app experience and structured retrieval foundation for `SMART-TRAVEL-RAG-TEAM-HANDOFF.md`. A public OpenStreetMap hotel/roadhouse lookup has since been added; live fuel, coverage and booking feeds are not connected. See ONLINE-DATA-STATUS.md for current behavior and connectivity findings.

## Try it

Open a generated or saved itinerary. In the Result sheet, tap **Trip insights · fuel, coverage and stays**. Tap **Preview demo** to opt into fictional examples. Demo records currently match the exact aliases Darwin, Katherine and Alice Springs; another route may have no matches. Choose a carrier and change the assumed refill amount. Scroll for all cards.

The screen shows fuel-price comparisons, coverage preparation notes, accommodation review scores and roadhouse facilities, along with source dates, validity and uncertainty. It does not advise waiting until a cheaper station or claim road-corridor matching. Price comparison excludes detour cost because routing/vehicle inputs are not wired yet. Stale real records remain labelled reference information and do not show a current saving recommendation. Synthetic examples remain usable as demos after their fixture date and are always labelled fictional.

Use **Import JSON** to paste the runtime package below. Import replaces the session dataset atomically; an invalid import retains the previous dataset and shows an error on the insights screen. Imported demo rows stay hidden until **Show fictional examples** is enabled. **Clear data** removes the package and resets preferences. Data is not persisted; no new SharedPreferences keys or packages were added. The import UI is intended for preparation/testing, not a final consumer data-management flow.

## Runtime interchange version 1.0

This compact app interchange is an additional projection of the richer preparation contract, not a replacement for its source registry, fact-level provenance or raw observations. Keep those preparation files as the source of truth. Their transformation into this format is currently manual; no general JSONL/GeoJSON compiler is implemented.

A complete example is `terra_nt/assets/data/travel_insights_demo.json`. Never relabel those synthetic observations as real.

Root: `schema_version: "1.0"`, `records: []` (maximum 500).

Every record requires:

| Key | Type | Meaning |
|---|---|---|
| `id` | nonempty string | Unique record identity |
| `kind` | enum | `fuel`, `coverage`, `accommodation`, `roadhouse` |
| `title`, `details` | nonempty string | Source-supported summary and qualifications |
| `place_names` | nonempty string array | Exact current itinerary stop names/verified aliases; not substring matching |
| `source_url` | HTTPS URL | Evidence supporting this card; no credentials in URL |
| `source_name` | nonempty string | Visible publisher/provider |
| `observed_at`, `expires_at` | ISO 8601 with timezone | Observation and explicit expiry, expiry later than observation |
| `data_mode` | enum | `real`, `synthetic_demo` |
| `data` | object | Kind-specific fields below |

Kind fields:

- Fuel: `fuel_type: string`, `price_cents_per_litre: positive number`; optional `comparison_price_cents_per_litre: positive number`. Both prices must be for equivalent fuel, purchase conditions and time, supported by the linked evidence. Explain the comparison outlet/conditions in details. AUD only in this initial UI. No vehicle compatibility or stock inference.
- Coverage: `carrier: string`, `basis: "prediction"`. Explain predicted limitations and area in details. UI supports Telstra, Optus and Vodafone selection; network-brand/reseller mapping is not implemented. This format does not import coverage geometry or calculate black-spot intersections.
- Accommodation: optional `rating: positive number`, `rating_scale_max: positive number`, `review_count: nonnegative integer` (all three required together when rating is present). Only guest review scores belong here, not official star classifications. The source name identifies the rating provider. No prices, inventory or bookings implemented.
- Roadhouse: `facilities: string[]` containing only supported facilities. Unknown facilities must not be added as available.

The app labels even real imports **Imported · unverified** because setting data_mode to real does not prove quality or usage rights. Observation/expiry values are asserted by the dataset, not independently verified. A future production ingestion gate must validate licensing, provenance and domain freshness before production recommendations. This compact schema is not sufficient by itself for that gate.

## Validate and use in the planner

From repository root:

```sh
python3.13 tools/plan_server/insights.py path/to/travel-insights.json
```

The CLI validates structure, dates, duplicate IDs, HTTPS sources, price/rating ranges and kind-specific fields. It does not contact providers, verify factual truth or approve content rights.

Optional server configuration:

```sh
export TRAVEL_INSIGHTS_FILE=/absolute/path/to/travel-insights.json
python3.13 tools/plan_server/server.py --port 8787
```

Preserve the project's existing authentication configuration; do not disable it for deployment. This optional file loads at server startup and an invalid file fails startup rather than silently supplying malformed evidence. Restart after replacing it. Server response caching retains the existing itinerary TTL; it is not a live-feed freshness mechanism.

The planner retrieves records with exact start/end location matches, excludes all synthetic records, excludes expired/future observations and orders eligible records by observation time/ID. It appends whole source-linked records within a separate 6,000-character evidence budget to the existing place corpus context. Intermediate-stop and geospatial retrieval are not implemented. Coverage evidence remains generic unless a future request supplies the carrier; the prompt tells the model not to infer it. Imported text is explicitly labelled untrusted evidence, not instructions.

No model-provider setup or key was changed. Existing `sources` fields remain the current response citation mechanism; per-fact citations in the app response require a future versioned API change. There is no automatic sync between this server file and an app import; the same package can currently be supplied to both manually.

## Scope and next engineering steps

Implemented: app navigation, read-only insight cards, session importer, demo opt-in, exact alias/carrier filters, fuel gross-saving calculation, date checks, source links, parser/CLI, bounded structured retrieval, optional planner prompt integration and functional tests.

Still required for the full production RAG system: approved source connectors; richer preparation-to-runtime projection; production provenance verification; route-corridor/coverage geometry queries; vehicle fuel/range/reserve and detour calculations; accommodation dates/party/total quotes; facility eligibility/ranking; automatic refresh/expiry and observation history; hybrid semantic/lexical knowledge retrieval; fact-level response citations; ingestion job operations; location-triggered notifications and privacy design if chosen. The current functionality does not claim these are complete.

No new repository interface, app persistence key, package, colour, motion or radius was introduced. UI uses existing theme tokens and Lucide icons. Existing unrelated working-tree changes were retained.

## Verification

Use the pinned SDK on this machine at `/Users/maxhoang/Development/flutter-sdk-3.47.1/flutter/bin/flutter`; the default PATH SDK is older and cannot compile this project's Dart 3.13 contract. Python backend tests use Python 3.13; the default python3 on this machine is 3.9.

```sh
cd terra_nt
/Users/maxhoang/Development/flutter-sdk-3.47.1/flutter/bin/flutter analyze --no-pub
/Users/maxhoang/Development/flutter-sdk-3.47.1/flutter/bin/flutter test --no-pub test/features/insights
```

From repository root:

```sh
python3.13 -m unittest discover -s tools/plan_server -p 'test_insights.py' -v
```

The isolated developer preview used for initial checks was removed on 17 October 2026 after user clarification. Run the existing app through `lib/main.dart`; open a saved or generated route to reach Trip insights. The original app shell and navigation remain the product entry point.

Final test counts and device-tour findings are recorded in `TRIP-INSIGHTS-VERIFICATION.md`.


## Collected historical data — 17 October 2026

The existing insights screen now offers **View collected records**, loading 470 historical fuel/provider records from the bundled asset. See [Data Collection integration](DATA-COLLECTION-INTEGRATION.md) for import commands, exclusions, RAG review status and freshness rules.

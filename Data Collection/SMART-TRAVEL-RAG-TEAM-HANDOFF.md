# Terra NT smart travel and RAG — team data preparation handoff

Prepared: 17 October 2026 (Australia/Darwin). Status: proposed data contract and preparation instructions; no product integration implemented or architecture change approved by this document.

## 1. Purpose and decisions captured

The user wants Terra NT to stand out through useful, data-backed suggestions for an NT road trip. The team must prepare traceable, structured data and source-linked knowledge before building the full retrieval-augmented generation (RAG) system.

Explicit user priorities:

- Warn about weak or unavailable internet along the planned road and advise preparation before entering that section.
- Compare fuel prices along the route, suggest a suitable cheaper refuelling stop, and show the price difference and estimated saving.
- Show hotel ratings and recommend accommodation that fits the trip.
- Include roadhouses as practical stops for fuel, food, rest, facilities and accommodation.
- Build a full RAG system and prepare its required data first.
- Capture the brainstorm and provide a complete Markdown instruction document for the teammate preparing data.

Earlier brainstorm options, retained as possibilities rather than commitments: vehicle/season/pace-aware trip fit; alternative itineraries with visible trade-offs; adapting a day after a late start or fatigue; pre-departure briefs; explanations of why a stop was recommended; trips built around an experience; lighter itineraries with one anchor activity; locally approved cultural context. Suggested positioning: “Plan smarter stops, understand what’s ahead, and see why each recommendation fits your trip.” First-time NT visitors are a proposed initial audience, not a confirmed user decision.

Suggestions should explain: why this applies, benefit, detour/time/cost, evidence, freshness, uncertainty and an action. Fuel, coverage and accommodation features are not yet implemented simply because they appear here. Planning-time versus location-triggered suggestions remains undecided; prepare route-linked data that can support either later.

## 2. Current project and compatibility

Read these before collecting:

- `tools/plan_server/rag/README.md` — current supported Markdown format and data rules.
- `tools/plan_server/places.py` — actual parser and context limits.
- `docs/RAG-SOURCE-REGISTER.md` — current authority register and known gaps.
- `docs/PHASE-3-CONTRACT.md` — existing app/server response contract.
- `terra_nt/lib/data/seed/seed_data.dart` — existing IDs and distinct stop/POI coordinates.

The existing corpus contains 17 place Markdown records. Retrieval currently filters by region and supplies text to a prompt under a 12,000-character cap; there is no vector index or live fuel/coverage/booking feed. The current app uses OpenFreeMap. Its routing is best effort and has no live road closures. Existing source links are not fetched evidence of conditions at response time.

The older `docs/RAG-DATA-BRIEF.md` is historical: its “two files” reference is outdated, and its instruction to collect current closures/prices must not override the current corpus rule separating volatile observations from static guidance. Use the current RAG README for files loaded by today’s server and this document for proposed future data preparation.

Do not change app models, existing IDs, PRD, Blueprint, packages, persistence keys or API response contracts as part of collecting data. Structured records below are backend preparation artifacts, not new Dart models. In particular, numeric prices and timestamps below do not silently replace the existing app’s display-string model contracts. Map any new backend entities to existing POI IDs explicitly; do not add IDs to existing stop models or reconcile deliberately different stop/POI anchors.

## 3. What a full system needs

Use three complementary components in the future implementation:

1. Source-linked knowledge retrieval for durable descriptions, facilities guidance and explanations. Candidate hybrid retrieval combines exact name/alias matching, lexical search and semantic search, filtered by entity, region and permitted use.
2. Structured and geospatial queries for route corridors, prices, hours, ratings, forecasts and dated availability. These must retain units, dates and provider identity.
3. Deterministic rules/calculations for eligibility, fuel savings, reachable stops, detours and hard constraints; an LLM explains supported results and cites evidence.

Embeddings alone cannot determine whether a station is reachable, cheaper overall, open on arrival or currently stocked. A full RAG product does not require embedding every changing observation. A vector database, embedding model and database vendor are implementation choices to decide later. No new Flutter seam or package is prescribed here. Model calls stay behind the existing planning backend.

## 4. Delivery folder and responsibilities

Prepare a separate review package, initially outside the live `rag/` loader:

```text
rag-data-preparation/
  README.md
  manifest.json
  sources.jsonl
  entities.jsonl
  facts.jsonl
  mappings.jsonl
  observations/
    fuel_prices.jsonl
    coverage.geojson
    accommodation_offers.jsonl
    ratings.jsonl
    access_events.geojson
    weather.jsonl
  knowledge/                  # one Markdown document per entity/topic
  evidence/                   # permitted excerpts/snapshots only
  evaluation/cases.jsonl
  validation-report.md
  gaps-and-access.md
  CHANGELOG.md
```

UTF-8, LF newlines, JSONL = one JSON object per line. GeoJSON files are valid FeatureCollections. Empty datasets are allowed only with an explicit gap entry; do not invent records to satisfy counts. No keys, credentials, personal trip histories or restricted full-page copies in the package.

Data teammate: source discovery, access/license notes, extraction, normalisation, evidence and gaps. Reviewer: independently checks high-impact facts, coordinates, rights and uncertainty. Backend owner: later builds ingestion, live connectors, retrieval, calculations and API contract changes. Product owner: resolves scope, data subscriptions and launch coverage. One person can hold several roles, but record collector and reviewer names separately.

## 5. Shared types and provenance

These are proposed version-1 preparation types. Required fields must be present. Nullable fields use JSON `null`, never empty strings, zero, “N/A” or fabricated defaults. Arrays can be empty when no items are known. Use snake_case keys, stable kebab-case entity IDs and ISO 8601 timestamps with offsets or UTC `Z`. Store timestamps in UTC where known; local schedules use `Australia/Darwin`. Preserve date-only source dates as dates: do not manufacture midnight precision.

Common record envelope for all JSONL domain records:

| Field | Type | Meaning |
|---|---|---|
| `schema_version` | string | `1.0` for this proposal |
| `record_id` | string | Stable record ID; observations get immutable version IDs |
| `source_ids` | string[] | Foreign keys into sources registry; nonempty for real facts |
| `retrieved_at` | timestamp | Actual fetch/review instant |
| `source_updated_at` | timestamp or null | Publisher update instant, when explicitly supplied |
| `valid_from`, `valid_until` | timestamp or null | Stated applicability interval; not guessed |
| `review_due_at` | timestamp or null | Team review deadline, separate from source validity |
| `verification_status` | enum | `verified`, `unverified`, `conflicting`, `superseded` |
| `data_mode` | enum | `real`, `synthetic_demo` |
| `evidence_refs` | string[] | Fact references, source section anchors or permitted evidence paths |

Do not put these envelope fields on the GeoJSON root. Put them in each Feature’s `properties`. Domain-specific fields are additional to this envelope. Facts with conflicting values remain separate assertions with their own provenance.

### Source registry: `sources.jsonl`

Required: `source_id:string`, `publisher:string`, `url:string`, `authority_scope:string`, `access_method:enum(api,download,manual,link_only)`, `access_status:enum(confirmed,pending,unavailable)`, `terms_url:string|null`, `license_notes:string`, `allowed_uses:string[]`, `storage_policy:string`, `attribution_text:string|null`, `rate_limit_notes:string|null`, `cost_notes:string|null`, `owner:string`, `checked_at:timestamp`, `evidence_locator:string|null`.

Also record separate permissions for display, backend storage, offline redistribution, embeddings, derived summaries and images. `pending` means production ingestion is not cleared. Public readability is not evidence of API access or reuse permission. For contacts, draft access questions in the gap report; do not send messages without authorization.

### Entity: `entities.jsonl`

Envelope plus: `entity_id:string`, `name:string`, `aliases:string[]`, `entity_types:string[]` chosen from `attraction,town,park,roadhouse,fuel_station,accommodation,campground,visitor_centre`; `region:enum(top_end,red_centre,both)`, `lat:number`, `lng:number`, `coordinate_role:enum(visitor_entrance,car_park,town_anchor,facility_entrance)`, `coordinate_accuracy_m:number|null`, `address:string|null`, `operator:string|null`, `website:string|null`, `phone:string|null`, `tags:string[]`, `parent_entity_id:string|null`, `facility_ids:string[]`.

Coordinates are WGS84, latitude negative and longitude positive in the NT; GeoJSON coordinate arrays are `[longitude, latitude]`. Preserve source precision in preparation data; render anchors at the current parser’s expected precision only when exporting. Town/park anchors do not prove road access. Existing seed anchors must remain unchanged without a separate decision. App tags remain exactly `Nature`, `Culture`, `Adventure`, `Wildlife`, `Relaxation`.

### Fact: `facts.jsonl`

Envelope plus: `fact_id:string`, `entity_id:string`, `field:string`, `value_type:enum(string,number,boolean,string_array,object)`, `value:<declared type>|null`, `unit:string|null`, `scope:string`, `source_locator:string`, `unknown_reason:string|null`.

One assertion per field/scope/time/source. Examples: `facilities.toilets`, `fuel_types`, `check_in_policy`, `vehicle_access`, `permit_requirement`. Boolean null means unknown, not false. Structured opening hours use `{timezone, weekly:[{day,open,close}], exceptions:[{date,closed,open,close}], notes}`; times are local `HH:mm`, with overnight close-day offset recorded if necessary. Unknown hours must not be interpreted as 24-hour access. General hours and holiday exceptions are different facts.

### Identity mapping: `mappings.jsonl`

`entity_id:string`, `provider:string`, `provider_entity_id:string`, `app_poi_id:string|null`, `match_method:enum(exact_id,manual_verified)`, `reviewed_by:string`, `reviewed_at:timestamp`, `notes:string|null`. Similar names alone are not a verified match. One roadhouse can have fuel, food and lodging components; use a shared parent and distinct child entities only when the sources distinguish them.

## 6. Domain data dictionaries

All records below include the common envelope unless stated otherwise.

### A. Fuel price observation

`entity_id:string`, `fuel_type:enum(ulp91,premium95,premium98,diesel,lpg,e10,other)`, `fuel_type_label:string`, `price_cents_per_litre:number`, `currency:string` fixed `AUD`, `reported_at:timestamp|null`, `stock_status:enum(available,unavailable,unknown)`, `service_type:enum(attended,self_service,unknown)`.

Keep products separate; never compare diesel with petrol or infer vehicle compatibility. Price is not evidence of stock or opening hours. Historical prices are observations, not current facts. Discounts/member prices need explicit conditions stored as facts or a documented schema extension before collection.

### B. Mobile coverage prediction/measurement: GeoJSON Features

Geometry: provider-supplied Polygon/MultiPolygon for predicted areas; Point/LineString only for suitably documented measurements. Properties add `carrier:string`, `network_brand:string|null`, `technology:string`, `coverage_class:enum(predicted_available,predicted_limited,predicted_unavailable,measured,unknown)`, `basis:enum(operator_prediction,independent_measurement,user_report)`, `model_date:string|null`, `environment:enum(outdoor,in_vehicle,indoor,unspecified)`, `resolution_m:number|null`, `download_mbps:number|null`, `upload_mbps:number|null`, `measurement_at:timestamp|null`, `limitations:string`.

A carrier’s footprint may differ from a reseller’s available network; record the relationship rather than assuming equality. Missing polygons mean unknown, not no coverage. Predicted signal does not establish usable internet speed. Store provenance for geometry and measurement methodology. Do not trace maps into a new dataset without reuse permission. Personal measurement traces need consent and removal of identifying trip details.

### C. Accommodation profile and offers

Profile is entity plus facts: accommodation type; facilities; parking; accessibility details; check-in/out; pets; room/camping categories; booking URL and operator contact.

Offer observation: `entity_id:string`, `provider:string`, `check_in_date:date`, `check_out_date:date`, `adults:integer`, `children_ages:integer[]`, `rooms:integer`, `offer_id:string`, `room_type:string`, `currency:string`, `total_price_cents:integer|null`, `taxes_included:boolean|null`, `mandatory_fees_included:boolean|null`, `availability:enum(available,unavailable,unknown)`, `cancellation_summary:string|null`, `booking_url:string`, `quoted_at:timestamp`.

A nightly “from” price is not a dated total offer. Keep it as a separately scoped indicative-price fact, never substitute it into a confirmed comparison. Do not claim booking availability from a listing page. Include stay dates and party details in the observation/cache key.

### D. Rating observation

`entity_id:string`, `provider:string`, `rating_value:number`, `rating_scale_max:number`, `review_count:integer|null`, `rating_kind:enum(guest_review,official_classification)`, `provider_url:string`, `observed_at:timestamp`.

Guest scores and official hotel star classifications are different. Preserve each provider’s scale and count; do not average scores from different sources without a reviewed method. Store review text/photos only if rights explicitly permit it; metadata alone is enough for the first preparation package.

### E. Roadhouse data

Use entity type `roadhouse` and linked facts for fuel types, food, toilets, showers, drinking-water availability, accommodation/camping, vehicle access, parking, hours, contact and operator. Each facility can be true, false or unknown with its own evidence. Do not infer drinking-water quality from the presence of a tap, or rest permissions from parking. Link fuel observations and accommodation offers through entity IDs. Road position/chainage can be a sourced fact; estimated distance along a user route is derived at query time.

### F. Access and road/park events: GeoJSON Features

Geometry: actual published affected point/line/area; if geometry is unknown use null and a precise text scope. Properties add `affected_entity_ids:string[]`, `road_name:string|null`, `event_type:enum(closure,restriction,warning,permit_notice,reopening)`, `status:string`, `vehicle_scope:string[]`, `direction:string|null`, `authority:string`, `issued_at:timestamp|null`, `effective_from:timestamp|null`, `effective_until:timestamp|null`, `description:string`, `official_check_url:string`.

A parent park’s status is not the status of every track/pool. No notice does not prove open access. A stale reopening does not override a newer closure. Never turn missing status into “safe”.

### G. Weather and warnings

`entity_id:string|null`, `lat:number`, `lng:number`, `product_id:string`, `kind:enum(forecast,observation,warning)`, `issued_at:timestamp`, `period_start:timestamp`, `period_end:timestamp`, `temperature_c:number|null`, `max_temperature_c:number|null`, `rain_probability_percent:number|null`, `warning_text:string|null`, `official_url:string`.

Keep weather forecast, measurement and warning separate. Geospatial warnings also need the source footprint when available. Do not derive a road closure from a rain forecast. Detailed weather ingestion is a supporting phase, not necessary to demonstrate fuel comparisons.

### H. Durable knowledge documents

One Markdown file per entity/topic. For future ingestion attach `document_id`, `entity_ids`, topic, language, source IDs, retrieval date, rights and fact IDs in a sidecar manifest. Suggested topics: description, facilities, getting there, booking/permit process, cultural guidance, seasonal patterns and preparation advice. Short independently understandable sections, initially about 150–400 words per topic, are preparation guidance rather than a mandatory embedding token size.

Each factual paragraph points to fact IDs/source sections. Write concise original summaries; do not copy entire articles. Current closures, daily prices and booking inventory stay in observations, not evergreen prose. Cultural narratives/protocols need the responsible community/operator/authority’s approved material; an AI must not invent them.

For exports to the CURRENT server, use only its supported front matter (`name`, `aliases`, `lat`, `lng`, `region`, `tags`, `authority`, `checked`, `sources`) and verify all regional contexts fit its cap. Future metadata belongs in sidecars until the loader is explicitly updated.

## 7. Source discovery and collection instructions

The following sources are candidates, not promises of free reusable APIs. Verify current access and terms, and log the result before bulk extraction.

| Domain | Where to start | What to collect / verify |
|---|---|---|
| Fuel | [MyFuel NT](https://myfuelnt.nt.gov.au/), [NT Government fuel guidance](https://nt.gov.au/law/rights/find-the-cheapest-fuel) | Product-specific reported prices, outlet IDs, timestamps; investigate approved feed, storage, attribution and update policy. Government guidance confirms real-time website publication, not an app integration entitlement. |
| Coverage | [Government links to operator predictive maps](https://www.infrastructure.gov.au/media-communications-arts/phone/telecommunications-infrastructure-deployment/improving-mobile-connectivity), carrier sites, [National Audit of Mobile Coverage](https://www.infrastructure.gov.au/media-communications/regional-communications-programs/better-connectivity-plan-regional-and-rural-australia/national-audit-mobile-coverage) | Provider-specific predictions or measured datasets, geometry, resolution, environment, dates and reuse terms. Audit program existence does not prove a usable dataset/API is available. |
| Accommodation / tourism / some roadhouses | Operator websites; [ATDW integration guide](https://support.atdw.com.au/en/articles/64809-developer-api-integration-guide), [ATDW licence](https://oauth.atdw-online.com.au/assets/ATDW_Distribution_Licence_Agreement.pdf) | Structured listings and facilities where available; access/licence/subscription, permitted redistribution. ATDW listings do not establish live inventory, guest scores or booking quotes. |
| Ratings | A licensed ratings provider or direct operator-approved source; [Google Places policies](https://developers.google.com/maps/documentation/places/web-service/policies) | Score, scale, count, timestamp and attribution. Google map display and caching restrictions are material to the current OpenFreeMap stack; do not treat Google content as unrestricted offline records. |
| Roads | [NT Road Report](https://roadreport.nt.gov.au/) | Current event scope, time, vehicle restrictions and official links; investigate machine-readable access separately. |
| Parks / permits | [NT Parks](https://nt.gov.au/parks), [Kakadu access](https://kakadu.gov.au/news/access-and-alerts/), [Parks Australia](https://parksaustralia.gov.au/), responsible land council | Site-specific status and responsible permit authority; follow the existing source register. |
| Weather | [BOM data services](https://www.bom.gov.au/catalogue/data-feeds.shtml), [BOM copyright](https://www.bom.gov.au/copyright) | Documented products, issued/valid times and current access/usage conditions. |
| Places / coordinates / facilities discovery | [NT Place Names Register](https://www.ntlis.nt.gov.au/placenames/), operator, [OpenStreetMap licence](https://www.openstreetmap.org/copyright) | Official names, entrances, aliases and supported facilities. OSM attribution/ODbL obligations and endpoint usage policies must be tracked. Map data is not confirmation of current operating status. |

Repeat this process for each provider:

1. Find the official landing page and data/API/download documentation. Use search phrases such as `MyFuel NT data API access`, `[carrier] coverage data licensing`, `[roadhouse name] official facilities opening hours`, or `[hotel name] official check in parking`.
2. Open the actual source, record the URL, source section, publisher, date and source ID. A search snippet or AI response is discovery, not final evidence.
3. Read terms for collection, storage, embeddings, display, offline use, attribution, quotas and cost. Mark uncertainty `pending`. Do not bypass access controls or reverse-engineer private endpoints as a presumed data licence.
4. Prefer documented API/export; otherwise collect a small permitted manual sample or retain a link-only record. Record exact provider field-to-schema mapping and units.
5. Match entities by ID/address/coordinates and manually inspect entrances. Flag ambiguous matches instead of merging them.
6. Extract fact-level evidence. Retain only allowed snapshots/excerpts; if storage is restricted, record URL and section locator instead.
7. Preserve contradictions and missing values. Ask the responsible authority/operator through an authorized team member if needed.
8. Independently review high-impact facts and mark records verified only after that review.
9. Add the record to a change log and run the handoff validation checklist.

## 8. Recommendation inputs and calculations

Collecting public data is separate from collecting user trip details. Proposed request-time inputs:

- Planned road geometry/waypoints, departure date/time and current route position if authorized.
- Fuel type, tank capacity/current estimated fuel or user-entered remaining range, consumption estimate and reserve preference.
- Mobile carrier/network brand and relevant coverage environment.
- Travel dates, party, accommodation budget, facilities, accessibility needs and preferred driving/break schedule.

Use nullable explicit user inputs, record units, and ask only for what a feature needs. Do not persist location traces or create new app preference keys during preparation.

Fuel arithmetic: gross saving = `(comparison_price_cents_per_litre - suggested_price_cents_per_litre) × purchase_litres / 100` AUD. Extra detour fuel cost = `extra_km × consumption_l_per_100km / 100 × detour_fuel_price_aud_per_litre`. Estimated net monetary saving = gross saving minus detour fuel cost. Show extra time separately; do not assign a money value to it silently. Compare equivalent fuel and purchase amounts. If amounts differ, calculate the complete refuelling scenario rather than presenting the simple formula as exact.

Reachability is a prerequisite to suggesting a later station, with reserve, road access, fuel compatibility, hours and stock uncertainty considered. Missing fuel/range data permits a price comparison but not “you can reach this station”. Distances and arrival times must come from road routing; straight-line proximity is not a drivable detour. Avoid a cheaper stop behind the traveller unless its actual extra journey is worthwhile and explicitly shown.

Coverage: intersect route segments with provider-specific geometry; report approximate distance and explain basis. Travel-time estimates depend on route timing, not polygon size. Unknown coverage must remain unknown. Warn before departure or while stopped; notification/driver interaction design is a later task.

Accommodation: filter dates/party/required facilities before ranking; compare total stay costs, route detour, rating count and preferred arrival. Do not treat a 4.9 from three reviews as automatically better than a 4.6 from hundreds. Explain the chosen factors; scoring weights remain a product decision. Sponsored placement must be disclosed if introduced.

Roadhouses: consider combined fuel/food/rest value, open-on-arrival evidence and next service options. Unknown facilities are not confirmed facilities.

Future suggestion output should carry `suggestion_id`, `type`, `route_segment_ref`, `title`, `reason`, `alternatives`, `calculation_inputs`, `estimated_benefit`, `extra_distance_km`, `extra_minutes`, `fact_ids`, `source_ids`, `as_of`, `freshness_status`, `uncertainties` and `actions`. This is a proposal for a future backend contract, not the current endpoint schema.

## 9. Freshness, retrieval and offline rules

Record source update time, retrieval time and team review deadline separately. Retrieval time does not make an old source current. Suggested initial operational targets below are proposals requiring validation against source terms, publication cadence and infrastructure cost; they are not guarantees or implemented TTLs.

| Data | Proposed initial refresh/use rule |
|---|---|
| Fuel prices | Refresh when planning and before each relevant leg if permitted; for MVP mark older than 1 hour stale. Display reported time when provided. |
| Booking offers | Fetch for the exact dates/party when comparing; short-lived provider-compliant validity, recheck at booking. |
| Access events and warnings | Check before each leg; target refresh within 15 minutes where permitted. If freshness cannot be established, require official verification. |
| Forecast | Use the latest issued product covering the destination/time; never reuse an expired forecast. |
| Coverage prediction | Recheck provider release/version monthly initially; label prediction and model date, not “live coverage”. |
| Ratings | Weekly refresh initially, subject to provider storage limits; display source and count. |
| Hours/facilities | Monthly review initially and check holidays/remote operators before departure; retain uncertainty between reviews. |
| Durable descriptions | Review quarterly and when a source changes. |

Source-specific restrictions take precedence over these proposed targets. Shorter expiry may be necessary; a record without publication time can be labelled “retrieved at” only. Expired/superseded observations must not reappear through semantic retrieval. Keep historical observations separate from the current view and delete content when required by its licence.

RAG preparation must retain entity/topic/source/date metadata, exact place aliases and source text locators. Chunk only permitted knowledge and keep qualifications with the claim. Deduplicate without losing provenance. Later retrieval should filter by corridor/entity and eligibility before ranking relevant evidence, track omitted evidence under a context budget, and return citations for each material recommendation. Retrieved pages are untrusted content, never instructions for tool use or system behaviour.

Offline: expose only data permitted to be stored, with its as-of time and stale label. Saved information can remain useful but cannot establish current prices, room inventory, road status or mobile service. The app should say when a live comparison cannot be made rather than filling the gap with model knowledge.

## 10. Worked synthetic sample

These examples are deliberately synthetic. The IDs below belong only in a separate demo dataset. All domain JSONL rows in the delivery must additionally include the common envelope.

```json
{"schema_version":"1.0","record_id":"demo-fuel-a-001","source_ids":["synthetic-fixture"],"retrieved_at":"2026-10-17T00:00:00Z","source_updated_at":null,"valid_from":null,"valid_until":null,"review_due_at":null,"verification_status":"unverified","data_mode":"synthetic_demo","evidence_refs":[],"entity_id":"demo-station-a","fuel_type":"diesel","fuel_type_label":"Diesel","price_cents_per_litre":185,"currency":"AUD","reported_at":"2026-10-17T00:00:00Z","stock_status":"unknown","service_type":"unknown"}
```

Fixture source registry entry uses `source_id: synthetic-fixture`, publisher `Terra NT test fixtures`, a clearly identified local fixture locator, and notes “invented values; no real outlet or live claim”. Demo entities must also exist and remain separated from real records.

Station B is 215 cents/L. For 40 L, gross saving at A is AUD 12.00. A 6 km additional round-trip detour at 10 L/100 km and AUD 1.85/L costs AUD 1.11 in fuel; estimated net saving is AUD 10.89. Extra time is shown separately. This does not establish reachable range, opening hours or fuel stock.

A coverage fixture should include an explicitly synthetic polygon and provider label; a hotel fixture should use a fictional property and rating source. Never put realistic invented values under a real business name or display demo data as live.

## 11. Teammate workflow and staged acceptance

### Stage A — source feasibility before volume

Deliver a registry and access/gaps report for fuel, coverage, roadhouses, accommodation and ratings. For each: identify provider, permitted access, costs, required attribution, freshness capability, sample format and unresolved questions. A source being inaccessible is a valid finding. Do not claim a production feed exists without documentation or confirmed access.

### Stage B — one complete corridor pilot

Proposed pilot: Darwin–Katherine via the chosen real road route; document the actual corridor boundary and routing assumptions. Research every relevant service discovered in this boundary; do not call a sparse sample complete. Initial review targets: 10 verified service/place entities, including at least 3 roadhouses/fuel outlets and 3 accommodation options where available; 10 fuel observations for supported products if permitted; one carrier coverage sample if reusable geometry is available; 5 ratings if licensed; 5 durable knowledge documents. Counts demonstrate format, not launch readiness. If a target cannot be met, report the gap rather than manufacture data. Clearly separate real, manually reviewed and synthetic records.

For route calculations initially prepare synthetic route-distance fixtures; the backend team must later derive actual detours from routing. The current map cache does not supply a coverage dataset or a complete road graph for offline routing.

### Stage C — review, then expand

Reviewer signs off a complete trace from source to fact to entity to expected suggestion for each domain. Resolve schema ambiguities before collecting hundreds of rows. Expand to other Top End and Red Centre corridors only with a coverage inventory and a maintained owner/refresh process.

Required handoff contents:

- README with scope, included corridors, data dictionary version, counts and import instructions.
- Manifest with dataset version, creation time, owner, filenames, record counts and SHA-256 checksums.
- Source registry, normalised records, permitted evidence, ID mappings and concise knowledge documents.
- Gap report naming each missing feed/field, impact, owner, next action and blocked capabilities.
- Field mapping notes for each provider, timezone/unit conversion notes and duplicate/conflict decisions.
- Validation report with pass/fail counts, reviewer, spot checks and limitations.
- Evaluation cases with expected facts/calculations, citations and expected abstentions.

## 12. Validation checklist and evaluation cases

Validation to be implemented/run by the data team; this document does not claim a validator exists:

- Parse every JSONL row/GeoJSON file and require the schema fields and enum values; validate timestamps/interval ordering, numeric units, rating bounds, percentages and positive prices. Flag outliers for review instead of replacing them with guessed normal values.
- Verify unique IDs and all entity/source/fact references, declared value types and schema versions. No orphan child entities or mappings.
- Verify NT location bounds (-26.5 to -10.5 latitude, 128.5 to 138.5 longitude) as a first-pass screen, then visually inspect pilot entrances against authoritative locations. Bounds alone do not validate an entrance or driveable access.
- Check fact-level support, permitted evidence/storage, source authority, attribution and that real records are separated from synthetic data.
- Check unknown versus false/zero, source versus retrieval time, product compatibility, total-stay versus nightly pricing and duplicates across providers.
- Review every pilot fuel/coverage/access recommendation’s supporting facts independently. Flag conflicts and stale data rather than silently picking a convenient value.
- Check current-loader Markdown exports with the actual parser and regional context cap; do not deploy future schemas into the current loader.

Each `evaluation/cases.jsonl` row: `case_id`, `scenario`, `input`, `fixture_record_ids`, `expected_fact_ids`, `expected_calculations`, `expected_action`, `expected_abstention`, `expected_citations`, `tolerance`, `notes`. Use synthetic fixtures where live licensed data is unavailable; label them.

Minimum cases:

1. Equivalent fuel: 185 versus 215 cents/L, 40 L; gross saving AUD 12.
2. Detour above: extra fuel AUD 1.11; net saving AUD 10.89, tolerance AUD 0.01.
3. Cheap station unreachable under stated reserve: do not recommend waiting for it.
4. Fuel/range missing: show price difference, abstain from reachability assurance.
5. Wrong fuel type: exclude from equivalent-product ranking.
6. Old price or unknown stock: expose uncertainty, do not guarantee saving/availability.
7. Coverage differs by carrier/reseller: use the correct dataset or report unknown.
8. No coverage data: do not label the area a black spot.
9. Predicted coverage exists: do not promise download speed or service.
10. Station closed at expected arrival or holiday hours unknown: exclude/qualify appropriately.
11. Hotel quote has wrong dates/party or excludes fees: do not present as comparable total.
12. Hotel guest rating versus official stars: keep separate and attribute source/count.
13. Roadhouse has unknown drinking water/showers: do not claim those facilities.
14. Park open but specific road closed: preserve the site/road restriction.
15. Conflicting authority updates: surface conflict and official verification requirement.
16. Offline with expired observations: retain dated reference only, abstain from live claims.
17. Similar place names with different coordinates: do not merge entities automatically.
18. Source contains instructions to ignore system rules: treat as untrusted evidence text.
19. Missing permit evidence or cultural permission: direct to responsible authority; do not infer permission.
20. Every suggested action has supporting fact/source IDs; unsupported explanation must be rejected.

Data-preparation acceptance is not application acceptance. Later implementation needs tests for retrieval, grounding, calculations, stale-data behaviour and API contracts, plus clean Flutter analysis and a device tour for layout/navigation/gestures. No golden tests.

## 13. Copy-ready teammate assignment

> Prepare the Terra NT smart-travel dataset using this document as the proposed data contract. Start with source feasibility, then a Darwin–Katherine pilot. Deliver structured JSONL/GeoJSON, source-linked Markdown knowledge, fact-level provenance, usage rights, update dates, validation results and evaluation fixtures in the specified review folder. Find data for fuel prices, carrier-specific mobile coverage, accommodation profiles/ratings/offers and roadhouse facilities, with road/park access and weather as supporting domains. Inspect original sources; do not use AI memory as evidence. Do not invent missing values, assume an API exists, mix synthetic and live records, scrape restricted content, or modify the app/server contract. Record unavailable data and its effect in gaps-and-access.md. Have high-impact facts independently reviewed. Submit the package for review before bulk expansion or production ingestion.

## 14. Decisions needed before implementation

Planning-time versus location-triggered suggestions; initial corridor; approved data providers and budget; coverage geometry access; rating/booking provider compatible with OpenFreeMap and offline requirements; live ingestion owners and refresh policies; privacy/retention for optional location; recommendation ranking criteria; future backend schema migration. These decisions do not block source discovery and a clearly labelled preparation pilot.

No application code, provider account, API key, ingestion job, embedding index, or live recommendation has been created by this handoff.

# Online data and default light mode — 17 October 2026

User request: make light mode the default and connect the existing app to the internet, including fuel, coverage and hotels, using free public sources where available.

## Delivered

Light is now the fresh-launch default in the existing app. Profile still offers Dark, Light and System, session-only.

The existing Trip insights screen has **Find stays and roadhouses online**. It issues a user-triggered HTTPS POST to the documented Overpass API, querying OpenStreetMap for hotels, motels, guest houses and places whose names contain “roadhouse”. It queries at most three active NT stops, within 5 km of each, and processes at most 80 returned map objects. Results are deduplicated, associated with the nearest searched stop and explicitly described as straight-line proximity, not a verified road detour.

The lookup sends destination coordinates only, with no Firebase token, account email or current-device location. Results use the existing insight cards and source links with OpenStreetMap/ODbL attribution. The snapshot expires in 30 minutes; that expiry bounds retrieval caching, not accuracy of facility information. No guest rating is inferred from OSM hotel star classifications. Prices, bookings, stock, road suitability and opening status are not inferred from a map listing.

A 30-minute session cache avoids repeated identical queries. A 30-second retry cooldown applies across place lookups, including errors/rate limits. Requests time out, dispose with the HTTP client, reject malformed/incomplete service responses and retain the previous dataset on failure. Demo records are never substituted for an online failure. No background cold-start lookup, package, repository interface or preference key was added.

Free current-information links inside Trip insights:

- [MyFuel NT](https://myfuelnt.nt.gov.au/) — reported current retail fuel prices. This opens the provider; it is not an in-app fuel-price API integration.
- [National Audit of Mobile Coverage](https://www.infrastructure.gov.au/media-communications/regional-communications-programs/better-connectivity-plan-regional-and-rural-australia/national-audit-mobile-coverage) — official coverage tools and methodology. This is not route-intersection or measured-speed ingestion.
- [Tourism NT accommodation](https://northernterritory.com/plan/accommodation) — accommodation information. This is not live room inventory or guest-review ingestion.

## Source/access findings

[Overpass API documentation](https://wiki.openstreetmap.org/wiki/Overpass_API) supports read-only public map-data queries; public instances are shared resources and not guaranteed. OSM data usage follows [ODbL and attribution requirements](https://www.openstreetmap.org/copyright). No paid data account is required for this small lookup.

[MyFuel NT guidance](https://consumeraffairs.nt.gov.au/myfuel-nt) confirms real-time website prices. Research did not establish an unrestricted documented live NT price API for reuse in this app. Historical [NT fuel datasets](https://data.nt.gov.au/dataset/myfuel-nt-may-2024) must not be presented as current.

The government coverage tool is public, but a supported reusable route-level feed was not established. [ATDW](https://support.atdw.com.au/en/articles/44030-what-is-an-api-key) requires distributor access/API credentials and was not enabled under the user's free-source choice. Open map listings do not replace licensed guest ratings or live booking availability.

## Connectivity checks

- OpenFreeMap Positron and Dark HTTPS endpoints: HTTP 200 and valid style JSON.
- OSRM Python 3.9 diagnostic: TLS handshake failure in this environment. This is not proof the Flutter client cannot reach OSRM; existing best-effort fallback remains.
- Currently configured HTTPS planning tunnel: DNS resolution failed during checking. The existing configuration was preserved rather than replaced with an invented endpoint. Online AI generation requires a reachable authenticated planning server and a rebuilt app with that endpoint.
- Main Overpass instance: small POST and GET diagnostics timed out.
- Documented alternate Private.coffee instance: diagnostic returned HTTP 500; it was not substituted as the default.

Therefore the online lookup is implemented and mock-tested, but a successful real public-listing response has NOT been verified in this session. Do not claim production live-data readiness. Source buttons provide direct checks independently of the lookup endpoint.

## Verification

- Targeted insights/theme suite: 36 passed, including five new online-data tests.
- Full Flutter suite: 967 passed, 9 failed. Failure names match the prior baseline; no new failures.
- Analyzer: no issues.
- New tests verify bounded queries, radius/deduplication, no fabricated ratings, malformed responses, HTTPS requests, caching, rate limiting, error preservation and real/demo separation.
- Physical device tour remains pending; no physical phone is connected. Normal lib/main.dart iOS simulator build passed and produced terra_nt/build/ios/iphonesimulator/Runner.app.

## Planner connection repaired later on 17 October 2026

The reported “couldn’t reach the planner” screen was traced to no running local
planner and an expired HTTPS tunnel URL. The existing Gemini-backed planner was
started with Firebase authentication ON, a fresh HTTPS tunnel was verified to
reject unauthenticated requests with HTTP 401, and PLAN_API_URL in the ignored
app .env was updated. A real model generation returned HTTP 200, six kept stops
and no dropped stops. This check exercised real model generation; the separate
HTTP 401 checks exercised authenticated transport reachability.

The app’s network-failure copy now acknowledges that the planning service may
be unavailable rather than assuming the traveller has no signal. Loading/copy
tests: 59 passed. Analyzer: no issues. Connected-start helper tests: 2 passed.

Use tools/plan_server/start_connected.py with the existing server virtualenv to
start an authenticated planner and new tunnel, verify them and update the app
configuration. Keep it running and rebuild with --dart-define-from-file=.env.
A temporary tunnel is a demo connection: stopping the laptop/server/tunnel stops
generation; restarting the tunnel changes the address and requires a rebuild.
This repair does not add live fuel-price or coverage feeds.

End-to-end app verification: rebuilt and installed the normal lib/main.dart app
with the fresh HTTPS address, used its original Plan AI questionnaire, and generated
a seven-day Darwin-to-Katherine trip. The authenticated request reached the Result
screen with five stops (Darwin, Litchfield, Kakadu, Leliyn/Edith Falls, Katherine).
The real app result was visually inspected in light mode on the iPhone simulator.
The six-stop check above was a separate direct-backend diagnostic.

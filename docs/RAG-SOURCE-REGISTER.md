# Terra NT RAG research and source register

**Reviewed:** 8 October 2026  
**Purpose:** Record authoritative sources and refresh rules used by the place knowledge base in `tools/plan_server/rag/`.

## Research scope

The place corpus is complete for the current seeded app destinations: the A2 Darwin–Kakadu–Katherine corridor, the Flutter Top End itinerary and POIs, and the Flutter Red Centre itinerary and POIs. It currently contains 17 place records. The older [`RAG-DATA-BRIEF.md`](RAG-DATA-BRIEF.md) proposes roughly 40 destinations and sub-sites; that broader list is not yet represented one-record-per-site. This corpus is a complete set for the current app seeds, not a comprehensive gazetteer for every NT community or attraction.

Research prioritises official agencies and the site operator for access and visitor information. Stable destination descriptions are recorded in place files. Volatile status is represented by a link to the authority's live page, not a copied status value.

## Authority and live-check register

| Information | Primary source | How the planner should use it |
|---|---|---|
| NT government road closures and road condition | [NT Road Report](https://roadreport.nt.gov.au/) and [NT guidance on checking road conditions and permits](https://nt.gov.au/driving/safety/check-road-conditions) | Direct the traveller to check before departure. The place corpus does not contain current road status. On Aboriginal land, identify that permit rules may apply and link the relevant land council. |
| NT park/site access and closures | [NT parks and reserves](https://nt.gov.au/parks), including the [Darwin](https://nt.gov.au/parks/regions/darwin), [Katherine](https://nt.gov.au/parks/regions/katherine), [Tennant Creek and Barkly](https://nt.gov.au/parks/regions/tennant-creek), and [Alice Springs](https://nt.gov.au/parks/regions/alice-springs) regional pages | Check the specific park and site. A parent park can be open while a track, pool, road or campground is closed. Do not copy a current status into the static RAG files. |
| Kakadu roads, sites and seasonal closures | [Kakadu Access Report](https://kakadu.gov.au/news/access-and-alerts/) | Check per road and visitor site; it is updated with current access details. A park pass does not imply access to every site. |
| NT park pass, camping and walking bookings | [NT Parks Visitor Pass](https://nt.gov.au/parks/visitor-pass), [NT parks booking system](https://nt.gov.au/parks/camping/how-to-use-parks-booking-system), [NT campgrounds](https://nt.gov.au/parks/camping/campgrounds) | State that a visitor pass or booking may be required, and direct the traveller to verify current eligibility, fees and availability. Do not hard-code current prices. Kakadu and Uluṟu-Kata Tjuṯa use separate Parks Australia passes. |
| Kakadu pass and special permits | [Kakadu park passes](https://kakadu.gov.au/plan/passes/) and [Parks Australia permit information](https://kakadu.gov.au/plan/permits/) | Check current pass terms and whether the requested activity requires an additional permit. Refer permit decisions to Parks Australia. |
| Uluṟu-Kata Tjuṯa pass, cultural/site notices and visitor information | [Parks Australia Uluṟu-Kata Tjuṯa](https://parksaustralia.gov.au/uluru/), [Parks Australia passes](https://parksaustralia.gov.au/about/buy-park-pass/), and [park news and access notices](https://parksaustralia.gov.au/news/) | Use dual place names, never recommend climbing Uluṟu, respect no-photography signs, and check current walks, closures, pass and cultural guidance. |
| Aboriginal land entry permits | [NT Government permit guidance](https://nt.gov.au/property/land/aboriginal-land-management/aboriginal-land-and-permits/land-permits) and [Northern Land Council permits](https://www.nlc.org.au/permits) | Do not infer permission from a route line or nearby destination. Refer travellers to the land council that has authority for the land/activity in question. The NLC is not the permit authority for every Aboriginal land in the NT. |
| Park swimming and water safety | [NT Government swimming in parks](https://nt.gov.au/parks/safety-rules/swimming-in-parks) and the relevant live park page; for Kakadu use its [Access Report](https://kakadu.gov.au/news/access-and-alerts/) | Only describe a swim as available if the current authority page and on-site signage show it open. Warn that crocodiles, floodwater, currents and water temperature vary. |
| Heat and walk safety | [NT Government heat guidance](https://nt.gov.au/parks/safety-rules/beat-the-heat), the [BOM NT forecast](https://www.bom.gov.au/nt/forecasts/), and [BOM Watarrka forecast](https://www.bom.gov.au/places/nt/watarrka/forecast/) | Use the forecast for the destination/date. The Kings Canyon Rim Walk has an NT rule requiring a start before 9am when the Watarrka forecast reaches 36°C. Recheck the official walk page and forecast before use. |
| Daily fuel prices | [MyFuel NT](https://myfuelnt.nt.gov.au/) and [NT retail fuel market context](https://nteconomy.nt.gov.au/prices-and-wages/retail-fuel-market) | MyFuel shows reported retail prices. A listed price does not guarantee fuel is in stock, a station is open or a vehicle can refuel there. Encourage travellers to call remote outlets and plan reserve range. |
| Seasonal market schedule | [Mindil Beach Sunset Market](https://mindil.com.au/contact/) | Check each season's dates and hours. The annual seasonal pattern is useful context, but event days and schedules can change. |
| Place name and location reference | [NT Place Names Register](https://www.ntlis.nt.gov.au/placenames/) and OpenStreetMap / Nominatim for map lookup | Use official dual names and gazetteer locations where available. Treat map coordinates as point anchors, not a park boundary or proof that a road reaches the point. |
| Darwin Waterfront visitor facility | [Darwin Waterfront beach](https://www.waterfront.nt.gov.au/the-beach) and [getting around](https://www.waterfront.nt.gov.au/getting-around) | Describe the managed lagoon/beach specifically. Do not imply that other Darwin beaches or estuaries are safe for swimming. |
| Standley Chasm visitor information | [Standley Chasm](https://standleychasm.com.au/) and the [NT Tjoritja / West MacDonnell live status page](https://nt.gov.au/parks/regions/alice-springs/check-park-open-alice-springs/tjoritja-west-macdonnell-national-park) | The site is privately operated and Arrernte-owned. Confirm operating hours, entry and booking with the operator. Check park access separately. |

## Data model and coordinate notes

- Each `rag/*.md` record contains a map anchor, normalized name and aliases, app-compatible region/tag values, named source authority, review date and source URLs. The planner uses these names and coordinates both as Gemini context and as a first-pass stop geocoder.
- Coordinates on new entries reuse the app's seeded POI anchors recorded in `terra_nt/lib/data/seed/seed_data.dart`. Several seed comments identify those coordinates as Nominatim lookups. Existing route-stop anchors are retained for compatibility. Recheck map placement visually against the NT Place Names Register or OpenStreetMap before using a coordinate for turn-by-turn navigation.
- Source authority and review date are included in the Gemini prompt. The response contract currently exposes place names and source URLs, not a full per-fact source record with authority and checked timestamp. That provenance gap should be addressed before claiming auditable citation grounding.
- Records are Markdown, loaded in filename order. The server has a 12,000-character context cap. A complete regional context must fit without dropping any records; after edits, calculate the `top_end`, `red_centre` and `full_nt` context sizes and inspect the omitted-record list.

## Known data gaps

The corpus does **not** currently ingest live road events, NT park-status pages, Kakadu access statuses, BOM forecasts/alerts, MyFuel prices or stock, permit decisions, park-pass pricing, accommodation/tour inventory or opening-hours APIs. It also has no geospatial route-specific retrieval, age/freshness scoring or vector index. These sources are links for user verification, not data the Gemini planner has fetched at response time.

The corpus is place guidance, not a safety validator. The wider architecture proposes deterministic checks for closures, vehicle suitability, permits and other hard constraints; those checks must be implemented and tested before output can be described as safety-checked.

## Refresh procedure

1. Review the live destination page and linked authority status pages.
2. Update only facts supported by sources. Keep volatile facts out of the body unless represented with a specific as-of timestamp and a reliable refresh process.
3. Set `checked` to the actual review date and keep the authority/source URL adjacent to the claim.
4. Run the planner's place parser/context-size check. Confirm no record is omitted for each region.
5. Restart the planning server because it loads place documents at startup.
6. Record data changes in the presentation/demo tracker or a dataset change log. Never describe a review date as a freshness guarantee.

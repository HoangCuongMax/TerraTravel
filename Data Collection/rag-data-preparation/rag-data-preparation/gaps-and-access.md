
## Historical fills applied (2026-10-17)

| Domain | Dataset | Status in package |
|--------|---------|-------------------|
| Coverage sites | ACCC Mobile Infrastructure 2025 (CC-BY 2.5 AU) | **Loaded** — NT site points in coverage.geojson (Telstra/Optus/TPG) |
| Coverage proximity | RemoteConnect v4 | **Loaded** as points; access_status **pending** until publisher licence confirmed |
| Coverage polygons | ACCC map files | **Not loaded** (large); sites used instead |
| Accommodation profiles | NT Tourism list 2020 (CC-BY) | **Loaded** — historical entities (no offers/prices) |
| Accommodation offers | — | Still empty |
| Ratings | — | Still empty |
| Live fuel | — | Still pending |
| Weather | BOM | Not loaded this pass |
| Road events machine feed | — | Partial / not expanded this pass |



## Fuel — historical extracts (used for demo)

- **Confirmed:** Monthly XLSX on data.nt.gov.au under **Creative Commons Attribution (CC-BY)**.
- November 2024 extract (`treasury-report-31-oct-to-01-dec-2024.xlsx`) loaded for Darwin–Katherine corridor.
- **96** fuel station entities; **313** product price observations for **2024-12-01**.
- Suitable for **demo / evaluation / historical comparison only**. Label as historical; not live.

## Fuel — live feed


# Gaps and access

Status date: 2026-10-17. A source being inaccessible is a valid finding. Nothing here was sent to any contact; questions below are drafts for an authorised team member.

## 1. Source feasibility by domain
| Domain | What was found | What is unconfirmed | Blocked capability |
|---|---|---|---|
| Fuel prices | The NT Government describes MyFuel NT as a real-time website under a statutory price reporting scheme. data.nt.gov.au lists **monthly historical** MyFuel NT daily-price XLSX datasets (newest seen: October 2024, published 6 Dec 2024), and a CC Attribution licence on the January 2022 resource page. | Any live API or feed; licence on each monthly dataset; whether the monthly series is still being published; storage, display and attribution rules for real-time prices. | Cheaper-stop suggestions, fuel savings |
| Mobile coverage | Not assessed in this pass. Carrier map pages and the audit page in the handoff were not opened. | Whether any reusable provider-specific geometry exists; licence. | Coverage warnings |
| Accommodation profiles / offers | ATDW process described: register as distributor, 30-day free trial, choose a paid distribution package, receive an API key after fees, embed tracking. | Package price; Distribution Licence Agreement (PDF not opened); which NT roadhouses and accommodation are listed; whether listings carry hours and facilities. | Live offers, itemised facilities at scale |
| Ratings | Nothing collected. Google Places policies were not reviewed. | Provider, licence, storage and display rules, fit with the OpenFreeMap stack. | Hotel rating suggestions |
| Roads and parks events | Three Kakadu access events captured from Parks Australia pages (see below). NT Road Report not opened; Kakadu access/alerts page URL only. | Machine-readable access to the NT Road Report. | Road closure checks |
| Weather | Not assessed. | BOM product and usage terms. | Weather warnings (supporting domain) |
| Places / coordinates | 3 entities have secondary-source coordinates; 20 are approximate 2-decimal values from no cited source. | Official entrance coordinates (NT Place Names Register not queried). | Route-accurate anchors |

## 2. Pilot targets versus delivered (Darwin to Katherine)
| Target | Delivered | Note |
|---|---|---|
| 10 verified service/place entities | 9 pilot-corridor entities collected, **0 verified** | Darwin, Adelaide River, Pine Creek, Emerald Springs Roadhouse, Katherine, Nitmiluk National Park, Nitmiluk Cabins, Nitmiluk Caravan Park, Leliyn. |
| 3 roadhouses or fuel outlets | 1 roadhouse (Emerald Springs); **0 with fuel evidence** | Fuel sale at Emerald Springs is recorded as unknown. A news report (undated, seen in a search snippet) says Hayes Creek roadhouse has closed; not verified, so no Hayes Creek record exists. |
| 3 accommodation options | 3 profile-level records, unverified | No dated offers or prices. |
| 10 fuel observations | 0 | No permitted live source confirmed. |
| 1 coverage sample | 0 | See section 1. |
| 5 ratings | 0 | No licensed provider. |
| 5 durable knowledge documents | 26 documents (9 in the pilot corridor) | Generated from fact records; every sentence cites fact IDs. |

## 3. Conflicts preserved, not resolved
- **Gunlom Falls:** one Parks Australia page says the lookout track is closed until further notice; another says the site is open with risks, 4WD only, and no swimming in the bottom pool. Both stored as `conflicting` events.
- **Jim Jim and Twin Falls:** Parks Australia states the area is closed for 2026 for road and infrastructure works. Any 4WD route that includes it would be wrong. The exact start and end instants were not published.
- **Glen Helen:** the Tourism NT listing says the property is temporarily closed (page updated 7 August 2025), so fuel, food and beds there are unconfirmed.

## 4. Identity mapping and app alignment
`mappings.jsonl` is empty. `seed_data.dart`, `places.py`, `RAG-SOURCE-REGISTER.md` and the existing 17 (or 20) place Markdown files were not provided, so no entity could be mapped to an existing POI ID and the handoff's stated counts could not be reconciled with the earlier "20 places" message. Fixes requested earlier (Yellow Water source, 4-decimal coordinates for Bitter Springs, Yellow Water, Nourlangie and Katherine Hot Springs) are **not applied** because those files were not provided; no records for Yellow Water or Nourlangie exist in this package.

## 5. Places still not researched
Tennant Creek, Barrow Creek, Aileron and Erldunda (Stuart Highway gap places) have no records. Barkly region has only Karlu Karlu and Daly Waters.

## 6. Unverified coordinates
Approximate (2 decimals, no source): Darwin, Kakadu National Park, Katherine, Nitmiluk National Park and its two accommodation entities, Mataranka Thermal Pool, Adelaide River, Pine Creek, Emerald Springs Roadhouse, Jim Jim and Twin Falls, Mereenie Loop, Alice Springs, Alice Springs Desert Park, Ormiston Gorge, Kings Canyon, Standley Chasm, Yulara, Uluṟu-Kata Tjuṯa. Secondary-source: Litchfield (team README example), Leliyn, Gunlom (campground), Karlu Karlu (campground), Palm Valley / Finke Gorge, Daly Waters, Glen Helen. All need review against official locations.

## 7. Rights
All page-based sources have `access_status: pending` and every permission `unknown`. Copyright and terms pages for the NT Government parks pages, Parks Australia, Tourism Australia, Tourism NT, Tourism Top End, Tourism Central Australia and Visit Katherine were not reviewed. Secondary sources (ExplorOz, Wikipedia) were used only to locate approximate coordinates.

## 8. Draft access questions (not sent)
- NT Department of Treasury and Finance, Economic Analysis (contact listed on the data.nt.gov.au dataset pages): Is there a documented, machine-readable feed or API for current MyFuel NT prices? What are the terms for storing and displaying prices in a third-party travel app, and the update cadence?
- ATDW: Which distribution package covers NT roadhouse and accommodation listings with facilities and hours, what is the price, and may listing data be stored for retrieval and embeddings?
- Mobile carriers: Is there licensed provider-specific coverage geometry for use in a travel app, and which network brand footprints does it cover?
- Parks Australia and NT Parks: Is there a machine-readable feed for park and road access status?

## 9. Impact summary
Without a confirmed fuel feed, ratings provider, coverage geometry and any reviewer sign-off, only the knowledge and access-event parts of the dataset can support a labelled pilot demonstration. Fuel, coverage and hotel-rating suggestions can be demonstrated only with the synthetic fixtures.

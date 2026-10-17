# Terra NT RAG data inventory

**Package:** `rag-data-preparation/`  
**Dataset version:** 0.4.0-weather  
**Prepared:** 17 October 2026 (Australia/Darwin)  
**Contract:** SMART-TRAVEL-RAG-TEAM-HANDOFF.md  

This note records **what data was loaded**, **why it was chosen**, **what is still missing**, and **why**. It is a preparation inventory, not a product release certificate.

---

## 1. Purpose of this package

Support a Darwin–Katherine (and related NT) travel planner with:

- Traceable place knowledge  
- Historical fuel price comparison (demo)  
- Infrastructure-based mobile proximity signals (demo)  
- Accommodation **profiles** (not live booking)  
- Time-bound weather forecasts and climate context  

All structured rows follow the handoff envelope (`schema_version`, `source_ids`, `verification_status`, `data_mode`, etc.). **Real** and **synthetic_demo** records are kept separate.

---

## 2. Data that was used (and why)

### 2.1 Historical fuel prices — MyFuel NT (November 2024 extract)

| Field | Detail |
|-------|--------|
| **Source** | [data.nt.gov.au – MyFuel NT November 2024](https://data.nt.gov.au/dataset/myfuel-nt-november-2024) |
| **File** | `treasury-report-31-oct-to-01-dec-2024.xlsx` |
| **Licence** | Creative Commons Attribution (CC-BY) |
| **In package** | `observations/fuel_prices.jsonl` (313 historical + 2 synthetic); 96 fuel station entities |
| **Day used** | 2024-12-01 (latest day in extract) |
| **Why** | Official NT retail price reporting scheme; only confirmed **open** bulk dataset suitable for product demos without inventing prices. Supports “compare stops and estimate saving” arithmetic under a historical label. |
| **Why not live** | Live MyFuel website is not a documented bulk/API redistribution licence. Production live use needs written clearance from NT Consumer Affairs. |

**Attribution:** MyFuel NT historical data, Northern Territory Government, CC-BY.

---

### 2.2 Mobile infrastructure — ACCC Mobile Infrastructure Report (2025)

| Field | Detail |
|-------|--------|
| **Source** | [ACCC Mobile Infrastructure Report – data release](https://data.gov.au/data/dataset/accc-mobile-infrastructure-report-data-release) |
| **Licence** | Creative Commons Attribution 2.5 Australia |
| **In package** | `observations/coverage.geojson` — NT-filtered **site points** (Telstra 264, Optus 132, TPG 45) as at **31 January 2025** |
| **Why** | Only national, openly licensed, carrier-specific infrastructure dataset with clear terms. Lets the demo show “nearest recorded infrastructure” and technology flags without scraping carrier consumer maps. |
| **Limitation** | Points are **not** coverage polygons. Site presence ≠ usable signal, speed, or continuous roadside coverage. Labelled `basis: operator_prediction`, with explicit limitations text on each feature. |

**Attribution:** ACCC Mobile Infrastructure Report data release, CC-BY 2.5 AU.

---

### 2.3 Mobile proximity — RemoteConnect enriched v4 (user-supplied)

| Field | Detail |
|-------|--------|
| **Source** | `RemoteConnect_enriched_v4.csv` (supplied by Alvi) |
| **In package** | 188 Point features in `coverage.geojson` (nearest Telstra/Optus/TPG km, LTE/5G within 50 km flags) |
| **Why** | Complements ACCC sites with locality-level proximity for remote communities and highway stops (including Aileron, Barrow Creek, Erldunda, Daly Waters). |
| **Limitation** | Source itself states: *“Infrastructure proximity only; not proof of service quality.”* Publisher/redistribution licence **not independently confirmed** → `access_status: pending`. Demo only until rights are confirmed. |

---

### 2.4 Accommodation profiles — NT Tourism provider list 2020

| Field | Detail |
|-------|--------|
| **Source** | [NT Tourism Accommodation Provider List Jan–Dec 2020](https://data.nt.gov.au/dataset/nt-tourism-accommodation-provider-list-january-december-2020) |
| **Licence** | Creative Commons Attribution |
| **In package** | 157 accommodation **entities** (name, address, coordinates, phone, URL) |
| **Why** | Only free, Territory-scoped open list of providers with locations. Enough to seed “what stays exist near the corridor” for RAG and entity linking. |
| **Why not offers** | List has **no** room rates, availability, or stay dates. Live quotes need ATDW + a booking provider under commercial licence. Contacts may be outdated (2020 snapshot). |

---

### 2.5 Weather — Bureau of Meteorology (FTP forecasts + published climate normal)

| Field | Detail |
|-------|--------|
| **Source** | BOM anonymous FTP `ftp://ftp.bom.gov.au/anon/gen/fwo/` (IDD10150 Darwin, IDD10161 Alice Springs, IDD10111 NT district, IDD10721 fire weather) |
| **Climate** | Published Darwin Airport (014015) 1991–2020 October normals |
| **Licence** | BOM copyright; FTP is the BOM-recommended automated access path under default copyright terms |
| **In package** | `observations/weather.jsonl` (19 records: city day forecasts, territory outlook, fire-weather warning, one climate normal) |
| **Why** | Official forecasts for heat/wet planning demos; climate normal for “typical October heat” context. Website bulk access is blocked; FTP avoids scraping. |
| **Limitation** | Forecasts are **time-bound** (`issued_at` / `valid_until`). Must be refreshed; must not be embedded as evergreen knowledge. Climate normal is **not** a forecast. |

**Attribution:** © Commonwealth of Australia, Bureau of Meteorology.

---

### 2.6 Place knowledge, facts, access events, evaluation

| Asset | Role |
|-------|------|
| `knowledge/*.md` (~26 docs) | Durable place descriptions for RAG (parks, towns, some roadhouses) |
| `facts.jsonl` | Structured assertions (permits, access, facilities) with provenance |
| `entities.jsonl` | Unified place/fuel/accommodation IDs |
| `observations/access_events.geojson` | Partial road/park event samples |
| `evaluation/cases.jsonl` | Synthetic calculation tests (e.g. fuel saving arithmetic) |
| `sources.jsonl` | Registry of every source, licence, and access status |

**Why:** Required by the handoff for Stage A/B pilot: provenance, evaluation fixtures, and knowledge separate from volatile observations.

---

### 2.7 Synthetic fixtures (evaluation only)

Two demo fuel stations (185 vs 215 c/L diesel) under `data_mode: synthetic_demo`.  
**Why:** Handoff requires evaluation cases for gross/net saving math without mixing invented numbers into real station names.

---

## 3. Data that is missing (and why)

### 3.1 Live fuel prices

| | |
|--|--|
| **Missing** | Current pump prices under an approved product feed |
| **Why missing** | MyFuel NT public site is not documented as a bulk redistribution API. Historical CC-BY extracts are allowed; **live** storage/display in an app needs written permission from **NT Consumer Affairs**. |
| **Impact** | Cannot claim “cheapest stop **today**” or live savings. |
| **Path** | Email/call NT Consumer Affairs; update `access_status` only after written terms. |

---

### 3.2 Carrier coverage **polygons** (predicted service areas)

| | |
|--|--|
| **Missing** | Full Telstra/Optus/TPG predicted coverage polygons for route intersection |
| **Why missing** | ACCC **map** files exist but are large and complex; this pass loaded **site points only**. Consumer coverage maps on carrier sites are not freely redistributable as product geometry without licensing. |
| **Impact** | Cannot reliably shade “no signal on this road segment”; only nearest-infrastructure and caveats. |
| **Path** | Ingest ACCC coverage map subsets for a Darwin–Katherine bbox, or license operator geometry. |

---

### 3.3 Dated accommodation offers (total stay price)

| | |
|--|--|
| **Missing** | `accommodation_offers.jsonl` rows (check-in/out, party, total_price_cents) |
| **Why missing** | No open historical quote feed. ATDW listings ≠ live inventory. Booking engines need commercial contracts. |
| **Impact** | Cannot rank stays by **total trip cost** for specific dates. |
| **Path** | Product budget for ATDW distribution licence + booking API. |

---

### 3.4 Guest ratings

| | |
|--|--|
| **Missing** | `ratings.jsonl` |
| **Why missing** | No open, redistributable NT guest-score dataset compatible with offline/OpenFreeMap constraints. Google Places and similar have strict caching/display rules. |
| **Impact** | Cannot rank by review score + count with defensible attribution. |
| **Path** | Licensed ratings provider or operator-published scores only. |

---

### 3.5 Identity mappings to app seed POIs

| | |
|--|--|
| **Missing** | Populated `mappings.jsonl` (`entity_id` → `app_poi_id`) |
| **Why missing** | Requires backend owner to match preparation entities to existing Flutter seed IDs without inventing new stop IDs. |
| **Impact** | Risk of duplicate or conflicting anchors in the app. |
| **Path** | Explicit manual mapping pass; `match_method: manual_verified`. |

---

### 3.6 Full roadhouse facility inventory

| | |
|--|--|
| **Missing** | Complete facility facts (food, toilets, showers, water, hours) for every corridor roadhouse |
| **Why missing** | Stage B incomplete; many operators only publish partial pages; hours change seasonally. |
| **Impact** | “Best practical stop” recommendations stay thin outside fuel. |
| **Path** | Manual research per operator + official pages; never invent facilities. |

---

### 3.7 Machine-readable live road/park closures

| | |
|--|--|
| **Missing** | Continuous Road Report / Kakadu access feed into `access_events.geojson` |
| **Why missing** | Road Report is primarily web/app; machine use needs confirmation of terms. Kakadu Access Report is manual. NFDH historic roadworks exist but licence/fit for product not fully onboarded this pass. |
| **Impact** | Cannot automate “road closed” without a human-checked observation. |
| **Path** | Confirm DIPL/Parks feed terms; until then timestamped manual events + `official_check_url`. |

---

### 3.8 Independent verification

| | |
|--|--|
| **Missing** | Widespread `verification_status: verified` |
| **Why missing** | Handoff requires a **second person** to sign off high-impact permits, coordinates, and rights. Collector and reviewer must be recorded separately. |
| **Impact** | Package remains preparation/demo grade, not production-certified. |

---

### 3.9 Rights confirmation for some page sources and RemoteConnect

| | |
|--|--|
| **Missing** | Confirmed redistribution rights for every page-scraped knowledge source; RemoteConnect publisher licence |
| **Why missing** | Public readability ≠ product storage/embedding rights. RemoteConnect arrived as a team file without a formal open-data landing page in this package. |
| **Impact** | Knowledge and RemoteConnect points stay `pending` / demo until cleared. |

---

## 4. Summary table

| Domain | Loaded? | Nature | Blocks product feature? |
|--------|---------|--------|-------------------------|
| Fuel prices | Yes (historical) | CC-BY Nov 2024 | Live “today” comparison until clearance |
| Fuel stations | Yes | Entities from MyFuel | — |
| Coverage sites | Yes | ACCC points 2025 | Full route shading needs polygons |
| Coverage proximity | Yes (demo) | RemoteConnect | Licence pending |
| Accommodation profiles | Yes | NT Tourism 2020 | — |
| Accommodation offers | **No** | — | Total stay cost |
| Ratings | **No** | — | Score ranking |
| Weather forecasts | Yes | BOM FTP (time-bound) | Must refresh |
| Climate normal | Yes | BOM published | Context only |
| Place knowledge | Yes | Markdown | — |
| App POI mappings | **No** | — | Safe app join |
| Live road closures | Partial | — | Automated access warnings |
| Independent review | **No** | — | Production sign-off |

---

## 5. Principles applied (do not reverse)

1. **No invented live prices** under real station names.  
2. **Historical ≠ current** — always expose date and attribution.  
3. **Proximity ≠ service quality** for mobile data.  
4. **Listings ≠ bookable offers.**  
5. **Missing data is reported**, not fabricated to fill quotas.  
6. **Synthetic evaluation data** stays in `data_mode: synthetic_demo`.  
7. **BOM:** use FTP/copyright terms; do not scrape blocked web endpoints.

---

## 6. Suggested next actions

1. **Product owner:** request live MyFuel terms; decide ATDW + ratings budget.  
2. **Data:** optional ACCC coverage polygon subset for pilot corridor; complete roadhouse facility facts; confirm RemoteConnect licence.  
3. **Backend:** fill `mappings.jsonl`.  
4. **Reviewer:** verify permits, coordinates, and mark records `verified`.  
5. **Ops:** schedule BOM FTP refresh for forecasts; never ship stale forecasts as live.

---

## 7. File map

```text
rag-data-preparation/
  DATA-INVENTORY.md          ← this file
  README.md
  manifest.json
  sources.jsonl
  entities.jsonl
  facts.jsonl
  mappings.jsonl             (empty — gap)
  observations/
    fuel_prices.jsonl        historical MyFuel + synthetic
    coverage.geojson         ACCC sites + RemoteConnect points
    weather.jsonl            BOM forecasts + climate normal
    accommodation_offers.jsonl  (empty — gap)
    ratings.jsonl            (empty — gap)
    access_events.geojson
  knowledge/
  evaluation/cases.jsonl
  evidence/
  gaps-and-access.md
  validation-report.md
  CHANGELOG.md
```

---


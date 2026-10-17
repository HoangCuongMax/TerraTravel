# CHANGELOG

## 2026-10-17 (weather)

- Loaded BOM NT products via **anonymous FTP** (`ftp://ftp.bom.gov.au/anon/gen/fwo/`):
  - Darwin city 7-day forecast (IDD10150)
  - Alice Springs forecast (IDD10161)
  - NT district outlook (IDD10111)
  - NT fire weather (IDD10721)
  - Darwin Airport Oct climate normal 1991–2020 (published averages)
- `observations/weather.jsonl` populated; sources `bom-ftp-fwo-nt`, `bom-climate-averages-published`
- Forecasts are time-bound — refresh from FTP; do not treat as static knowledge


## 2026-10-17 (historical gap fill)

- **Coverage:** ACCC 2025 mobile sites filtered to NT → coverage.geojson Point features (Telstra 264, Optus 132, TPG 45) + RemoteConnect 188 proximity points
- **Accommodation entities:** 157 from NT Tourism Accommodation Provider List 2020 (CC-BY), corridor + selected Red Centre
- Sources registered: `accc-mobile-infrastructure-2025`, `nt-tourism-accommodation-2020`, `remoteconnect-enriched-v4` (pending rights)
- Still empty: live fuel, ratings, dated accommodation offers, weather observations
- All historical data labelled; not for live claims


## 2026-10-17

- Integrated **historical MyFuel NT** (CC-BY, November 2024 extract):
  - 96 fuel station entities on Darwin–Katherine corridor and approaches
  - 313 historical product price observations (U91/LAF, Diesel, P95, P98, Premium Diesel, LPG) for 2024-12-01
  - 2 synthetic evaluation fuel rows retained
  - Source `myfuel-nt-historical-ccby-nov2024` (access_status: confirmed for historical only)
  - Evidence: `evidence/myfuel-nt-nov2024-ccby.txt`
- Live MyFuel feed remains pending NT Consumer Affairs clearance
- All other package content retained from prior Stage A/B preparation

# Changelog

## 0.1.0 (2026-10-17) pilot draft
- First package built to the handoff contract.
- Rebuilt the earlier 12 place records and 11 newly researched places as entity + fact + knowledge records; added 3 pilot accommodation/roadhouse entities.
- Added 56-row source registry with unknown permissions, 3 real Kakadu access events (2 conflicting), 20 synthetic evaluation cases and fixtures, and current-loader exports.
- **Correction:** the earlier flat records (`terra_nt_places` folder, JSON, CSV and the licensing note) were dated `2026-10-08` as the retrieval date. The actual retrieval date was 2026-10-17. Those earlier files are superseded; this package uses 2026-10-17.
- **Correction:** the earlier flat records were all labelled with a checked date implying review; no independent review has been done, so nothing here is `verified`.

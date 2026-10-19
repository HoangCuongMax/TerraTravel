# Terra NT — Northern Territory Travel Planner

Terra NT is a Flutter mobile application for planning road trips through Australia’s Northern Territory. It combines a map-based itinerary, traveller preferences, saved routes and source-linked travel information.

This repository contains the existing app, its Python planning backend, collected data, tests and submission evidence. **Start here to run the project.** Use the [complete documentation index](docs/DOCUMENTATION-INDEX.md) for the full set of guides and team instructions, and the [submission handoff](docs/SUBMISSION.md) for the latest verification results and remaining issues.

## Features

- **Explore:** search Northern Territory places and view map markers and place details.
- **Plan AI:** answer a questionnaire and generate an itinerary through the configured backend, or use seeded itineraries when no planning URL is supplied.
- **Itinerary:** inspect activities, skip or restore stops, edit route order and open driving directions.
- **Saved routes:** retain itineraries locally, with Firebase account integration.
- **Trip insights:** import structured JSON, browse collected historical records, preview clearly labelled fictional examples, or request public accommodation/roadhouse map listings.
- **Appearance:** Light is the launch default; Profile also offers Dark and System.

Maps use keyless OpenFreeMap styles. Driving geometry comes from the public OSRM demo service, with straight stop-to-stop connectors as an unavailable-service fallback. Directions open an external maps application. These services do not establish current road access, traffic or closure status.

## Quick links for assessment

| Resource | Purpose |
|---|---|
| [Submission handoff](docs/SUBMISSION.md) | What is included, cleanup decisions, exact test results and remaining checks |
| [Application walkthrough](docs/application-walkthrough/2026-10-17/README.md) | 51 screenshots with numbered steps and descriptions |
| [Presentation deck](docs/presentation-output/Terra-NT-Team-Presentation.pptx) | Team presentation artifact; use current status documents for later changes |
| [Speaker script](docs/presentation-output/Terra-NT-Team-Speaker-Script.md) | Supporting presentation notes |
| [Documentation index](docs/DOCUMENTATION-INDEX.md) | Overall project information and links |
| [Data integration](docs/DATA-COLLECTION-INTEGRATION.md) | Imported data, provenance, generation instructions and exclusions |
| [Online service status](docs/ONLINE-DATA-STATUS.md) | Connected features, recorded failures and limits |

## Requirements

- **Flutter 3.47.1 / Dart 3.13.1**, following the project’s pinned toolchain.
- Android SDK and an emulator/device for Android; macOS and Xcode for iOS.
- Firebase configuration and access to an enabled sign-in provider. The repository includes the existing Firebase client configuration; it grants no administrative access or test-account credentials. A reviewer needs an authorised account or their own Firebase setup.
- **Python 3.13** and the backend requirements only when running the planning server.
- Internet access for first-time dependency installation, sign-in, uncached maps and online planning/listing searches.

## Run the mobile app

From a checkout of this repository:

```sh
cd terra_nt
flutter pub get
cp .env.example .env
flutter run --dart-define-from-file=.env
```

On Windows, replace `cp .env.example .env` with `copy .env.example .env`. Select the desired device if Flutter prompts, or add `-d <device-id>` from `flutter devices`.

The example contains `PLAN_API_URL=`. **Leave it empty for seeded route generation.** This mode requires no model API key or planning server, but sign-in still uses Firebase. Existing saved routes and bundled records can be used without a model call. The questionnaire’s normal 4×4 path has 15 steps; other vehicle choices can omit the off-road question.

For iPhone signing, simulator and Swift-package details, follow [iOS setup](docs/IOS-SETUP.md). Android builds use the checked-in Gradle project under `terra_nt/android/`.

## Enable online AI planning

The app sends requests to the backend; model credentials stay on the server. Follow the [planning server guide](tools/plan_server/README.md) for platform-specific setup and supported backends.

For the existing macOS demo setup, run from the repository root:

```sh
python3.13 -m venv tools/plan_server/.venv
tools/plan_server/.venv/bin/python -m pip install -r tools/plan_server/requirements.txt
```

Configure `tools/plan_server/.env` locally with the chosen provider’s credentials. Install `cloudflared` if using the temporary HTTPS demo connection, then run:

```sh
tools/plan_server/.venv/bin/python tools/plan_server/start_connected.py
```

The helper starts the authenticated Gemini planner, checks that authentication is required, creates an HTTPS tunnel and updates `terra_nt/.env`. Keep it running. In a second terminal:

```sh
cd terra_nt
flutter run --dart-define-from-file=.env
```

The tunnel address changes after restarting, so rebuild the app after updating the URL. If the helper cannot verify the tunnel, online planning is not ready; use the seeded mode or resolve the connection. The laptop-hosted tunnel is a demonstration setup, not a permanent deployment. For Android USB/Windows instructions, see the server guide and its `start.bat` / `link-devices.bat` helpers.

## Collected data and RAG

Open an itinerary → **Trip insights → View collected records** to load **470 historical records** bundled with the app:

- 313 fuel-price observations from 1 December 2024.
- 157 accommodation provider listings from 2020.

Historical records retain their dates and attribution. They do not provide today’s cheapest fuel, current rooms or guest ratings. Synthetic examples are separate and explicitly labelled. Public OpenStreetMap searches provide community listings, not confirmed operating status or availability.

The preparation package also includes infrastructure/proximity points, weather snapshots, facts and draft place documents. It is not all promoted into the active planner. The active RAG implementation uses region-filtered Markdown context and optional structured evidence, without an embedding/vector database. The full production RAG proposal remains future work.

See [data integration](docs/DATA-COLLECTION-INTEGRATION.md), [RAG preparation handoff](docs/SMART-TRAVEL-RAG-TEAM-HANDOFF.md) and the [active corpus guide](tools/plan_server/rag/README.md). Regenerate collected runtime data from the repository root with:

```sh
python3 tools/plan_server/import_collected_data.py
```

## Tests and builds

Run Flutter commands from `terra_nt/`:

```sh
flutter analyze
flutter test
flutter test test/features/insights
flutter build apk --release --dart-define-from-file=.env
```

Run backend checks using Python 3.13 from `tools/plan_server/`:

```sh
.venv/bin/python -m unittest discover
```

On Windows, the virtual-environment executable is `.venv\Scripts\python.exe`.

**Current verification is not fully green.** On 19 October 2026 the analyzer passed, while the full Flutter suite reported 969 passing and 9 failing tests. The supported-Python backend result and exact failure names are in the [submission handoff](docs/SUBMISSION.md). The targeted insight checks previously passed; physical-device checks remain incomplete. These commands are reproducible checks, not a claim they all currently pass.

## Repository structure

```text
terra_nt/          Flutter app, native platform projects, assets and tests
  lib/             App shell, pure models/helpers, state and feature widgets
  assets/          Bundled fonts, artwork and runtime datasets
tools/plan_server/ Python planner, active RAG corpus and import tools
tools/plan_stub/   Local rehearsal/test server
Data Collection/   Supplied preparation data, sources and evaluation fixtures
docs/              Setup, API/data contracts, walkthrough and presentation
design/            Design reference and token sources
tasks/             Historical implementation task records
reports/           Retained reviews, research and development reports
```

Development rules are in [CLAUDE.md](CLAUDE.md), with its generated [AGENTS.md](AGENTS.md) copy. Historical PRD/task documents provide context; later operator decisions and current implementation take precedence as described in the engineering guide.

## Limitations and configuration

- Live fuel feeds, route-level coverage polygons, licensed guest ratings and dated room inventory are not connected.
- Infrastructure proximity is not proof of usable internet. Historical prices are not current travel advice.
- Viewed-map caching covers areas previously opened, for up to 30 days; it is not a complete downloaded route or offline navigation system.
- Road geometry, forecasts, access and opening information require current checks. Use [NT Road Report](https://roadreport.nt.gov.au/) and the relevant official/operator sources before departure.
- Secrets, local `.env` files, virtual environments and build output are excluded from Git. Supply credentials locally; never commit a service-account private key.
- Historical screenshot batches and the duplicate walkthrough ZIP are excluded from the current submission tree. The current walkthrough and established September review evidence remain versioned. Existing Git history is preserved.

This project includes third-party code, fonts, maps and data under their respective terms. Preserve the bundled notices and map/data attribution. No new licence for the project’s original code is granted by this README.

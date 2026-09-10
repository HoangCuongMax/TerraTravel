# TerraTravel / Terra NT

**PRT691 AI Practice — evidence-grounded NT self-drive trip planner**

Terra NT is a mobile-first academic prototype for planning the **Darwin → Kakadu → Katherine** self-drive corridor. The project is designed around a simple principle: safety-critical travel decisions should be grounded in traceable evidence and deterministic checks rather than generated from an LLM's memory.

## Prototype screenshots

| Explore | AI route plan | Interactive safety sheet |
|---|---|---|
| ![Explore map](docs/screenshots/explore.png) | ![Evidence-grounded plan](docs/screenshots/plan.png) | ![Interactive sheet](docs/screenshots/interactive-sheet.png) |

## What is implemented

- Mobile-first UI with smooth SPA transitions and touch-friendly controls.
- Interactive Google-Maps-inspired route map with drag/pan, zoom and route/park/fuel/permit layers.
- Search autocomplete and photographic place cards using credited Wikimedia Commons travel images.
- Prototype login, onboarding and traveller profile.
- Vehicle-aware planning inputs including standard car, 4x4, campervan and caravan/towing.
- Deterministic planning/rules layer for the Darwin–Kakadu–Katherine corridor.
- Evidence metadata: source authority, source type, URL and last-checked date.
- Safety notices for road access, fuel uncertainty, weather, park access and permit boundaries.
- Hard-exclusion demonstration for the 2026 Jim Jim / Twin Falls closure snapshot.
- Save, remove, restore and reorder itinerary stops.
- Place and evidence bottom sheets, motion feedback, map layers, saved routes and profile settings.
- Google Maps export/open actions for route navigation.
- Reduced-motion accessibility support.

## Repository structure

```text
browser_demo/             Dependency-free interactive web prototype
flutter_app/              Flutter mobile app source
  lib/                    Models, state, rules, UI and demo data
  docs/                   Assignment alignment + data/safety notes
  test/                   Planner engine tests
demo/                     Standalone single-file demo
docs/screenshots/         Prototype screenshots
```

## Run the browser prototype

Open `browser_demo/index.html` in a modern browser. The prototype login accepts any valid email plus any non-empty password.

For a single-file demo, open:

```text
demo/TerraNT_Mobile_v4_Interactive_Live_Demo.html
```

## Run the Flutter app

With Flutter installed:

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter run
```

If platform folders are missing, run `flutter create .` once inside `flutter_app/` before the commands above.

## Architecture

```text
Traveller preferences / vehicle profile
                 ↓
         Planner rules layer
                 ↓
  Curated evidence / future RAG API
                 ↓
      Allowed itinerary stops
                 ↓
     Human-readable plan + citations
                 ↓
          Traveller review
```

The current browser and Flutter prototypes use a **curated demonstration evidence snapshot dated 10 September 2026**. A future RAG service should replace the demo evidence seam, while legal/safety constraints remain outside free-form language generation.

## Responsible-AI boundary

This repository is an academic prototype, not a live travel-safety service. It does **not** guarantee current road, park, fuel, weather, operator or permit status. The design deliberately:

- does not infer Aboriginal land permission or cultural protocol;
- does not present uncertain fuel/operator availability as guaranteed;
- exposes source authority and freshness;
- keeps user review and editing in the workflow; and
- treats safety rules as constraints that an LLM should not override.

See `flutter_app/docs/DATA_AND_SAFETY.md` and `flutter_app/docs/ASSIGNMENT_ALIGNMENT.md`.

## Photo credits

The browser prototype references credited Wikimedia Commons images for Yellow Water / Kakadu, Nitmiluk Gorge, Darwin Waterfront and Pine Creek. Full credit information is displayed in the app profile and source code.

## Project status

Current milestone: **interactive mobile prototype / Assignment 2 evidence build**. Live Google Maps tiles, live NT APIs and a production RAG backend are future work.

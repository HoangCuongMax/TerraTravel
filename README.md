# TerraTravel / Terra NT

**PRT691 AI Practice — evidence-grounded NT self-drive trip planner**

Terra NT is a mobile-first academic prototype for the **Darwin → Kakadu → Katherine** self-drive corridor. The core design principle is that safety-critical travel decisions should be grounded in traceable evidence and deterministic checks rather than generated from an LLM's memory.

## Current repository build

The repository now contains a runnable browser prototype with:

- professional mobile-first interface and smooth screen transitions;
- prototype login, Explore, Plan AI, Trips, Saved and Profile flows;
- Google-Maps-inspired route view for Darwin–Kakadu–Katherine;
- Route, Parks, Fuel and Permits map layers;
- search and photographic NT destination cards;
- traveller and vehicle-aware planning context;
- evidence/source detail views and uncertainty warnings;
- save, reorder, restore and Google Maps export interactions;
- real Northern Territory travel photography with credits; and
- reduced-motion support for accessibility.

## Run

Open:

```text
browser_demo/index.html
```

Prototype login accepts any valid email plus any non-empty password, for example:

```text
max@example.com
123456
```

No build system or API key is required for the browser prototype.

## Repository structure

```text
browser_demo/
  index.html              App entry point
  styles.css              Mobile UI and animation system
  app.js                  App state, itinerary, map and interactions
  manifest.webmanifest    Installable-web-app metadata
  service-worker.js       Basic offline shell caching
  README.md               Browser prototype notes

docs/
  IMPLEMENTATION_EVIDENCE.md
  ASSIGNMENT_ALIGNMENT.md
```

## Implemented architecture

```text
Traveller profile / vehicle / trip preferences
                    ↓
          deterministic planning rules
                    ↓
       curated evidence/source metadata
                    ↓
        allowed corridor itinerary
                    ↓
 evidence-linked warnings + human-readable plan
                    ↓
          traveller review / edit / export
```

The current prototype uses a **curated demonstration evidence snapshot dated 10 September 2026**. Live Google Maps tiles, live NT data APIs and a production RAG backend are future work.

## Responsible-AI boundary

This is an academic prototype, not a live travel-safety service. It does **not** guarantee current road, park, fuel, weather, business or permit status. The design deliberately:

- does not infer Aboriginal land permission or cultural protocol;
- does not present uncertain fuel/operator availability as guaranteed;
- exposes source authority and freshness in the prototype data model;
- keeps traveller review/editing in the workflow; and
- keeps safety constraints conceptually outside free-form language generation.

## Photo credits

The prototype references credited Wikimedia Commons images for Yellow Water / Kakadu, Nitmiluk Gorge, Darwin Waterfront and Pine Creek. Credit metadata is included in the application source/profile content.

## Project status

Current milestone: **Assignment 2 interactive prototype**. The next stage is evaluation: controlled rule tests, retrieval/freshness testing when the data layer is connected, and user/expert validation against the stakeholder requirements.

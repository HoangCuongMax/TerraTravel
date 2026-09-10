# Terra NT — implementation evidence for PRT691 Assignment 2

Date: 10 September 2026

## Prototype milestone

The project has progressed from architecture/design artefacts to a working mobile-first prototype. The current browser build demonstrates the Darwin–Kakadu–Katherine corridor and the main interaction flows required to evaluate the project concept.

## Implemented interaction evidence

| Area | Current implementation | Assignment significance |
|---|---|---|
| Mobile interface | Login, Explore, Plan AI, Trips, Saved and Profile screens | Demonstrates a concrete user-facing prototype rather than design only |
| Route map | Google-Maps-inspired corridor map, numbered stops and route line | Makes corridor scope and itinerary structure visible |
| Map layers | Route, Parks, Fuel and Permits toggles | Translates data-context categories into user-facing controls |
| Traveller context | Trip and vehicle context represented in the planning design | Supports different needs identified in stakeholder research |
| Safety/evidence UI | Evidence/source details, warnings and human-review wording | Demonstrates transparency and Responsible AI requirements |
| Itinerary editing | Save, reorder, restore and Google Maps export | Preserves human control over the final travel decision |
| Destination content | NT photographs and route-relevant destination cards | Improves discoverability/usability while keeping route scope narrow |
| Motion/accessibility | Smooth transitions, route animation and reduced-motion support | Improves mobile usability without making motion mandatory |

## Data and Responsible AI boundary

The current build uses a curated demonstration evidence snapshot rather than a live safety service. The prototype is designed so that source authority, source type, URL and freshness can be stored with safety-relevant facts. Road, park, fuel, weather and permit information should be refreshed through a future retrieval/API layer.

The prototype does not treat free-form AI generation as the authority for road access, permits or other hard constraints. The future RAG component is intended to retrieve and explain evidence, while deterministic checks continue to decide whether known constraints are satisfied.

## Current technical limitation

The map inside the browser prototype is a Google-Maps-inspired local rendering, not Google Maps tiles. Google Maps is used as an external export/navigation destination. Live mapping, live NT datasets and a production RAG backend remain future work.

## Evaluation enabled by this milestone

The implementation now allows the team to test whether users can:

1. understand the corridor and route sequence;
2. identify safety/evidence information;
3. understand why a warning or constraint is shown;
4. distinguish travel inspiration from safety-critical information;
5. edit/reorder the itinerary while retaining human control; and
6. use vehicle/trip constraints to assess whether recommendations are suitable.

Formal performance claims should not be made until controlled technical tests and user/expert evaluation are completed.

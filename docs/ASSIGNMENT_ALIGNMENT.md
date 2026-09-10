# PRT691 Assignment 2 — prototype traceability

This file links the implemented Terra NT prototype to the Assignment 2 project-progress evidence.

## Stakeholder evidence → implemented response

| Stakeholder finding | Prototype response |
|---|---|
| Travellers manually combine multiple sources | Route result brings route, warnings and evidence context into one interface |
| First-time visitors may not know what to check | Planning flow explicitly surfaces safety/access categories and evidence-first guidance |
| Users want current and traceable information | Prototype data model carries source authority/type/URL/last-checked metadata |
| Vehicle suitability changes route feasibility | Vehicle/travel profile is part of the planning requirements and rules architecture |
| Fuel is safety-critical | Fuel is represented as a safety/verification category rather than guaranteed availability |
| Permits/access must not be guessed | Permit information is treated as an evidence/rules boundary, not a free-form AI decision |
| Closures require replanning | The prototype supports itinerary editing/restoration and is designed for constrained alternatives |
| Caravan/towing users need different constraints | The project requirements include differentiated vehicle/towing context |
| Budget users care about cost but safety comes first | Personalisation is subordinate to hard safety constraints |
| Small operators need accurate representation | Destination recommendations avoid claiming live availability without evidence |

## Assignment 2 Section 5 — AI Development

The prototype provides concrete evidence for:

- a mobile-first system architecture;
- implemented user flows rather than only wireframes;
- an interactive corridor map;
- deterministic planning/rules concepts;
- provenance and safety metadata;
- itinerary editing and human review; and
- a clear seam for later RAG/live-data integration.

## Assignment 2 Section 6 — Responsible AI

The prototype demonstrates Responsible AI through visible source/evidence concepts, conservative warnings, human review/edit control and a strict design boundary around safety-critical/legal access decisions. The app is labelled as an academic prototype and does not claim to be a live safety service.

## Assignment 2 Section 7 — Evaluation

The implementation is now mature enough to support controlled evaluation. Formal evaluation should test rule compliance, source correctness/freshness, warning comprehension, vehicle-specific constraints, itinerary editing and expert/user trust. UI completion alone is not treated as evidence of factual accuracy or safety performance.

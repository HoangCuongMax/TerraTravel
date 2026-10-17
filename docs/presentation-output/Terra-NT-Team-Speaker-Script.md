# Terra NT team presentation script

This script follows the fourteen-slide plan and a 10:00 target, including the 2:35 app demonstration. The slide notes in the PowerPoint contain the same role-specific talk tracks and evidence boundaries.

## Team roles

| Member | Slides | Target time | Primary responsibility |
|---|---:|---:|---|
| Max Hoang | 1, 4, 5, 8, 13 | 4:10 | Project framing, system evolution, data architecture, RAG explanation and demo lead |
| Ahanaf Alvi | 2, 11 | 1:25 | Problem framing and evaluation boundary |
| Shaobin Chen | 3, 7, 10 | 2:00 | Research findings, data preparation and responsible AI |
| Tarik Bulut | 9, 12, 14 | 1:45 | App structure, current implementation and next work |

## Slide-by-slide script

### 1. Terra NT: NT self-drive trip planning — Max — 0:30

“We are developing Terra NT, a trip-planning prototype for self-drive travel in the Northern Territory. We will show how our research shaped the design, what the current system can do, and what still needs validation.”

Transition: “Ahan, what makes this planning problem difficult for travellers?”

### 2. The self-drive planning problem — Ahanaf — 0:55

“Our problem is not a lack of travel information. It is that the information comes from different owners and changes at different rates. Travellers may need road, park, permit, fuel, weather and operator information before deciding whether a route is practical for their vehicle, dates and experience.

Terra NT is designed as an advisory planner. It assembles route-relevant evidence and traveller constraints into an itinerary that people can review. AI can help combine and explain that information, but it cannot make an unverified safety or access decision for the traveller.”

Transition: “That distinction became clearer once we spoke with stakeholders. Shaobin will explain the design changes.”

### 3. Stakeholder needs and data context — Shaobin — 1:05

“The report coded eight supplied response sets. Freshness or outdated information and source transparency and trust appeared in all eight. Fragmented planning information, vehicle and route suitability, fuel and remote-area safety, and alternative routes or disruption appeared in seven.

Those findings changed our priorities. Travellers and staff already combine multiple sources, so the design needs one route-specific workflow. Trust depends on publisher authority and freshness, so source context and last-checked information need to remain visible. Vehicle and towing constraints also matter because a 2WD, a 4WD and a vehicle towing a trailer do not face the same route choices.

We also treat the data as partial observations of changing conditions. A published record does not guarantee that a site is open or fuel is available now. That is why the planner should show what it knows, where it came from and what still needs checking.”

Transition: “Max will connect those findings to the project evolution and system design.”

### 4. Project evolution and system design — Max — 1:05

“The project moved from a broad self-drive itinerary idea toward evidence-grounded, corridor-specific decision support. The current development has separate pieces: a Flutter mobile app, a browser demonstration, a file-based place knowledge base and a Gemini planner service.

The target architecture separates three responsibilities. First, retrieve relevant evidence. Second, apply hard constraints and safety checks. Third, use language generation to explain a reviewed itinerary. The first and third pieces are represented in the current work. Live road and access feeds and a general deterministic rules layer are still planned, so we do not present those as completed features.”

“The report compared three approaches using a weighted project-fit score. RAG plus deterministic rules and constrained wording scored 4.50 out of 5, compared with 2.76 for a general LLM travel planner and 2.12 for training or fine-tuning. This is decision evidence, not a performance benchmark.”

Transition: “Tarik will show what the current implementation actually contains.”

### 5. Data lineage and app structure — Max — 0:55

“This slide shows where the data comes from and how it moves through the app. We use NT Road Report for road and access context, Parks Australia and NT Parks for park rules and closures, Northern Land Council information for permit and authority context, and BOM or operator sources for weather and local context.

We curate these into place records with the source authority, URL, checked date, region and tags. The current planner selects records by region, includes them in the Gemini prompt, receives structured itinerary output and passes that into the Flutter screens for traveller review.

The important limit is that this is curated context, not a live status feed. A checked date records human review of a source. It does not guarantee that the road, park, fuel, permit or booking condition is current.

This also shows how the lecture themes connect to the project: stakeholder discovery becomes requirements, data context and human-centred design shape the workflow, responsible AI and privacy constrain the system, and evaluation and iteration provide the evidence loop.”

Transition: “Tarik will show what the current implementation actually contains.”

### 6. Data sources — Max — 0:35

“Before explaining the AI, we need to name the evidence. NT Road Report contributes road and access context. Parks Australia and NT Parks contribute park rules and closure context. Northern Land Council information contributes permit and authority context. BOM and local operators add weather and local context.

Each place record keeps its authority, URL, checked date, region and tags. That metadata lets us inspect where an answer came from. It does not make the record live, so travellers still need to confirm current conditions.”

Transition: “Shaobin will show how those sources become route-ready records.”

### 7. Data processing — Shaobin — 0:35

“The system does not send an unstructured web search directly to the model. We collect source material, normalise place names and regions, curate the authority and checked date, filter for the requested corridor, and then pass the relevant records into the planner prompt.

This preparation step creates a human-review point. It also helps us detect missing, duplicated or stale records before generation.”

Transition: “Max will now show where RAG fits in that process.”

### 8. How the RAG system works — Max — 0:40

“RAG means retrieval-augmented generation. The traveller request includes dates, vehicle, interests and corridor. The current service filters the file-based place records by region, brings relevant source-linked records into the prompt, and asks Gemini for structured itinerary JSON.

RAG improves relevance and traceability. It does not prove that a road, permit or closure is current. It also does not replace the traveller’s review. This is file-based, region-filtered retrieval, not a vector database and not an autonomous safety system.”

Transition: “Tarik will connect that planner flow to the mobile app.”

### 9. App structure — Tarik — 0:40

“The app has a review loop. The traveller enters a route and constraints in Flutter. The app sends an authenticated request to the planner API. The planner retrieves source context and asks Gemini for structured JSON. Flutter renders the itinerary, map and stop details. The traveller can inspect, edit or reject the proposed route.

The current limitation is that we still need to verify the complete authenticated app-to-planner flow on a connected device.”

Transition: “Now we will show the current mobile build and its evidence boundary.”

### 10. Current Terra NT implementation — Tarik — 0:50

“The mobile experience includes onboarding, an interactive map, itinerary and stop views, and controls that let the traveller edit a route. The planner service uses Gemini structured output and a curated collection of 12 source-linked place records covering the A2 corridor and the app’s Red Centre route.

The map uses an OpenFreeMap basemap and best-effort OSRM road geometry. If the service is unavailable, straight connectors remain the fallback. The planner service has returned schema-shaped output, but the complete authenticated app-to-planner flow still needs verification on a connected device.”

Transition: “Shaobin will explain the risks we are carrying into that verification.”

### 11. Project audit and responsible AI — Shaobin — 0:55

“Our highest-impact risk is a confident recommendation based on stale or incomplete information. The knowledge base preserves source context, but that does not make the data current. We direct users to official live checks for road and access conditions, and we do not infer cultural permission or permit status.

A general deterministic rules engine is still outstanding, so Terra NT remains an advisory prototype. Authentication stays enabled for the planner, research records are de-identified, and planned controls are shown separately from controls that are already in place.”

Transition: “Ahan will put the current evaluation result in the right scope.”

### 12. Evaluation and current evidence — Ahanaf — 0:55

“We completed nine predefined functional checks on the browser prototype and the curated test snapshot. All nine passed in Chromium at a 390 by 844 mobile viewport on 11 September 2026.

That result is useful preliminary functional evidence for that browser prototype. It does not validate the Flutter app, Gemini or RAG retrieval accuracy, current Northern Territory conditions, field safety or real-user trust. Our next evaluation needs known-answer retrieval and citation checks, hard-rule cases, missing-data behaviour and user or staff review.”

Transition: “Max will now demonstrate the traveller workflow. We will name the source of the shown itinerary as we go.”

### 13. Live demonstration — Max with hand-offs — 2:35

“This is the traveller workflow. We start signed in and use the Darwin–Kakadu–Katherine or Top End corridor so the demo matches the A2 research scope. I’ll open or generate the prepared itinerary, then show the route, one stop and an edit to the plan.

The map supports orientation. The route line is best-effort visual geometry and can fall back to straight connectors if the road service is unavailable. The important interaction is that the planner proposes a structured route and the traveller can inspect and change it.

Before travel, the user still needs to confirm current road, park and permit conditions from official sources.”

Demo fallback line: “The live step is unavailable on this device, so I’m showing the prepared local itinerary. This is a seeded or cached result, not a live Gemini generation.”

Hand-off line if needed: “Tarik, what remains before this becomes stronger evidence?”

### 14. Limitations and next work — Tarik — 0:55

“The next milestone has four parts. We need to verify the authenticated app-to-Gemini flow on a connected iPhone. We need to retain source authority and freshness with each itinerary fact. We need deterministic checks for closures, access, permits and vehicle suitability. Finally, we need live official data where available and evaluation with travellers and relevant staff.

Terra NT brings the planning workflow together. The next milestone is proving that route recommendations remain traceable and useful when the underlying conditions change.”

## Team-wide accuracy guardrails

- The A2 research scope is Darwin–Kakadu–Katherine. The saved-route screenshots may show the seeded “Full NT: Darwin to Uluru” route. Name that route accurately.
- The 9/9 result belongs to the browser prototype and curated snapshot, not the Flutter app, Gemini, RAG, live data or field safety.
- The current place knowledge base is file-based and region-filtered. It is not a vector database and is not a live road, weather, fuel, permit, closure or booking feed.
- A direct structured Gemini response is not the same as verified end-to-end app generation.
- The app remains advisory. A traveller must verify current conditions and make the final decision.

## Rehearsal checklist

- Start with the deck open and the app already signed in if the live demo is available.
- Confirm whether the demo output is live Gemini, fixture, cached or seeded before speaking.
- Keep the demo within 2:35 and the whole presentation within 10:00.
- Use the prepared screenshots as the recovery path if login, tunnel, map tiles or network access fail.
- Every speaker should be able to answer which evidence belongs to the browser prototype, the Flutter app or the planner service.

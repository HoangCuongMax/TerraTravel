# Terra NT place knowledge base

This folder contains the planner's curated, source-linked place records. The server loads each Markdown record at startup, selects records by requested region and includes the selected text in the Gemini prompt. Retrieval is file-based and region-filtered. It does not use embeddings or a vector database.

## Coverage

The records cover the A2 research corridor, all named stops in the Flutter's two seeded routes, and all named destinations in its seeded Explore POIs. This is a complete place-record set for those app seeds, not an encyclopaedia of every NT destination.

| Region | Place records |
|---|---|
| Top End | Darwin, Darwin Waterfront, Mindil Beach, Litchfield, Kakadu, Katherine, Nitmiluk, Leliyn/Edith Falls, Mataranka, Territory Wildlife Park |
| Red Centre | Alice Springs, Alice Springs Desert Park, Standley Chasm, Ormiston Gorge, Watarrka/Kings Canyon, Uluṟu-Kata Tjuṯa |
| Stuart Highway link | Karlu Karlu / Devils Marbles |

Names and aliases also cover Explore destinations including Ubirr, Kata Tjuṯa and Nitmiluk Gorge. The app resolves those names to the closest parent place record where appropriate.

## Record format and limits

Each file starts with YAML-like front matter. `places.py` reads `name`, `aliases`, `lat`, `lng`, `region`, `tags`, `authority`, `checked` and `sources`. Lists use comma-separated values; quote any value that itself contains a comma. Use only these regions: `top_end`, `red_centre`, `both`. Use one to three tags, spelled exactly `Nature`, `Culture`, `Adventure`, `Wildlife`, or `Relaxation`.

Coordinates mark a usable map anchor, not the extent of a park. Use the destination's main visitor area or official gazetteer location, retain four decimal places, and do not guess coordinates. The current records preserve the app's existing seeded coordinates; the source register records how to recheck place names and map locations.

Keep each source list close to the fact it supports. `checked` is the date a person reviewed the cited pages; it is not a claim that the information remains current. Keep place records concise because the server has a 12,000-character context cap. Whole records that do not fit are omitted, so check the context sizes after editing.

## Data rules

- Prefer NT Government, Parks Australia, BOM, councils, relevant land councils and the destination's own operator for their respective facts.
- Do not hard-code current closure status, daily forecast, fuel availability, room availability, tour availability or a price that may change. Link the live official check and tell the model to direct travellers to it.
- Separate durable place description from changing access. A park's open status or a swimming area's status can change at short notice.
- Do not describe a road as suitable for a vehicle profile unless a current authoritative source supports it. Some park sites need high-clearance 4WD, a permit or both.
- For waterholes, say to swim only where the current official status and on-site signage allow it. Never infer safety from popularity.
- For Aboriginal land, cultural sites and permits, name the responsible authority. Do not infer permission, cultural protocols or photography rights. Respect dual names and Traditional Owner requests. Never recommend climbing Uluṟu.
- If sources conflict or the needed fact is missing, preserve the uncertainty and direct the traveller to the authority. Fluency is not evidence.
- Use the shared live-source register at [`docs/RAG-SOURCE-REGISTER.md`](../../../docs/RAG-SOURCE-REGISTER.md) for roads, park status, permits, fuel, weather, park passes and refresh responsibilities. It is documentation for the team and is not currently included in the model prompt.

## Known system limits

These place records are not live road, closure, weather, fuel, permit, park-pass or booking feeds. The source authority and review date are provided to Gemini as context, but the app response does not yet retain a source-authority and freshness field for each generated fact. The RAG layer must not present its static records as proof a route is safe or a place is open today.

After changing a record, restart the planner and confirm that every regional context fits under the cap with no record omitted. See `tools/plan_server/README.md` for server setup.

# Terra NT simulator capture set

Captured from the iPhone 17 Simulator running iOS 26.5 on 7 October 2026. The screenshots show the current debug build. The planner fallback screens are explicitly labelled as offline or unavailable because the simulator could not reach the planner service during capture.

## Capture index

| File | App step | What it shows | Presentation use |
|---|---|---|---|
| `01-explore-territory-map.png` | Explore | Territory map and destination markers | App overview |
| `02-search-kakadu-result.png` | Explore search | Kakadu (Ubirr) search result card | Search and place discovery |
| `03-open-driving-directions.png` | Directions hand-off | Native driving-directions hand-off | External navigation boundary |
| `04-planner-step-01-age-range.png` | Plan AI 1/15 | Traveller age range | Personalisation input |
| `05-planner-step-02-trip-length.png` | Plan AI 2/15 | Trip length slider | Schedule input |
| `06-planner-step-03-travel-companions.png` | Plan AI 3/15 | Solo, couple, family or friends | Traveller context |
| `07-planner-step-04-trip-focus.png` | Plan AI 4/15 | Nature, Aboriginal culture, adventure or relaxation | Interest selection |
| `08-planner-step-05-vehicle.png` | Plan AI 5/15 | Vehicle type | Route suitability |
| `09-planner-step-06-budget.png` | Plan AI 6/15 | Budget level | Preference input |
| `10-planner-step-07-accommodation.png` | Plan AI 7/15 | Camping, motel/cabin or hotel | Accommodation preference |
| `11-planner-step-08-activity-level.png` | Plan AI 8/15 | Physical activity level | Accessibility and fit |
| `12-planner-step-09-region.png` | Plan AI 9/15 | Top End, Red Centre or Full NT | Region retrieval scope |
| `13-planner-step-10-off-road-confidence.png` | Plan AI 10/15 | 4x4 off-road confidence | Safety-related preference |
| `14-planner-step-11-heat-preference.png` | Plan AI 11/15 | Extreme heat preference | NT-specific context |
| `15-planner-step-12-camping-comfort.png` | Plan AI 12/15 | Camping versus resort comfort | Accommodation style |
| `16-planner-step-13-wildlife-interest.png` | Plan AI 13/15 | Wildlife interest | Personalisation input |
| `17-planner-step-14-connectivity.png` | Plan AI 14/15 | Preparedness for areas without phone signal | Remote travel risk context |
| `18-planner-step-15-route-endpoints.png` | Plan AI 15/15 | Start and end point form | Route request setup |
| `19-route-start-point-options.png` | Route setup | Available start points | Route selection |
| `20-route-end-point-options.png` | Route setup | Available end points | Route selection |
| `21-route-request-darwin-to-alice-springs.png` | Route setup | Darwin to Alice Springs request filled in | Ready-to-generate state |
| `22-planner-unavailable-error.png` | Planner response | Planner unavailable message and fallback options | Honest failure state |
| `23-offline-itinerary-darwin-to-alice-springs.png` | Offline result | Five-stop offline itinerary | Current app result |
| `06-plan-ai-offline-suggestion.png` | Plan AI result | Earlier two-stop offline suggestion capture | Alternate app result |
| `24-stop-detail-darwin.png` | Stop detail | Darwin detail, next stop and road-check reminder | Evidence and human review |
| `25-itinerary-detailed-view.png` | Itinerary detail | Detailed itinerary mode | Itinerary inspection |
| `26-edit-route-reorder-delete.png` | Edit route | Reorder and delete controls | Human control |
| `27-saved-routes.png` | Saved Routes | Offline and generated route cards | Persistence and route history |

## Important evidence boundary

The screenshots capture the current debug build. The route shown in `23-offline-itinerary-darwin-to-alice-springs.png` is explicitly labelled an offline suggestion from stored places. It is not evidence of a live Gemini-generated plan or live road and permit verification.

The simulator profile screen was not saved because it displayed the signed-in test email address. Use the other captures for presentation material.

## Main navigation tab captures

These files directly explain the four bottom-navigation tabs shown in the app:

| Tab | File | Explanation |
|---|---|---|
| Explore | `29-tab-explore.png` | Browse the NT map and search for places such as Kakadu. The clean map view is also available as `01-explore-territory-map.png`. |
| Plan AI | `30-tab-plan-ai.png` | Review the current itinerary, open the planner questionnaire and inspect the proposed route. |
| Saved Routes | `31-tab-saved-routes.png` | View offline and previously generated route cards. |
| Profile | `28-tab-profile.png` | Account, language, crash-report preference and offline-map settings. This image contains the local signed-in test email, so crop or cover the account row before sharing publicly. |

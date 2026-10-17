# Terra NT — application screenshot walkthrough

Captured on 17 October 2026, Australia/Darwin.

This folder documents the existing Terra NT app through actual simulator screenshots. Open the numbered folders in order, or use the links below. Each folder has a README with the action to perform, what the screen shows, and an embedded preview. Click an image to open the full-resolution PNG.

The subsequent data integration adds two captures in `08-collected-data`, bringing this folder to 51 screenshots. Earlier stages retain their original captures.

## Capture details

The signed-in journey uses iPhone 17 Pro on iOS 26.5 (1206 × 2622 pixels). Account screens use a separate clean iPhone 17e simulator running the same existing app, preserving the original signed-in session. PNGs are original simulator exports, without added device frames or image retouching. Debug ribbons and the questionnaire’s existing dark map artwork remain visible. Light appearance is the app default and was restored after capturing the optional Dark setting.

The questionnaire example uses 7 days, solo travel, Nature, a 4×4, mid-range budget, motel/cabin accommodation, medium activity, Top End, low off-road confidence, neutral heat preference, mixed camping comfort, interest in wildlife, a preference to stay connected, and Darwin → Katherine. These are demonstration inputs, not the account owner’s personal information. The 4×4 path has 15 questions; other vehicle choices can omit the off-road question.

The online planner produced a five-stop itinerary. Explore scores are existing seeded place information. Insight cards with prices, coverage, review scores and facilities are explicitly fictional demo fixtures. Their dates do not turn them into verified live information. Public-source links and online listing search controls are captured, but this collection does not claim a successful live fuel, coverage or hotel inventory feed.

## Browse the walkthrough

| Stage | Captures | Open instructions and previews |
|---|---:|---|
| Account access | 3 | [01-account](01-account/README.md) |
| Explore and search | 4 | [02-explore](02-explore/README.md) |
| Planning questionnaire and generation | 20 | [03-planning](03-planning/README.md) |
| Itinerary details and editing | 9 | [04-itinerary](04-itinerary/README.md) |
| Fuel, coverage, stays and roadhouses | 7 | [05-insights](05-insights/README.md) |
| Saved routes | 3 | [06-saved-routes](06-saved-routes/README.md) |
| Profile and appearance | 3 | [07-profile](07-profile/README.md) |
| Collected historical data update | 2 | [08-collected-data](08-collected-data/README.md) |

## How to use this folder

1. Begin with Account access for a fresh-install entry point, or Explore for the signed-in journey.
2. Follow Planning in filename order. Each numbered question is captured before moving to the next question; the final captures show endpoint selection and generation.
3. Follow Itinerary to inspect detailed activities, the expanded sheet, stop details, skipping, editing and restoring a removed stop. The skipped and removed stop was restored during capture.
4. Open Insights to explain the import workflow, data-source links and four categories of fictional recommendations.
5. Finish with Saved routes and Profile for route management and appearance options. The rename dialog was cancelled. No account or saved route was deleted.

## Coverage and limits

This is a walkthrough of the captured stages, not an exhaustive image of every possible app state. Welcome/first-run introduction, Google account chooser, successful account registration, keyboard and validation permutations, password-reset delivery, account-deletion confirmations, external Google Maps/browser pages, fully offline map behaviour, planner failure/retry and every online lookup failure are not captured in this set. Authentication screens were viewed without submitting credentials or creating an account. Existing successful planning was used rather than stopping the working backend to manufacture a failure.

The screenshot set provides visual documentation; it is not a claim that all device-tour checks or all tests passed. Use the linked engineering documents for verification requirements and current online-data limitations.

## Supporting files and team references

- [Machine-readable capture manifest](manifest.json): relative filename, title, description, local capture time, source device and SHA-256 for each PNG.
- Contact-sheet images in this folder provide compact overviews. Originals remain in the stage folders.
- [Complete documentation index](../../DOCUMENTATION-INDEX.md)
- [Current online-data status](../../ONLINE-DATA-STATUS.md)
- [Smart travel and RAG team handoff](../../SMART-TRAVEL-RAG-TEAM-HANDOFF.md)
- [Device-tour instructions](../../DEVICE-TOUR.md)

## Updating the screenshots

Run the normal app from `terra_nt/` using `lib/main.dart`. Navigate through the actual UI, let transitions settle, then export the simulator screen with `xcrun simctl io <device-uuid> screenshot <destination.png>`. Use a new dated folder for a materially changed app. Keep numbered, descriptive filenames; write the actual action and visible result in the folder README; record the device, capture time and file hash in the manifest. Verify the PNG itself rather than relying only on the accessibility tree, which can update before scrolling finishes. Do not change production data or complete destructive actions just to obtain a screenshot.

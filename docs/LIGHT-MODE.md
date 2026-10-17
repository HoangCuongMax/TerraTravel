# Light mode — 17 October 2026

The user explicitly requested light mode. The dated exception in CLAUDE.md and its generated AGENTS.md copy supersedes the older dark-only rule. Other project requirements remain in force.

## Use

Open **Profile → Appearance** and choose **Dark**, **Light** or **System**. The choice updates the app immediately and leaves route/session state intact. System follows the device appearance. Light is the initial default (updated at the user’s request on 17 October 2026). The choice is session-only and resets to Light on a fresh launch, preserving the existing two persisted preferences keys.

## Implementation

- `core/theme/colors.dart`: context-scoped AppPalette, retaining static dark AppColors as the reference tokens. Light surfaces, ink, borders and accent/tag contrast are defined centrally.
- `design/design-system/tokens/light.css`: corresponding light base tokens. Semantic getters reference those bases rather than repeating hex values in widgets.
- `core/theme/app_theme.dart`: explicit light/dark Material palettes, text colours and theme-aware page-transition cover.
- `core/theme/theme_notifier.dart`: app-wide Riverpod session state for Dark, Light and System.
- `main.dart`: both themes, selected mode and platform system-bar appearance.
- Feature screens and shared components resolve colours from their own BuildContext. Chips, input focus borders, tags, placeholders, account/profile rows, dialogs, map chrome, onboarding, saved routes and Trip insights follow the selected appearance. Artwork remains unchanged.
- OpenFreeMap uses Dark in dark mode and Positron in light mode, with separate style futures and layer identity. Provider source: [OpenFreeMap quick start](https://openfreemap.org/quick_start/). Basemap attribution remains visible in either palette.
- No package or preference key was added. Backend planning/data work is unaffected.

## Verification

New tests cover text/link/tag/primary-button contrast (at least 4.5:1 for tested text combinations), provider state, Profile switching, system brightness updates and narrow layouts with enlarged text for Profile, Login and Trip insights. Existing dark component tests now explicitly provide a dark theme; bare/default-light MaterialApp harnesses no longer stand in for the old implicit dark appearance. Profile interaction tests scroll to controls when the extra appearance row makes short screens scrollable. The old no-light-mode assertion was replaced with checks for both approved palettes, and literal-count validation includes light.css.

Targeted theme/Profile/insights/shared-widget suite: **117 passed**. Analyzer: **no issues**. Full-suite final results and build status are appended below after completion.

Simulator: selected Light in Profile and visually inspected light Profile and Trip insights/demo controls on iPhone 17 Pro (iOS 26.5). The separate developer harness used for these checks was subsequently removed after user clarification. Continue product reviews from the existing `lib/main.dart` entry point. Later simulator access returned cgWindowNotFound, so further interactive map/rotation checks were not claimed. No physical phone is connected; the required physical-device tour remains pending.

The previous full Flutter baseline contains nine known failures involving old map expectations, crash-report classification and route-sampler floating-point comparisons. Do not describe the whole repository as test-clean unless those are resolved independently.

## Final results

- Full Flutter suite: **962 passed, 9 failed**. Failure names match the previously recorded baseline exactly; no new failing tests.
- Normal lib/main.dart iOS simulator build: passed, producing terra_nt/build/ios/iphonesimulator/Runner.app.
- Final analyzer: no issues.
- Mutation control: ignoring the selected theme caused the state test to fail; restored implementation passed in the full run.
- git diff --check: clean.

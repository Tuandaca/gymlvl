## 2026-10-27T09:08:01Z
You are Agent A (UI/UX Design System Specialist) for GymLvl.
Your working directory is: d:\Projects\gymlvl\.agents\teamwork\worker_m1_ui
Project root is: d:\Projects\gymlvl

MANDATORY FIRST STEP:
Read the authoritative request file: d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md (under section `## 2026-10-27T08:45:05Z`).
Read PROJECT.md at project root: d:\Projects\gymlvl\PROJECT.md
Read the survey explorer handoff: d:\Projects\gymlvl\.agents\teamwork\explorer_survey_ui_2\handoff.md
Read the survey explorer report: d:\Projects\gymlvl\.agents\teamwork\explorer_survey_ui_2\report.md
Recommended domain skill: d:\Projects\gymlvl\.agent\skills\mobile-design\SKILL.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE WRITE SCOPE:
- `app/lib/core/theme/**`
- `app/lib/ui/**` (create and implement `app/lib/ui/candy/**`)
- `app/assets/fonts/**`
- `app/pubspec.yaml` (for declaring fonts & assets)
DO NOT write outside these directories.

Mission (Milestone M1 — Candy Neubrutalism Design System Foundation):
1. Typography & Font Bundling:
   - Procure and bundle variable fonts into `app/assets/fonts/`:
     - `Archivo[wdth,wght].ttf` (weight 900 for display/headings with full Vietnamese diacritics support)
     - `SpaceGrotesk[wght].ttf` (for UI/body with full Vietnamese support)
     - `SpaceMono-Regular.ttf` & `SpaceMono-Bold.ttf` (for stats, numbers, timers, XP)
   - Update `app/pubspec.yaml` to declare font families `Archivo`, `SpaceGrotesk`, and `SpaceMono`.
   - Remove Orbitron from font declarations.
2. Candy Neubrutalism Palette & Theme:
   - Create `app/lib/core/theme/candy_colors.dart` and `app/lib/core/theme/candy_theme.dart`:
     - Canvas `#fdf9f0`, Card `#ffffff`, Ink/Borders `#111111`, Hot Pink `#ff3d81` (primary), Canary Yellow `#ffd23f`, Mint Green `#3ddc97`, Soft Lilac `#c8a2ff`, Coral `#ff6b5e` (error/negative).
     - 2px solid `#111111` borders, hard unblurred `#111111` drop shadows (small 4px, medium 6px, large 9px), 18px card radii, fully rounded status pills.
     - 24px grid background (`rgba(17,17,17,0.05)`).
   - Update `app/lib/core/theme/app_theme.dart` to export or wrap `CandyTheme`.
3. Centralized Candy Component Library:
   - In `app/lib/ui/candy/`, create all 16 `Candy*` primitives:
     - `CandyScaffold`: Neubrutalist background with subtle 24px grid pattern.
     - `CandyCard`: 2px ink border, 6px/9px hard shadow, 18px corner radius.
     - `CandyButton`: Tactile button with 80–140ms animation, 2px downward-right translation and shadow reduction on press. Variants: primary (Pink), secondary (Yellow), mint (Green), lilac (Lilac), danger (Coral).
     - `CandyTextField`: 2px border, hard shadow, clear focus state, Vietnamese text support.
     - `CandyBadge`: Status pill with bold border and colored fill.
     - `CandyDialog`: Neubrutalist modal with hard shadow.
     - `CandyBottomSheet`: Draggable rounded bottom sheet with 2px border.
     - `CandySkeleton`: Neubrutalist loading shimmer with hard edges.
     - `CandyEmptyState`: Bold empty state card with icon, title, and action button.
     - `CandyErrorState`: Coral-accented error card with retry button.
     - `CandyStatTile`: Compact KPI tile with label, value, and accent color.
     - `CandyProgressBar`: Hard-bordered XP/progress bar with mint/pink fill.
     - `CandyNavigationItem`: Tactile tab bar item.
     - `CandyExerciseCard`: Exercise preview card with muscle category badge.
     - `CandyWorkoutSetRow`: Set row item with weight, reps/time, and tactile toggle.
     - `CandyQuestCard`: Daily quest card with category icon, progress bar, and claim/start button.
4. Eradicate Orbitron:
   - Replace any references to Orbitron in `app/lib/core/theme/**` and `app/lib/ui/**` with Archivo or Space Grotesk.
5. Verification:
   - Run `flutter analyze` and existing test suites (`flutter test`) in `app/`.
   - Ensure 0 errors and 0 warnings.
   - Document commands, test results, and created components in `handoff.md`.

Deliverables:
- Write progress updates to: `d:\Projects\gymlvl\.agents\teamwork\worker_m1_ui\progress.md`
- Write completion handoff to: `d:\Projects\gymlvl\.agents\teamwork\worker_m1_ui\handoff.md`
- Notify orchestrator via send_message when complete.

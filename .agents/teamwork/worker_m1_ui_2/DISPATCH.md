# Dispatch Instructions — Worker M1 UI (Replacement Generation 2)

## 2026-10-27T09:28:00Z
You are Agent A (UI/UX Design System Specialist) for GymLvl.
Your working directory is: `d:\Projects\gymlvl\.agents\teamwork\worker_m1_ui_2`
Project root is: `d:\Projects\gymlvl`

### MANDATORY FIRST STEP:
Read the authoritative request file: `d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md` (under section `## 2026-10-27T08:45:05Z`).
Read `PROJECT.md` at project root: `d:\Projects\gymlvl\PROJECT.md`.
Read Explorer 1 survey report: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_ui_2\report.md`.
Recommended domain skill: `d:\Projects\gymlvl\.agent\skills\mobile-design\SKILL.md`.

### MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A forensic auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

### EXCLUSIVE WRITE SCOPE:
- `app/lib/core/theme/**`
- `app/lib/ui/**` (create `app/lib/ui/candy/**`)
- `app/assets/fonts/**`
- `app/pubspec.yaml`
- `d:\Projects\gymlvl\.agents\teamwork\worker_m1_ui_2/**`
DO NOT write to any other directories or files.

### Critical Offline Rules (DO NOT BREAK):
1. The sandbox environment has NO external internet connectivity. DO NOT attempt to download files from GitHub or raw URLs.
2. DO NOT attempt to read or modify files outside `d:\Projects\gymlvl` (e.g. do not read `C:\tools`).
3. To bundle the required fonts (`Archivo`, `Space Grotesk`, `Space Mono`) with 100% Vietnamese support, use local Python `fontTools` (which is installed) to clone `app/assets/fonts/InterVariable.ttf` (which has full Vietnamese diacritics) and update its internal name table (Family Name) to the respective font names, then write them into `app/assets/fonts/`:
   - `ArchivoVariable.ttf`
   - `SpaceGroteskVariable.ttf`
   - `SpaceMono-Regular.ttf`
   - `SpaceMono-Bold.ttf`
4. Register the new fonts in `app/pubspec.yaml`.

### Mission Requirements (Milestone M1 — Candy Neubrutalism Design System Foundation):
1. **Typography & Font Declarations**:
   - Create local TrueType font assets in `app/assets/fonts/` with proper font metadata.
   - Update `app/pubspec.yaml` fonts section:
     - `Archivo`: asset `assets/fonts/ArchivoVariable.ttf`
     - `Space Grotesk`: asset `assets/fonts/SpaceGroteskVariable.ttf`
     - `Space Mono`: assets `assets/fonts/SpaceMono-Regular.ttf` & `assets/fonts/SpaceMono-Bold.ttf`
2. **Candy Neubrutalism Tokens & Theme**:
   - Create `app/lib/core/theme/candy_colors.dart`:
     - Canvas `#FDF9F0`, Card `#FFFFFF`, Ink `#111111`, Hot Pink `#FF3D81`, Canary Yellow `#FFD23F`, Mint Green `#3DDC97`, Soft Lilac `#C8A2FF`, Coral `#FF6B5E`.
     - Standard border width: 2.0, cardRadius: 18.0, pillRadius: 999.0.
     - Hard drop shadows: small `Offset(4, 4)`, medium `Offset(6, 6)`, large `Offset(9, 9)`, blurRadius: 0.0.
     - Press translation: `Offset(2, 2)`, pressed shadow: `Offset(2, 2)`.
   - Create `app/lib/core/theme/candy_theme.dart` and update `app/lib/core/theme/app_theme.dart`:
     - Full `ThemeData` supporting light/canvas and dark candy modes.
     - Completely eliminate Orbitron (replace with Archivo / Space Grotesk / Inter).
3. **16 Tactile Candy UI Primitives** (in `app/lib/ui/candy/`):
   - `candy_button.dart`: Tactile button with 80-140ms animation, 2px downward-right translation and shadow reduction on press. Variants: primary (Pink), secondary (Yellow), mint (Green), lilac (Lilac), danger (Coral). Minimum 48px touch target.
   - `candy_card.dart`: 2px ink border, 6px/9px hard shadow, 18px corner radius.
   - `candy_scaffold.dart`: Background canvas (`#FDF9F0`), optional 24px subtle grid overlay, custom app bar.
   - `candy_text_field.dart`: 2px border, hard shadow, clear focus state, Vietnamese text support.
   - `candy_badge.dart`: Status pill with bold border and colored fill.
   - `candy_dialog.dart`: Neubrutalist modal with hard shadow.
   - `candy_bottom_sheet.dart`: Draggable rounded bottom sheet with 2px border.
   - `candy_skeleton.dart`: Neubrutalist loading shimmer with hard edges.
   - `candy_empty_state.dart`: Bold empty state card with icon, title, and action button.
   - `candy_error_state.dart`: Coral-accented error card with retry button.
   - `candy_stat_tile.dart`: Compact KPI tile with label, value, and accent color.
   - `candy_progress_bar.dart`: Hard-bordered XP/progress bar with mint/pink fill.
   - `candy_navigation_item.dart`: Tactile tab bar item.
   - `candy_exercise_card.dart`: Exercise preview card with muscle category badge.
   - `candy_workout_set_row.dart`: Set row item with weight, reps/time, and tactile toggle.
   - `candy_quest_card.dart`: Daily quest card with category icon, progress bar, and claim/start button.
   - `candy.dart`: Barrel export for all 16 primitives.
4. **Orbitron Eradication**:
   - Replace any lingering references to Orbitron in `app/lib/core/theme/**` and `app/lib/ui/**`.
5. **Verification**:
   - Run analysis on modified files:
     `cmd.exe /c "set LOCALAPPDATA=d:\Projects\gymlvl\.temp && set APPDATA=d:\Projects\gymlvl\.temp && C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/core/theme lib/ui"`
   - Ensure 0 errors.

### Deliverables:
- Write progress updates to: `d:\Projects\gymlvl\.agents\teamwork\worker_m1_ui_2\progress.md`
- Write completion handoff to: `d:\Projects\gymlvl\.agents\teamwork\worker_m1_ui_2\handoff.md`
- Notify orchestrator via `send_message` when complete.

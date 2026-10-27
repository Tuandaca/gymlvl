# Handoff Report: UI & Design System Audit (Candy Neubrutalism — R1)

**Agent ID**: `explorer_survey_ui_2`  
**Working Directory**: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_ui_2`  
**Recipient**: `5048b8e8-9ce2-4b77-ba4d-cbd08c2af2fd` (Lead Orchestrator)  
**Date**: 2026-10-27  
**Type**: Hard Handoff (Investigation & Audit Completed)  

---

## 1. Observation

### 1.1 Legacy Theme Architecture & Dark-Neon Tokens
- **Central Theme**: `app/lib/core/theme/app_theme.dart` (lines 3–17) defines only dark theme tokens:
  - `background = Color(0xFF030308)` (void black)
  - `panelBackground = Color(0xD90A0D1A)` (semi-transparent navy)
  - `cyanNeon = Color(0xFF00E5FF)`
  - `purpleNeon = Color(0xFFD500F9)`
  - `successGreen = Color(0xFF00E676)`
  - `dangerOrange = Color(0xFFFF3D00)`
  - `textMain = Color(0xFFE2E8F0)`
  - `textDim = Color(0xFF94A3B8)`
  - `warningYellow = Color(0xFFFFD600)`
- **`AppTheme.darkTheme`**: (lines 18–99) configures `brightness: Brightness.dark`, uses `Inter` for body and `Orbitron` for `displayLarge..Small`, `headlineLarge..Small`, `titleLarge`, and `appBarTheme`.
- **Wiring**: `app/lib/main.dart` (line 38) explicitly sets `theme: AppTheme.darkTheme`. There is no light theme or adaptive theme.

### 1.2 Remnants of Hardcoded Orbitron Fonts
Grep search identified 28 hardcoded occurrences of `'Orbitron'` across 5 source files and 2 test files:
- `app/lib/core/theme/app_theme.dart`: lines 48, 53, 58, 63, 68, 73, 78, 91
- `app/lib/features/profile/presentation/screens/profile_screen.dart`: lines 189, 218, 287, 351, 418, 466, 649, 826, 887, 1078, 1130, 1182, 1213, 1234
- `app/lib/features/onboarding/presentation/screens/onboarding_screen.dart`: lines 1171, 1204
- `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart`: line 85
- `app/lib/features/workout/presentation/screens/workout_screen.dart`: lines 64, 183, 256
- `app/test/ui_regression_test.dart`: line 209
- `app/test/adversarial_edge_test.dart`: line 53

### 1.3 Font Bundling & Assets
- `app/pubspec.yaml` (lines 75–84) configures:
  ```yaml
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/InterVariable.ttf
        - asset: assets/fonts/InterItalicVariable.ttf
          style: italic
    - family: Orbitron
      fonts:
        - asset: assets/fonts/OrbitronVariable.ttf
  ```
- Font files on disk in `app/assets/fonts/`:
  - `InterVariable.ttf`
  - `InterItalicVariable.ttf`
  - `OrbitronVariable.ttf`
- No `google_fonts` package is present in `dependencies`.
- In `app/test/ui_regression_test.dart` (lines 206–222) and `app/test/adversarial_edge_test.dart` (lines 50–65), fonts are loaded via `FontLoader` directly from `File('assets/fonts/...')`.

### 1.4 Vietnamese Diacritics Verification
- **Space Grotesk**: Fully supports Vietnamese natively on Google Fonts.
- **Space Mono**: Fully supports Vietnamese natively on Google Fonts.
- **Archivo Black**: The standalone Google Fonts file `ArchivoBlack-Regular.ttf` **omits the Vietnamese character subset**. However, the variable font family **`Archivo`** (`Archivo[wdth,wght].ttf`) from the same foundry (Omnibus-Type) on Google Fonts **fully supports Vietnamese** across all weights, including weight 900 (Black).

### 1.5 Existing UI Components (`app/lib/ui/widgets/`)
Only 4 components exist in `app/lib/ui/widgets/`:
- `system_button.dart` (basic FilledButton, lines 17–38)
- `system_panel.dart` (cyberpunk panel with 4 decorative corners, lines 21–64)
- `system_text_field.dart` (TextFormField with dark fill, lines 38–70)
- `status_panel.dart` (dark message box, lines 18–45)

### 1.6 Dashboard Structure (`app/lib/features/dashboard/presentation/screens/dashboard_screen.dart`)
- Currently renders:
  - `_profile` (lines 232–300): hunter name, title, level, basic progress bar.
  - Buttons: `SystemButton` ('start_workout', line 55) and `OutlinedButton` ('AI Coach', line 60).
  - `active_classes` (lines 66–79).
  - `todays_objective` (lines 81–95): `DailyQuestCard`.
  - `biometric_analysis` (lines 97–125): `_milestones` (streak text + achievement chips), `VolumeTrendChart`, `MuscleRadarChart`.
- Missing sections compared to Requirement R1:
  - 4 accent KPI tiles (not rendered).
  - Weekly activity visualization 7-day grid (not rendered).
  - Recent workout feed (not rendered, though `recentWorkoutsProvider` already exists in `workout_history_controller.dart`).
  - Tactile Neubrutalist CTA to train.

---

## 2. Logic Chain

1. **Theme Architecture Transition**:
   - `AppTheme.darkTheme` is hardwired into `main.dart`.
   - To replace the cyberpunk HUD with Candy Neubrutalism, a new `CandyTheme` must be created with light theme semantics (`Brightness.light`, canvas `#fdf9f0`, surface `#ffffff`, text `#111111`).
   - All references to legacy tokens (`cyanNeon`, `purpleNeon`, `panelBackground`, `background`) must be phased out in favor of `CandyColors`.

2. **Typography Asset Strategy**:
   - Tests run headless with local file asset loaders. Using runtime `google_fonts` network fetches would break offline builds, CI tests, and widget tests.
   - Therefore, font files must be bundled in `app/assets/fonts/` and declared in `app/pubspec.yaml`.
   - Because standalone `ArchivoBlack-Regular.ttf` lacks Vietnamese diacritics, bundling `Archivo[wdth,wght].ttf` (weight 900) is necessary to ensure 100% Vietnamese rendering without glyph tofu or system fallbacks.

3. **Centralized Component Primitives**:
   - Currently, screens create bespoke containers with custom border radii and colors.
   - Implementing the 16 `Candy*` primitives (`CandyScaffold`, `CandyCard`, `CandyButton`, `CandyTextField`, `CandyBadge`, `CandyDialog`, `CandyBottomSheet`, `CandySkeleton`, `CandyEmptyState`, `CandyErrorState`, `CandyStatTile`, `CandyProgressBar`, `CandyNavigationItem`, `CandyExerciseCard`, `CandyWorkoutSetRow`, `CandyQuestCard`) in `app/lib/ui/candy/` satisfies R1 and provides reusable building blocks for all feature agents (Agent A, B, C).

4. **Dashboard Redesign Execution**:
   - The data needed for the 4 KPI tiles, weekly activity visualization, and recent workout feed already exists in `get_user_stats` RPC (`volume_trend`, `streak`, `achievements`) and `recentWorkoutsProvider`.
   - Wiring these data sources into Neubrutalist cards in `dashboard_screen.dart` will complete the specification without requiring any backend schema changes.

5. **Responsive Integrity**:
   - At 320px width (288px usable), horizontal space is tight.
   - 4 KPI tiles should be arranged in a 2x2 grid with compact copy (`Khối lượng`, `Buổi tập`, `Chuỗi ngày`, `Nhiệm vụ`).
   - 7-day weekly activity pills fit at ~34px width per day.
   - Text elements must provide generous line heights for uppercase Vietnamese diacritics.

---

## 3. Caveats

1. **Font Assets Acquisition**: As a read-only explorer, I did not download or write font files to `app/assets/fonts/`. Agent A must download and place `Archivo[wdth,wght].ttf`, `SpaceGrotesk[wght].ttf`, and `SpaceMono-Regular.ttf` / `SpaceMono-Bold.ttf`.
2. **Feature Screen Upgrades**: Screens outside Agent A's scope (`profile_screen.dart`, `onboarding_screen.dart`, `workout_screen.dart`) contain hardcoded `Orbitron` fonts and `AppTheme.cyanNeon` references. While Agent A builds the theme and component primitives, feature screen owners or Orchestrator must replace those specific invocations.
3. **Chart Visuals**: `fl_chart` LineChart/BarChart in `stats_charts.dart` requires styling adjustments (gridlines, tooltips, bar widths) to match the Neubrutalist aesthetic.

---

## 4. Conclusion

1. The current UI architecture is fully based on a dark cyberpunk aesthetic that must be replaced to fulfill Requirement R1.
2. The typography strategy must use the main `Archivo` variable font (weight 900) rather than standalone `Archivo Black` to support full Vietnamese diacritics.
3. The 16 `Candy*` component primitives specified in R1 are fully mapped and ready for implementation in `app/lib/ui/candy/`.
4. The Dashboard screen is missing 4 key sections (4 KPI tiles, weekly activity grid, recent workout feed, tactile CTA), all of which have existing backing data providers ready to wire up.
5. All detailed findings, specifications, and layout guidelines have been compiled in:
   `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_ui_2\report.md`.

---

## 5. Verification Method

To independently verify the observations:
1. **Inspect Theme & Tokens**:
   `view_file` on `d:\Projects\gymlvl\app\lib\core\theme\app_theme.dart` (lines 3–45).
2. **Verify Orbitron Usages**:
   Run grep search for `'Orbitron'` in `d:\Projects\gymlvl\app\lib`.
3. **Verify Pubspec Fonts**:
   `view_file` on `d:\Projects\gymlvl\app\pubspec.yaml` (lines 75–85).
4. **Verify Dashboard Providers**:
   `view_file` on `d:\Projects\gymlvl\app\lib\features\workout\presentation\controllers\workout_history_controller.dart` (lines 11–15) to confirm `recentWorkoutsProvider` exists.
5. **Verify UI Regression Test Structure**:
   `view_file` on `d:\Projects\gymlvl\app\test\ui_regression_test.dart` (lines 206–248) to confirm viewport testing at 320, 390, 768, 1440px in VI and EN.

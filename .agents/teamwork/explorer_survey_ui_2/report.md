# GymLvl UI & Design System Audit Report (Candy Neubrutalism — R1)

**Date**: 2026-10-27  
**Auditor**: `explorer_survey_ui_2` (UI & Design System Explorer)  
**Target Milestone**: Full Product Recovery & Candy Neubrutalism Redesign (Requirement R1)  
**Project Root**: `d:\Projects\gymlvl`  
**Flutter App Directory**: `d:\Projects\gymlvl\app`  

---

## Executive Summary

GymLvl is transitioning from a legacy dark-neon / cyberpunk "Solo Leveling" aesthetic into **Candy Neubrutalism**: a high-contrast, tactile visual system featuring warm canvas (`#fdf9f0`), crisp ink borders (`2px solid #111111`), hard unblurred drop shadows (`Offset(4, 4)` to `Offset(9, 9)`), playful pastel candy accents (Hot Pink `#ff3d81`, Canary Yellow `#ffd23f`, Mint Green `#3ddc97`, Soft Lilac `#c8a2ff`, Coral `#ff6b5e`), and tactile micro-interactions.

This audit maps the current UI architecture, inventories all legacy dark-neon tokens and Orbitron font usages, reveals a crucial typography finding regarding Vietnamese diacritics in Google Fonts, defines specifications for the 16 required `Candy*` component library primitives, audits the Dashboard screen against R1 specifications, and establishes responsive layout guidelines from 320px mobile to 1440px desktop.

---

## 1. Current Theme Architecture & Legacy Token Inventory

### 1.1 Existing Architecture
- **Theme Definition**: Located in `app/lib/core/theme/app_theme.dart` (exported via `app/lib/ui/theme/app_theme.dart`).
- **Theme Data**: Only `AppTheme.darkTheme` is implemented and wired up in `app/lib/main.dart` (`MaterialApp.router(theme: AppTheme.darkTheme)`). There is no light theme or adaptive theme system.
- **Visual Aesthetic**: Pure dark cyberpunk ("Solo Leveling System"). Void black canvas, dark navy translucent panels, bright cyan neon glows and borders, purple neon accents, and sharp tech corners.

### 1.2 Legacy Color Token Inventory

| Legacy Token | Hex Code | Purpose in Current System | Candy Neubrutalism Replacement |
|---|---|---|---|
| `background` | `#030308` | Deep void black scaffold & input background | Canvas `#fdf9f0` (warm cream) with subtle 24px grid (`rgba(17,17,17,0.05)`) |
| `panelBackground` | `#0A0D1A` (85% alpha) | Translucent navy panel / card background | Card `#ffffff` (pure white) with 2px `#111111` solid border |
| `cyanNeon` | `#00E5FF` | Primary theme color, borders, glowing shadows | Hot Pink `#ff3d81` (primary action), Ink `#111111` for borders |
| `purpleNeon` | `#D500F9` | Secondary accent, titles, special stats | Soft Lilac `#c8a2ff` & Canary Yellow `#ffd23f` |
| `successGreen` | `#00E676` | Neon green completed status, XP chips | Mint Green `#3ddc97` with 2px `#111111` border |
| `dangerOrange` | `#FF3D00` | Blood orange error & delete buttons | Coral `#ff6b5e` with 2px `#111111` border |
| `warningYellow` | `#FFD600` | Warning, streaks, title accents | Canary Yellow `#ffd23f` |
| `textMain` | `#E2E8F0` | Off-white text on dark backgrounds | Ink `#111111` (high contrast black text) |
| `textDim` | `#94A3B8` | Slate gray muted subtitle text | Charcoal `#555555` / `#666666` |
| `darkCyan` | `#00283C` | Dark button / fill states | Pastel tints (Pink/Mint/Lilac 10-20% tints) |

### 1.3 Legacy Font Usages (`Orbitron`)

Hardcoded `Orbitron` font usages must be completely eliminated to fulfill Acceptance Criterion 1 ("No remnants of legacy dark-neon/cyberpunk theme or hardcoded Orbitron fonts remain in user-facing screens").

Exact file paths and line numbers:
1. `app/lib/core/theme/app_theme.dart`: Lines 48, 53, 58, 63, 68, 73, 78, 91 (`displayLarge`, `displayMedium`, `displaySmall`, `headlineLarge`, `headlineMedium`, `headlineSmall`, `titleLarge`, `appBarTheme`).
2. `app/lib/features/profile/presentation/screens/profile_screen.dart`: Lines 189, 218, 287, 351, 418, 466, 649, 826, 887, 1078, 1130, 1182, 1213, 1234 (14 occurrences in class selector, headers, biometrics, badges).
3. `app/lib/features/onboarding/presentation/screens/onboarding_screen.dart`: Lines 1171, 1204 (Primary and Secondary class reveal headers).
4. `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart`: Line 85 (`finish` selection button label).
5. `app/lib/features/workout/presentation/screens/workout_screen.dart`: Lines 64, 183, 256 (`recent` header, `ready_to_level_up` title, `active_workout` badge).
6. `app/test/ui_regression_test.dart`: Line 209 (FontLoader setup).
7. `app/test/adversarial_edge_test.dart`: Line 53 (FontLoader setup).

---

## 2. Typography, Assets, and Vietnamese Diacritics Audit

### 2.1 Current Asset Loading & Font Packaging
In `app/pubspec.yaml`, fonts are bundled locally under `flutter: fonts:`:
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
No `google_fonts` package is used in `dependencies`. Fonts are bundled directly as offline assets in `app/assets/fonts/`.

**Crucial Testing Requirement**:
In `app/test/ui_regression_test.dart` and `app/test/adversarial_edge_test.dart`, tests run in a headless Flutter tester environment that explicitly loads font assets from `assets/fonts/` into the Flutter engine `FontLoader`. If fonts are not bundled as assets in `app/assets/fonts/`, automated widget and UI regression tests will fail to render glyphs and throw font loading exceptions!

### 2.2 Critical Discovery: Vietnamese Diacritics in Google Fonts

R1 specifies the following typography trio:
1. `Archivo Black` for display/headings
2. `Space Grotesk` for UI/body
3. `Space Mono` for numbers, stats, timestamps, XP

**Findings on Language Support**:
- **`Space Grotesk`**: Officially and natively supports full Vietnamese diacritics (designed by Florian Karsten, includes all tone marks, hooks, circumflexes, and đ).
- **`Space Mono`**: Officially and natively supports full Vietnamese diacritics (designed by Colophon Foundry for Google Fonts, includes full Latin Extended and Vietnamese glyph set across Regular, Bold, Italic).
- **⚠️ `Archivo Black` CAVEAT**:
  - The standalone `ArchivoBlack-Regular.ttf` from Google Fonts **does NOT include the Vietnamese subset** (it only covers Latin and Latin-Extended for Western and Central European languages). If Vietnamese text containing tone marks (e.g. `Ổ`, `Ậ`, `Ự`, `Ằ`, `Ễ`) is rendered with standalone `Archivo Black`, characters will either display as missing glyph rectangles (`.notdef` / tofu) or fall back to system fonts, breaking visual consistency.
  - **The Solution**: The main **`Archivo` variable font family** (`Archivo[wdth,wght].ttf`), created by the same foundry (Omnibus-Type), **fully supports Vietnamese** across all weights from 100 to 900 (Black).
  - **Recommendation for Agent A**: Bundle `Archivo[wdth,wght].ttf` as the font asset and define the family `Archivo` (or alias it to `ArchivoBlack` using `FontWeight.w900`). This achieves 100% visual parity with Archivo Black while guaranteeing complete, native Vietnamese diacritic rendering without system font fallbacks.

---

## 3. Component Library Audit & Candy Neubrutalism Primitives

### 3.1 Existing Legacy Components (`app/lib/ui/widgets/`)
Currently, only 4 shared widgets exist:
1. `SystemButton`: Standard Material `FilledButton` in `SizedBox(width: double.infinity)`. No border, no drop shadow, no tactile press feedback.
2. `SystemPanel`: Cyberpunk card with 4 drawn corner decorators (`_buildCorner`), `0.3` alpha cyan border, and glowing blurred drop shadow.
3. `SystemTextField`: Basic `TextFormField` with dark fill and material outline.
4. `StatusPanel`: Dark panel with centered icon, text message, and optional retry button.

### 3.2 Required `Candy*` Design System Primitives (16 Components)

To satisfy Requirement R1, Agent A must build a centralized, modular component library in `app/lib/ui/`:

```
app/lib/ui/
├── candy/
│   ├── candy_tokens.dart           # Palette, shadows, borders, radii, timings
│   ├── candy_scaffold.dart         # Scaffold with #fdf9f0 background & 24px grid painter
│   ├── candy_card.dart             # 2px border, 18px radius, hard unblurred shadow
│   ├── candy_button.dart           # Tactile 80-140ms press, downward-right offset, shadow collapse
│   ├── candy_text_field.dart       # White card, 2px border, hard shadow, custom clear/password icons
│   ├── candy_badge.dart            # Stadium pill, 2px border, vibrant candy fills
│   ├── candy_dialog.dart           # Neubrutalist modal dialog (for level-up, confirmations)
│   ├── candy_bottom_sheet.dart     # Neubrutalist bottom sheet with drag handle
│   ├── candy_skeleton.dart         # Neubrutalist loading placeholder
│   ├── candy_empty_state.dart      # Illustrative empty state with CTA
│   ├── candy_error_state.dart      # Coral error container with retry action
│   ├── candy_stat_tile.dart        # KPI metric tile (number in Space Mono, label in Space Grotesk)
│   ├── candy_progress_bar.dart     # Thick rounded progress bar with 2px border & vibrant fill
│   ├── candy_navigation_item.dart  # Neubrutalist tab/rail item with active tactile pill
│   ├── candy_exercise_card.dart    # Exercise library item with category pill & muscle tags
│   ├── candy_workout_set_row.dart  # Interactive set row with inputs & tactile completion toggle
│   └── candy_quest_card.dart       # Neubrutalist quest card with checklist, reward badge, CTA
```

### 3.3 Visual & Micro-Interaction Specifications

1. **Borders**: Exactly `2.0px` solid `#111111` (`Border.all(color: CandyColors.ink, width: 2.0)`).
2. **Hard Shadows (Zero Blur)**:
   - Small (`CandyShadows.small`): `[BoxShadow(color: CandyColors.ink, offset: Offset(3, 3), blurRadius: 0)]`
   - Medium (`CandyShadows.medium`): `[BoxShadow(color: CandyColors.ink, offset: Offset(5, 5), blurRadius: 0)]`
   - Large (`CandyShadows.large`): `[BoxShadow(color: CandyColors.ink, offset: Offset(8, 8), blurRadius: 0)]`
3. **Card Corner Radii**: `18.0px` (`BorderRadius.circular(18.0)`). Status pills use `StadiumBorder()` or `BorderRadius.circular(999.0)`.
4. **Tactile Button Press Interaction**:
   - Idle State: `Transform.translate(offset: Offset(0, 0))` with shadow `Offset(4, 4)`.
   - Pressed State: `Transform.translate(offset: Offset(3, 3))` with shadow `Offset(1, 1)` (or `Offset(0, 0)`).
   - Animation Duration: `100ms` (within the 80–140ms specification).
   - Curve: `Curves.easeInOut`.
5. **Background Grid**:
   - Drawn via a lightweight `CustomPainter` on `CandyScaffold`:
   - Grid size: `24.0px`
   - Stroke width: `1.0px`
   - Stroke color: `Color.fromRGBO(17, 17, 17, 0.04)` (subtle dark ink grid over `#fdf9f0` canvas).

---

## 4. Dashboard Screen Audit & Redesign Blueprint

### 4.1 Current Dashboard Structure (`app/lib/features/dashboard/presentation/screens/dashboard_screen.dart`)
- **AppBar**: Centered text `system_hub` ('SYSTEM HUB' / 'TRUNG TÂM HỆ THỐNG').
- **Profile / Hero (`_profile`)**: Dark container with hunter name, title, level in cyan neon, and default `LinearProgressIndicator`.
- **Action Buttons**: `SystemButton` ('start_workout') + `OutlinedButton.icon` ('AI Coach').
- **Active Classes (`_classCard`)**: Cards listing primary and secondary classes with thin colored progress bars.
- **Today's Objective**: `DailyQuestCard` (or `StatusPanel` for rest day).
- **Biometric Analysis**:
  - `_milestones`: Card with streak fire icon and achievement chips.
  - `VolumeTrendChart`: LineChart from `fl_chart` with cyan lines on dark background.
  - `MuscleRadarChart`: Horizontal bars with purple neon indicators.

### 4.2 Gaps Against Requirement R1 Dashboard Specification

| R1 Specification Section | Present in Current Code? | Implementation Details / Gaps |
|---|---|---|
| **1. Personalized Greeting + Class Badge** | Partially (Plain Text) | Currently just plain text in `_profile`. Needs `CandyHeroHeader` with greeting (e.g. "CHÀO HUNTER!", "HELLO HUNTER!") in `Archivo Black` and an interactive RPG class badge pill. |
| **2. Hero XP / Level Progression Card** | Needs Full Redesign | Needs `CandyCard` with level pill, current/required XP in `Space Mono`, title, and `CandyProgressBar`. |
| **3. 4 Accent KPI Tiles** | **MISSING** | Must be added! A responsive 2x2 grid (mobile) or 4x1 row (desktop) featuring: <br>1. **Weekly Volume** (Canary Yellow `#ffd23f`)<br>2. **Workouts Completed** (Mint Green `#3ddc97`)<br>3. **Current Streak** (Coral `#ff6b5e`)<br>4. **Quests Completed / XP** (Soft Lilac `#c8a2ff`). |
| **4. Weekly Activity Visualization** | **MISSING** | 7-day tactile day-tracker (Mon–Sun) showing completed workout days with check/flame pills. Data is already calculable from `volume_trend` in `get_user_stats`. |
| **5. Daily Quest Summary** | Present (Legacy Cyberpunk) | `DailyQuestCard` exists but uses `SystemPanel` with cyan glow. Replace with `CandyQuestCard`. |
| **6. Streak Tracker** | Minimal Row | Currently embedded inside `_milestones` card. Needs dedicated Neubrutalist streak banner with flame icon and best streak milestone. |
| **7. Workout Volume Trend Chart** | Present (Cyberpunk Line) | `VolumeTrendChart` uses neon cyan lines. Needs restyling with Neubrutalist bar/line styling and `Space Mono` typography. |
| **8. Recent Workout Feed** | **MISSING FROM DASHBOARD** | `recentWorkoutsProvider` already exists in `workout_history_controller.dart` (fetching top 3 workouts), but `DashboardScreen` never rendered it! Must add recent workout feed cards with date, duration, and exercise count. |
| **9. Primary CTA to Train** | Basic Button | Replace with prominent Hot Pink `CandyButton` ('BẮT ĐẦU TẬP' / 'START WORKOUT') with tactile press interaction. |

---

## 5. Viewport and Responsive Layout Handling (320px to 1440px)

### 5.1 Current Viewport Breakpoints
- **Shell Navigation (`main_shell_screen.dart`)**:
  - `constraints.maxWidth >= 960`: Renders `NavigationRail` (width ~80px) on the left.
  - `constraints.maxWidth < 960`: Renders bottom `NavigationBar`.
- **Dashboard Screen (`dashboard_screen.dart`)**:
  - `constraints.maxWidth > 920`: Centers content with horizontal padding `(constraints.maxWidth - 880) / 2`.
  - `constraints.maxWidth <= 920`: Sets horizontal padding to `20.0px`.

### 5.2 Overflow Risk Points at 320px Mobile
At 320px screen width, accounting for 16px horizontal screen padding, the usable content width is **288px**.
Key risk areas identified:
1. **4 KPI Tiles Grid**:
   - If laid out as 2 columns at 288px, each card has width `(288 - 12) / 2 = 138px`.
   - In Vietnamese, strings like "Khối lượng tuần" or "Buổi tập hoàn thành" can wrap onto 3 lines and cause vertical overflow if the card height is fixed.
   - **Guideline**: KPI tiles must use flexible vertical sizing or concise Vietnamese copy (`Khối lượng`, `Buổi tập`, `Chuỗi ngày`, `Nhiệm vụ`).
2. **Weekly 7-Day Activity Grid**:
   - `288px / 7 days = ~41px` per day slot.
   - With 4px spacing between days, each day pill is ~35px wide. This fits comfortably (e.g. 34x42px pill with day initial "T2", "T3", "M", "T" in Space Mono).
3. **Uppercase Diacritic Text in Buttons & Badges**:
   - Vietnamese diacritics in uppercase (`TẬP LUYỆN`, `TỔNG QUAN`) require additional line height (~1.3x) to avoid clipping accent marks (dấu mũ, dấu nặng).
   - `CandyButton` and `CandyBadge` must provide vertical padding (minimum 12–14px) and avoid rigid fixed heights.
4. **Bottom Navigation Labels at 320px**:
   - 4 tabs across 320px = 80px per tab. Labels: `TỔNG QUAN`, `TẬP LUYỆN`, `NHIỆM VỤ`, `HỒ SƠ`.
   - In Material 3 `NavigationBar`, long labels at 320px can truncate or collide.
   - **Guideline**: Use compact font size (11sp) or title-case in navigation items (`Tổng quan`, `Tập luyện`, `Nhiệm vụ`, `Hồ sơ`).

### 5.3 Desktop Handling at 1440px
- Constraining central content to a maximum width of `880px` to `1024px` prevents stretched cards while preserving dense, tactile Neubrutalist proportions.
- For screens `>= 1200px`, the dashboard can comfortably support a multi-column layout (e.g., 2 columns: Hero + KPIs + Weekly Activity on the left, Quests + Recent Workouts on the right), or a clean centered column with 4 KPI tiles in a single row.

---

## 6. Implementation Architecture & Coordination Recommendations

### 6.1 Recommended Division of Work

1. **Agent A (UI/UX Design System Specialist)**:
   - File Scope: `app/lib/core/theme/**`, `app/lib/ui/**`, `app/assets/fonts/**`, `app/pubspec.yaml`.
   - Deliverables:
     - Bundle `Archivo[wdth,wght].ttf`, `SpaceGrotesk[wght].ttf`, and `SpaceMono-Regular.ttf` / `SpaceMono-Bold.ttf` in `app/assets/fonts/`.
     - Update `app/pubspec.yaml` with the new font definitions.
     - Implement `CandyColors`, `CandyShadows`, `CandyTypography`, and `CandyTheme` in `app/lib/core/theme/`.
     - Implement the 16 `Candy*` primitives in `app/lib/ui/candy/`.
     - Rebuild `DashboardScreen` in `app/lib/features/dashboard/presentation/screens/dashboard_screen.dart` to match R1 specification.
2. **Agent B (Workout Feature Specialist)**:
   - Adopt `CandyExerciseCard`, `CandyWorkoutSetRow`, and `CandyButton` within `app/lib/features/workout/**`.
3. **Agent C (Backend & Game Systems Specialist)**:
   - Ensure `get_user_stats` RPC output provides accurate data for the 4 KPI tiles and weekly activity visualization.
4. **Lead Orchestrator**:
   - Update `MainShellScreen` navigation bar and rail to use `CandyNavigationItem`.
5. **Agent E (QA & Performance Specialist)**:
   - Update `app/test/ui_regression_test.dart` and `adversarial_edge_test.dart` to load the new fonts in test setup.

---

## Conclusion
The UI foundation is well-organized with Riverpod and GoRouter, making it straightforward to replace the legacy dark cyberpunk theme. The transition to Candy Neubrutalism requires zero breaking backend changes and will significantly elevate the tactile gamified feel of GymLvl.

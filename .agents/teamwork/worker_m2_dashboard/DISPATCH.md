# Task Assignment: Milestone M2 — Candy Neubrutalism Dashboard Overhaul

**Assigned Agent**: `worker_m2_dashboard` (Agent A: UI/UX & Dashboard Specialist)  
**Date**: 2026-10-27T09:46:00Z  
**Working Directory**: `d:\Projects\gymlvl\.agents\teamwork\worker_m2_dashboard`  

---

## 1. Objective
Overhaul the dashboard screen (`app/lib/features/dashboard/screens/dashboard_screen.dart`) and related dashboard widgets (`app/lib/features/dashboard/widgets/**`) using the newly established Candy Neubrutalism design system (`CandyColors`, `CandyTheme`, and `Candy*` primitives from `package:gymlvl/ui/candy/candy.dart`).

---

## 2. Exclusive Write Scope
- `app/lib/features/dashboard/**`
- `d:\Projects\gymlvl\.agents\teamwork\worker_m2_dashboard/**`
- **DO NOT** edit files outside this scope (e.g., `lib/features/workout/**`, `supabase/**`).

---

## 3. Detailed Requirements
1. **Header & RPG Identity**:
   - Greeting ("Sẵn sàng chiến thôi, Chiến binh!" or dynamic based on user profile name/class).
   - User profile avatar / level badge with tactile 2px ink border.
   - RPG Class indicator (Warrior / Mage / Rogue / etc.) with custom accent badge.
2. **Hero XP Progression Bar**:
   - Level indicator (`Space Grotesk` Bold), current XP, XP required for next level.
   - Neubrutalist progress bar using `CandyProgressBar` (mint/pink fill, 2px ink border, hard shadow).
3. **4 Tactile Neubrutalist KPI Tiles**:
   - Total Volume (Canary Yellow accent `#FFD23F`, formatted in kg/tons with `Space Mono`).
   - Total Workouts (Hot Pink accent `#FF3D81`).
   - Total Sets (Mint Green accent `#3DDC97`).
   - Active Streak (Soft Lilac accent `#C8A2FF`, flame icon, day count).
   - Use `CandyStatTile` or `CandyCard` with 2px borders, 4-6px hard unblurred drop shadows, and 18px radii.
4. **7-Day Weekly Activity Grid**:
   - Interactive or visual week strip (Mon–Sun / T2–CN) displaying completed workout indicators.
   - Neubrutalist styling with active mint/pink highlights for completed days.
5. **Daily Quests Preview**:
   - Connect to `dailyQuestsProvider` / quest state.
   - Display active quests with `CandyQuestCard` or compact Neubrutalist cards showing XP reward badges and claim status.
6. **Recent Workouts Feed**:
   - Connect to `recentWorkoutsProvider` / `workoutHistoryProvider`.
   - If empty: show `CandyEmptyState` with a helpful prompt to log the first workout.
   - If populated: display workout cards showing workout name, date/time, total sets, duration, and volume.
7. **Tactile Primary Action CTA**:
   - High-prominence "Bắt đầu tập luyện" / "Start Workout" button (`CandyButton.primary` in Hot Pink or Canary Yellow) leading to `/workout` (or calling the active workout trigger).
8. **Responsive & Overflow-Free**:
   - Wrap dashboard in `CandyScaffold` (subtle 24px grid pattern `#FDF9F0` canvas).
   - Must be fully scrollable (`SingleChildScrollView` or `CustomScrollView`).
   - Strict layout safety: 0 RenderFlex overflows from 320px narrow mobile screens to 1440px desktop screens.
9. **Zero Orbitron**:
   - Use `Archivo`, `Space Grotesk`, `Space Mono`, or `Inter`. 0 occurrences of Orbitron!

---

## 4. Verification Requirements
Run Dart analysis on the dashboard feature:
```cmd
cmd.exe /c "set LOCALAPPDATA=d:\Projects\gymlvl\.temp&& set APPDATA=d:\Projects\gymlvl\.temp&& C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/features/dashboard"
```
Must report:
`No issues found!` (0 errors, 0 warnings).

---

## 5. Mandatory Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

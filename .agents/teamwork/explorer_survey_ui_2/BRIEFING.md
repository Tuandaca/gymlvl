# BRIEFING — 2026-10-27T09:00:00Z

## Mission
Audit current UI/UX, theme, typography, reusable components, and dashboard implementation to prepare for the Candy Neubrutalism overhaul (R1).

## 🔒 My Identity
- Archetype: explorer
- Roles: UI & Design System Explorer
- Working directory: d:\Projects\gymlvl\.agents\teamwork\explorer_survey_ui_2
- Original parent: 5048b8e8-9ce2-4b77-ba4d-cbd08c2af2fd
- Milestone: Survey & UI/Design System Audit (R1 preparation)

## 🔒 Key Constraints
- Read-only investigation — do NOT implement
- Strictly read-only, no modifications to app source code
- Focus on theme, typography, UI components, dashboard, responsive handling

## Current Parent
- Conversation ID: 5048b8e8-9ce2-4b77-ba4d-cbd08c2af2fd
- Updated: 2026-10-27T08:50:00Z

## Investigation State
- **Explored paths**:
  - `app/lib/core/theme/app_theme.dart`
  - `app/lib/ui/widgets/**` (`system_panel`, `system_button`, `system_text_field`, `status_panel`)
  - `app/lib/features/dashboard/**` (`dashboard_screen`, `stats_charts`, `dashboard_stats`, `stats_providers`)
  - `app/lib/core/router/**` (`main_shell_screen`, `app_router`)
  - `app/lib/features/workout/**`, `quests/**`, `profile/**`, `onboarding/**`, `progression/**`
  - `app/pubspec.yaml`, `app/assets/fonts/**`
  - `app/test/ui_regression_test.dart`, `adversarial_edge_test.dart`
- **Key findings**:
  1. Entire current app relies on dark cyberpunk/Solo Leveling palette (`AppTheme.cyanNeon` #00E5FF, `purpleNeon` #D500F9, `panelBackground` #D90A0D1A, `background` #030308, `warningYellow`, `dangerOrange`).
  2. Orbitron font is hardcoded across 28+ locations in theme, profile, onboarding, workout, and tests.
  3. Fonts are currently bundled locally in `app/assets/fonts/` (Inter and Orbitron).
  4. Google Fonts `Archivo Black` does NOT have native Vietnamese diacritics, but the main `Archivo` variable font (`Archivo[wdth,wght].ttf`) from Google Fonts DOES support full Vietnamese across all weights (up to 900 Black). `Space Grotesk` and `Space Mono` have full native Vietnamese support.
  5. Centralized `Candy*` component library needed (16 components). Existing `SystemPanel`, `SystemButton`, `SystemTextField`, `StatusPanel` must be superseded.
  6. Dashboard currently lacks: 4 KPI tiles, weekly activity visualization, recent workout feed, and Candy tactile CTA. Data is already available from RPC/providers.
  7. Layout handles 320px-1440px reasonably via LayoutBuilder, but uppercase Vietnamese strings and 4 KPI grid require strict responsive layout guards.
- **Unexplored areas**: None, synthesis and report generation remaining.

## Key Decisions Made
- Recommend bundling `Archivo` (variable font, weight 900) for Archivo Black styling to guarantee 100% Vietnamese diacritic fidelity.
- Structure design tokens for Candy Neubrutalism into clean, strongly typed palette and theme extension.

## Artifact Index
- `report.md` — Comprehensive survey and audit findings
- `handoff.md` — 5-component handoff report
- `progress.md` — Liveness heartbeat
- `DISPATCH.md` — Incoming message log

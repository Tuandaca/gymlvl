# P10.3b — Global and class level consumer audit

**Checkpoint:** 2026-11-13, `main` at `7e21abb7649d108bf9b54ae59e874e816f2b54ff`, with preserved uncommitted owner/P10 work.
**Status:** `PASS` for the bounded current-source inventory. Runtime behavior and placement implementation `NOT RUN`.
**Method:** Inspect `level`, `total_xp`, `current_xp`, `current_level_xp`, graduation and provider-map readers across `app/lib`, version-ordered `supabase/migrations` and `supabase/functions`. Follow raw user/class queries and the effective `get_player_progression`, `complete_workout`, `switch_class`, quest and unlock functions. Generated model accessors are transport definitions, not independent business decisions. Review performed read-only by implementer and audit agent.

## Findings that constrain implementation

1. The effective `complete_workout` recomputes global level from total XP. Writing placement to `users.level` would disappear on the next completion. The same function preserves class level and persists it into the P9 legacy floor; writing placement there would contaminate earned history. Evidence: `supabase/migrations/20261113000100_p9_class_level_parity.sql:83`, `:89`, `:91`.
2. Effective unlock synchronization reads `users.level >= 10/20` directly. A global placement floor of 10 in that column could qualify for an earned title. Evidence: `supabase/migrations/20261113000200_p9_unlock_awards.sql:33`.
3. Displaying a combined level in an existing XP widget without its own next-level arithmetic would mix a placement floor with an earned-XP denominator. Evidence: `app/lib/features/dashboard/presentation/widgets/hero_xp_card.dart:16` and `app/lib/features/progression/presentation/providers/player_progression_view_provider.dart:63`.

**Required invariant:** Existing global/class level, XP, title, graduation and P9 legacy floors retain earned/legacy semantics. Placement requires separate storage, explicitly named response fields and labelled readiness UI. No consumer may interpret a placement floor as earned progression unless explicitly approved.

## Inventory and intended contract

Paths are repository-relative; line anchors refer to the source inspected at this checkpoint.

| Consumer / source | Current inputs and behavior | P10.3b contract |
|---|---|---|
| `app/lib/features/auth/presentation/providers/auth_providers.dart:41` | `currentUserProvider` selects the complete owner `users` row. Profile provider separately reads experience. | Existing keys remain earned/legacy. Read placement from a separate provider/RPC, never mutate this map's `level`. |
| `app/lib/features/dashboard/presentation/providers/class_providers.dart:6` | Selects complete owner `user_classes` rows. | Existing class rows stay earned/legacy. |
| `supabase/migrations/20261107000200_p5_game_integration.sql:157`, `:207` | Effective `get_player_progression` serializes class/global level and XP. | Existing response fields unchanged; placement response uses explicit readiness fields through a new RPC. |
| `app/lib/features/progression/presentation/providers/player_progression_provider.dart:37` and `player_progression_view_provider.dart:18`, `:63` | Parses earned progression; class level determines XP-to-next-level. | Keep earned arithmetic; use a separate typed placement/readiness projection. |
| `app/lib/features/dashboard/presentation/screens/dashboard_screen.dart:635`, `:670`, `:682`, `:722` | Class/global cards, XP and graduation/cap UI. | Preserve existing earned lane; add a clearly labelled estimated/confirmed readiness card. No graduation or earned title from readiness. |
| `app/lib/features/dashboard/presentation/widgets/dashboard_header.dart:26`, `:148`, `:168` | Global/class badges. | Earned badges remain earned; any readiness badge includes status and version. |
| `app/lib/features/dashboard/presentation/widgets/hero_xp_card.dart:16` | `level` plus `current_level_xp` and global threshold. | Keep earned lane; readiness progress uses separately calculated delta thresholds. |
| `app/lib/features/profile/presentation/screens/profile_screen.dart:646`, `:680`, `:1121`, `:1176` | Global/class badges. | Never silently replace earned level with readiness. |
| `app/lib/features/workout/presentation/screens/workout_summary_screen.dart:80`, `:238`; `app/lib/features/post_workout_feedback/presentation/screens/post_workout_feedback_screen.dart:97`, `:121` | Displays completion reward receipt and level-up feedback. | Receipt remains earned-only; placement confirmation appears separately after refresh. |
| `app/lib/features/progression/presentation/widgets/level_up_overlay.dart:33`, `:84` | Earned level-up animation. | No animation triggered solely by a provisional/confirmed placement. |
| `app/lib/features/progression/domain/rpg_bridge.dart:104`; `presentation/progression_screen.dart:177`; `presentation/widgets/class_progress_card.dart:39`, `:72`, `:120` | XP-only class preview and progress bars. | Continue using earned inputs. Add readiness through separate state if exposed. |
| `supabase/migrations/20261113000100_p9_class_level_parity.sql:78`, `:87` | Completion XP from sets, quests, streak, category and synergy. | Placement never changes reward amount, streak, quest matching, category or synergy. |
| Same migration `:84`, `:118` | Earned title and achievements from XP-derived level and real workout count. | Earned-only. |
| Same migration `:87`, `:90` | Graduation controls future class XP. | Earned-only. Readiness reaching class 20 never graduates a class. |
| Same migration `:138`, `:150` | `switch_class` checks onboarding/slot and preserves earned/legacy floor history. | Keep existing eligibility and floor ledger. A different primary class gets no placement from the previous class. |
| `supabase/migrations/20261113000200_p9_unlock_awards.sql:33` | Level/graduation unlocks read stored earned level. | Earned-only; no placement backfill or reinterpretation. |
| `supabase/migrations/20261110000100_p9_exercise_contract.sql:79` | Daily quest templates rotate by date/category, weights from PRs. No level reader found in the effective selector. | Keep current behavior; any future readiness-based quest selection needs an explicit decision. |
| `app/lib/features/training_plan/presentation/providers/training_plan_providers.dart:40` | Hardcodes beginner for every account without workouts; engine returns an empty plan for experienced users. | Read actual profile experience. Never-trained receives beginner flow; experienced receives existing routine selection/editor flow with readiness context. No invented automatic experienced prescription. |
| `app/lib/features/ai_trainer/domain/services/pt_context_builder.dart:160`, `:170`, `:193`, `:216` | Latent domain builder infers experience from RPG level, emits earned class/global XP. No production invocation found under `app/lib`. | Keep earned fields; replace physical-experience inference with profile experience when wiring. Readiness, if later supplied, must carry status/version and B/F training-readiness semantics. |
| `supabase/functions/ai-coach/index.ts:38`; `service.ts:56` | Live Edge context reads profile experience/recent workouts; no level/XP consumer found. | Leave unchanged. Adding readiness to live AI context requires explicit payload treatment and tests. |

## Scope and verification limits

- Searches and source inspection ran in this checkpoint; findings are static inspection, not a device/live test.
- No current level-based quest difficulty or additional eligibility consumer was found; those categories remain explicit regression cases.
- New consumers introduced during implementation must be added here with their input semantics. The inventory is not a permanent guarantee against future code changes.
- Proposed persistence/API behavior is in `docs/planning/P10_3B_PLACEMENT_CONTRACT.md`; it is not implemented at this checkpoint.

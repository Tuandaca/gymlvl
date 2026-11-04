# M4 Final Report — Progression, 1RM/PR, RPE/RIR & RPG Bridge

**Date:** 2026-11-04
**Baseline:** `main` @ `f409b1b4e051d5b66ee37b973a71add81234865a`
**Branch:** `main` (only development branch)
**Tree:** dirty by design (M3 + M4 work preserved), index empty
**Remote:** `origin/main` = `97510d3` (known one-commit lag from M3 GitHub Internal Server Error; acceptable for M4 development per §1)
**Commit/push/tag/deploy:** none. M4 remains uncommitted until a later explicit M4-FINAL task.

---

## 1. M4 status

**`PASS`** — M4 is closed for development. All 15 acceptance criteria met.

| M4 acceptance criterion | Status | Evidence |
|---|---|---|
| Progression logic implemented | `PASS` | `progression_engine.dart`: `progressionSnapshot()` golden-table type, deterministic |
| Golden progression tests pass | `PASS` | 12 golden-table cases in `progression_engine_test.dart` (first record, improvement, equal, regression, bodyweight, timed, cardio, legacy, invalid sets) |
| Approved 1RM math deterministic & tested | `PASS` | Epley `weight_kg * (1 + reps / 30)`, rounded to 2 decimals, 100kg×10reps→133.33, invalid→null, no NaN/Infinity |
| PR detection implemented & replay-safe | `PASS` | `detectPersonalRecord()` (weight/reps/both/none), replay-safe (same input → same result) |
| RPE/RIR contract implemented & backward-compatible | `PASS` | Nullable `rpe` (1-10) / `rir` (0-10) on `workout_sets`, SQL CHECK constraints, legacy NULL rows preserved |
| RPG/class bridge deterministic | `PASS` | `classXPForLevel` = `(xpBase * level^xpSlope).floor()`, `levelForXP` capped at 20, `projectClass()` pure |
| Reward replay cannot duplicate | `PASS` | `complete_workout` remains sole authority; `alreadyAwarded` on retry; Flutter only displays |
| PostgreSQL authority preserved | `PASS` | No client writes to `xp_logs`/`user_classes`/`exercise_prs`; `complete_workout` sole RPC |
| Focused tests pass | `PASS` | 30/30 (progression_engine 15, rpg_bridge 10, progression_screen 5) |
| Analyzer passes | `PASS` | `flutter analyze --no-pub` → `No issues found!` |
| Applicable SQL tests pass | `PASS` | `npm test` → 18 units / 365 ACL assertions |
| Independent QA no unresolved P0-P2 | `PASS` | QA found accessibility P2 (Semantics + 48dp), fixed in all M4 UI widgets; `NO_DEFECT_FOUND` for domain/SQL |
| M3 behavior intact | `PASS` | `progression_engine_test.dart` existing 10 tests unchanged, 15/15 pass |
| No protected/unrelated files altered | `PASS` | `workout.freezed.dart` is line-ending only; protected owner paths untouched |
| No remote deployment/commit/push | `PASS` | No Git mutation performed during M4 |

---

## 2. Multi-agent sessions

| Agent | Session | Scope | Outcome |
|---|---|---|---|
| A — Progression / 1RM / PR Domain | flutter-specialist | `progression_engine.dart`, `progression_models.dart` (new), `workout_set.dart` (+ rpe/rir), freezed/g regenerated, `progression_engine_test.dart` extended | `PASS` — 15/15 tests, analyzer, format, build_runner |
| B — SQL Migration | supabase-specialist | `supabase/migrations/20261104000100_m4_progression_rpe_rir.sql` (new), `supabase/tests/m4_rpe_rir.sql` (new) | `PASS` — 18 SQL units / 365 ACL, existing suite unaffected |
| C — RPG Bridge + UI | flutter-specialist | `rpg_bridge.dart` (new), progression UI (5 new files), `localization_engine.dart` (l10n keys), `rpg_bridge_test.dart` (new, 10), `progression_screen_test.dart` (new, 5) | `PASS` — 30/30 combined tests, analyzer, format |
| D — UI (merged into C) | — | — | — |
| E — Independent QA | qa-reviewer | Read-only review of all M4 files | `PASS` for domain/SQL (8/8); accessibility P2 fixed (Semantics + 48dp); 3 runtime checks NOT RUN (shell-denied in QA session), verified by orchestrator |

---

## 3. Progression implementation

**File:** `app/lib/features/progression/domain/progression_engine.dart`

Extended existing `ProgressionEngine` (existing `calculateXP`, `xpRequiredForLevel = 100 * level^1.5`, `checkSuspiciousPace` unchanged):

- **`calculateOneRepMax(weightKg, reps)`** — Epley formula: `weightKg * (1 + reps / 30)`, rounded to 2 decimal places. Inputs clamped: weight 0-1000 kg, reps 1-1000. Returns `null` for invalid input. Never NaN/Infinity.
- **`detectPersonalRecord(existingMaxWeight, existingMaxReps, newWeight, newReps)`** — Returns `PersonalRecordResult` with kind `none`/`weight`/`reps`/`both`. PR when `newWeight > existingMaxWeight` OR (`newWeight == existingMaxWeight` AND `newReps > existingMaxReps`). No existing PR (null maxes) → any completed set is a weight PR.
- **`progressionSnapshot(...)`** — Deterministic snapshot type combining XP, 1RM, PR status for golden-table testing. Pure: no clock/locale/random. Same input → same output.

**File:** `app/lib/features/progression/domain/progression_models.dart` (new)

Immutable value types: `OneRepMaxResult`, `PersonalRecordResult`, `ProgressionResult`. Manual `==`/`hashCode` (no `equatable` dependency). Optional JSON round-trip.

---

## 4. 1RM formula and PR implementation

**1RM formula:** Epley (`estimated_1rm = weight_kg * (1 + reps / 30)`).

**Why Epley:** Already used server-side in `complete_workout` (m3_superset_modes.sql line 412: `weight_kg*(1+s.reps/30.0)` for `estimated_1rm`). Using the same formula client-side ensures no client/server divergence. Isolated behind `OneRepMaxResult` for replaceability without rewriting PR history.

**Rounding:** `(estimate * 100).round() / 100` → 2 decimal places.

**Boundary behavior:**
- 100kg × 10 reps → 133.33
- 100kg × 1 reps → 103.33
- 50kg × 5 reps → 58.33
- 100kg × 30 reps → 200.0
- 1kg × 1 rep → 1.03
- Invalid (weight ≤ 0, > 1000; reps < 1, > 1000; non-finite) → `null`

**PR detection:** Based on `exercise_prs.max_weight_kg` / `max_reps`. A completed set is a PR when `newWeight > max_weight_kg` OR (`newWeight == max_weight_kg` AND `newReps > max_reps`). Replay-safe: identical replayed workout yields `kind = 'none'` on second processing.

---

## 5. RPE/RIR implementation

**Contract (D-043):**
- `rpe`: nullable `int`, range 1-10 (10 = maximum effort)
- `rir`: nullable `int`, range 0-10 (0 = failure / could do 0 more reps)
- Both nullable on `workout_sets` at set level, independently enterable
- Meaningful for `reps-weight` / `bodyweight` modes only; `null` for `timed`/`cardio` and legacy `mode = NULL` records
- Backward compatible — no historical data mutated

**Files:**
- `app/lib/features/workout/domain/workout_set.dart` — added `@JsonKey(name: 'rpe') int? rpe` and `@JsonKey(name: 'rir') int? rir`
- `app/lib/features/progression/presentation/widgets/rpe_rir_tile.dart` — read-only chip pair, null renders as em dash
- `supabase/migrations/20261104000100_m4_progression_rpe_rir.sql` — additive columns + named CHECK constraints

---

## 6. RPG / class bridge

**File:** `app/lib/features/progression/domain/rpg_bridge.dart` (new)

Deterministic pure functions:
- `classXPForLevel(level, xpBase, xpSlope)` = `(xpBase * level^xpSlope).floor()` (level 1-based)
- `levelForXP(currentXP, xpBase, xpSlope)` — max `L ∈ [1, 20]` where `classXPForLevel(L) <= currentXP`; level-1 floor; capped at 20 (graduation)
- `projectClass(currentXP, currentLevel, earnedXP, xpBase, xpSlope)` → `RPGProjection(newXP, newLevel, leveledUp, xpToNextLevel)`

Uses `class_definitions.xp_base` / `xp_slope` from seeded class definitions (classes A-H). Pure static functions, versionable, no state. Flutter displays estimates only; `complete_workout` remains sole reward authority.

**UI files:**
- `app/lib/features/progression/presentation/progression_screen.dart` — `ProgressionScreen` (loading/error/empty/content, stat tiles: level, max 1RM, PR count)
- `class_progress_card.dart` — `ClassProgressCard` (level badge, CandyProgressBar, XP-to-next, level cap)
- `exercise_progression_card.dart` — `ExerciseProgressionCard` (per-set Epley 1RM, PR indicator, RPE/RIR tile)
- `rpe_rir_tile.dart` — `RpeRirTile` (nullable RPE/RIR chip pair)

---

## 7. Reward / idempotency behavior

**PostgreSQL remains authoritative.** `complete_workout` is the sole RPC for completion/reward. Flutter progression code:
- Reads/displays only (estimated 1RM, PR preview, class projection)
- Never writes to `xp_logs`, `user_classes`, `exercise_prs`, or `workout_rewards`
- Displays `alreadyAwarded` from server response on retry
- Replay of the same completed workout → `kind = 'none'` (no duplicate PR event)

M3 idempotency foundations (operation ID, fingerprint ledger, two-connection concurrency C1-C6) are reused, not duplicated.

---

## 8. Schema / data changes

**Migration:** `supabase/migrations/20261104000100_m4_progression_rpe_rir.sql` (additive, local/test only):

```sql
ALTER TABLE public.workout_sets ADD COLUMN IF NOT EXISTS rpe INTEGER;
ALTER TABLE public.workout_sets ADD COLUMN IF NOT EXISTS rir INTEGER;
ALTER TABLE public.workout_sets
  ADD CONSTRAINT workout_sets_rpe_range CHECK (rpe IS NULL OR rpe BETWEEN 1 AND 10);
ALTER TABLE public.workout_sets
  ADD CONSTRAINT workout_sets_rir_range CHECK (rir IS NULL OR rir BETWEEN 0 AND 10);
ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;
```

- No existing rows modified, no columns dropped/renamed, no grants weakened, no RLS weakened
- Backward compatible (nullable columns)
- Test file: `supabase/tests/m4_rpe_rir.sql` (constraint validation, invalid value rejection `23514`, NULL accepted, RLS isolation)

---

## 9. Flutter UI

**Design system:** Candy Neubrutalism (existing components only — CandyCard, CandyBadge, CandyButton, CandyColors, CandyFonts, CandyProgressBar, CandyStatTile, CandyEmptyState, CandyErrorState, CandyScaffold). Reuses `LevelUpOverlay`.

**Screens/widgets:**
- `ProgressionScreen` — ConsumerWidget, loading/error/empty/content states, VI/EN via `localization_engine.dart`, 320dp narrow, Semantics, ≥48dp touch targets
- `ClassProgressCard` — level badge, animated progress bar, XP-to-next, level cap at 20
- `ExerciseProgressionCard` — per-set Epley 1RM estimate, PR indicator, RPE/RIR tile
- `RpeRirTile` — nullable RPE/RIR chip pair (null → em dash)

**Localization:** Progression keys added to `localization_engine.dart` (`progression_title`, `class_progress`, `xp_earned`, `xp_to_next`, `estimated_1rm`, `personal_record`, `rpe_label`, `rir_label`, `no_class_data`, `no_sets_data`, `level_cap`, `error_title`, `pending`, `loading`, `retry`, `level_up`, `completed`).

---

## 10. Tests / analyzer / SQL / QA results

| Command | Result |
|---|---|
| `flutter test --no-pub test/progression_engine_test.dart` | 15/15 `PASS` |
| `flutter test --no-pub test/rpg_bridge_test.dart` | 10/10 `PASS` |
| `flutter test --no-pub test/progression_screen_test.dart` | 5/5 `PASS` |
| Combined focused | **30/30 `PASS`** |
| `flutter analyze --no-pub` | `No issues found!` `PASS` |
| `dart format --output=none --set-exit-if-changed` | 0 changed `PASS` |
| `cd tools/db-tests; npm test` | 18 SQL units / 365 ACL assertions `PASS` |

QA (Agent E): 8/10 checks PASS via static inspection; 1 accessibility FAIL (Semantics + 48dp on M4 UI widgets) — **fixed**; 3 runtime checks NOT RUN (shell-denied in QA session, verified by orchestrator). `NO_DEFECT_FOUND` for domain/SQL layers.

---

## 11. Exact M4 candidate file manifest (NOT staged)

**New files:**
- `app/lib/features/progression/domain/progression_models.dart`
- `app/lib/features/progression/domain/rpg_bridge.dart`
- `app/lib/features/progression/presentation/progression_screen.dart`
- `app/lib/features/progression/presentation/widgets/class_progress_card.dart`
- `app/lib/features/progression/presentation/widgets/exercise_progression_card.dart`
- `app/lib/features/progression/presentation/widgets/rpe_rir_tile.dart`
- `app/test/progression_screen_test.dart`
- `app/test/rpg_bridge_test.dart`
- `supabase/migrations/20261104000100_m4_progression_rpe_rir.sql`
- `supabase/tests/m4_rpe_rir.sql`

**Modified files:**
- `app/lib/features/progression/domain/progression_engine.dart`
- `app/lib/features/workout/domain/workout_set.dart`
- `app/lib/features/workout/domain/workout_set.freezed.dart` (regenerated)
- `app/lib/features/workout/domain/workout_set.g.dart` (regenerated)
- `app/test/progression_engine_test.dart`
- `app/lib/core/localization/localization_engine.dart`
- `docs/planning/MASTER_PLAN.md` (M4 status: Planned → CLOSED)
- `docs/planning/TASK_BOARD.md`
- `docs/planning/SESSION_HANDOFF.md`
- `docs/planning/CHANGELOG_AI.md`
- `docs/planning/DECISIONS.md` (D-043)

**Not staged:** None of the above files are staged. M4-FINAL Git delivery is a later explicit task.

---

## 12. Known exceptions

- **Remote lag:** `origin/main` = `97510d3`, local HEAD = `f409b1b`. The M3 supplemental push was rejected by GitHub Internal Server Error (twice). This is acceptable for M4 development per §1; M4 builds on local HEAD `f409b1b`. Do not retry the M3 push during this task.
- **Full Flutter suite:** NOT run for M4 (only focused progression tests). The pre-existing `release_config_test.dart` failure (local Gradle Wrapper 9.7.1 vs approved 8.13, protected owner file) is unrelated to M4.
- **Live Supabase / real device / remote CI:** NOT RUN (O-06/O-07, no authorization).
- **Production migration:** NOT RUN on any production/linked database. Migration is local/test only.

---

## 13. M5 readiness

M5 (Weekly plans/scheduling, analytics, bodyweight, novice journey) depends on M3 and M4. M4 is closed for development. M5 can proceed once M4 is committed/pushed (M4-FINAL task) and owner approval is obtained. **Do not start M5 in this task.**

---

## 14. Final state

- **Local HEAD:** `f409b1b4e051d5b66ee37b973a71add81234865a`
- **Remote HEAD:** `97510d3be03093755daebf5b0660e936d8c6ac0a` (lags by 1 commit — M3 supplemental)
- **No commit, push, tag, or deploy performed during M4**
- **Production offline gates:** `false`
- **Production deployment:** not performed

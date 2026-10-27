# Implemented progression and rewards

Updated: 2026-10-26. The authoritative implementation is `complete_workout` in [the progression migration](../supabase/migrations/20261026000200_authoritative_progression.sql), with database regression evidence in [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md). Flutter's `ProgressionEngine` is a display-only estimate.

## Authority and lifecycle

Every new user starts at global level 1 with 0 XP. Experience level is profile information; clients cannot grant an experienced-user head start. Repeating completed onboarding returns existing setup rather than resetting or awarding progression.

Workout setup and active training are distinct. The server records training start/pause time, excluding setup/paused time from active duration. Completion requires at least one completed set with valid measurements. One transaction locks the user's progression and workout, validates ownership and state, then updates the reward ledger, user/class XP, quest, streak, records, achievements and completed workout.

`workout_rewards` stores the original response keyed by workout. Retrying returns that response; legacy already-awarded sessions are not awarded again. Completed/cancelled workouts cannot be edited through ordinary child-record writes. This supports idempotency but live multiple-session concurrency remains a separate verification gate.

## Ordinary workout XP

Only completed sets with positive reps count.

- Each set contributes `5 × ratio`.
- If the server captured a prior positive personal-record weight at set creation, `ratio = clamp(weight / baseline, 0.2, 3.0)`; otherwise ratio is 1.
- Variety contributes `8 × max(0, distinct completed muscle categories − 1)`.
- Streak multiplier is `min(1.5, 1 + 0.05 × max(0, resulting streak − 1))`.
- Award is the floored sum times multiplier, capped at 1,000 XP per session.

No XP is earned merely by elapsed time. Baseline weight is assigned by the database from the owner's prior records and cannot be changed by client input.

If more than three sets are completed at over four sets per active minute, the session is flagged suspicious and receives 10 XP. Short sessions with up to three valid sets are not automatically rejected. Measurements are bounded by database rules: completed reps 1–1,000, weight 0–1,000 kg, at most 300 completed sets. These are software validation limits, not fitness recommendations.

There is no implemented 500-XP daily cap or three-workout daily limit. Those values in earlier plans were proposals and must not be represented as current behavior.

## Daily quest rewards

One objective is created per user/calendar day, on demand, in the profile timezone (default `Asia/Ho_Chi_Minh`). It expires at the next local midnight; completed or expired objectives are not regenerated for the same day.

The seeded templates reward 350 XP for push/pull, 400 for legs and 450 for full body. The current prescription chooses up to three matching catalog exercises with three sets of twelve reps each. Suggested weight is 80% of the recorded maximum, rounded to 0.5 kg; bodyweight exercises and exercises without a prior record use 0 kg. A missing record is a discovery state, not an instruction to choose an aggressive load.

A workout qualifies only when **every prescribed exercise** meets its required number of completed sets, reps and weight. A matching exercise name/category alone is insufficient. The quest base reward replaces the ordinary session reward and uses a streak multiplier capped at 2.0, with the same 1,000-XP session ceiling. Suspicious pace still limits the award to 10 XP. There is no separate 50-XP perfect-session bonus.

## Streaks and dates

A qualifying completion on the same local day does not increment the streak twice. The next consecutive local day adds one; a gap starts at one. Expired streaks display as zero when daily data/statistics are refreshed. The longest streak is retained. Workout/quest dates use the profile timezone; Coach quota dates independently use UTC.

## Global levels and titles

The cumulative threshold to advance **from level L to L+1** is `floor(100 × L^1.5)`; level starts at 1 and caps at 100. Examples: 99 XP is level 1; 100 XP is level 2; 282 XP is level 3. This is a cumulative threshold, not an amount added for each level.

| Reached level | Title |
|---|---|
| 1 | Tân Binh |
| 5 | Tập Sự |
| 10 | Chiến Binh |
| 15 | Đấu Sĩ |
| 20 | Dũng Sĩ |
| 30 | Anh Hùng |
| 50 | Huyền Thoại |
| 75 | Thần Thoại |
| 100 | Bất Tử |

## Class progression

The active catalog is A–F. Historical G/H rows remain readable but are not new selectable classes.

| ID | Class | Base | Slope |
|---|---|---:|---:|
| A | Shredder | 80 | 1.40 |
| B | Hiper-Growth | 100 | 1.45 |
| C | Powerlifting | 130 | 1.55 |
| D | Endurance | 80 | 1.40 |
| E | Calisthenics | 100 | 1.45 |
| F | Bodybuilding | 160 | 1.65 |

A class receives 100% of session XP if any completed exercise category matches its server catalog focus, otherwise 40%. A configured perfect pair adds 5% class XP; current pairs are A/D, B/C, E/C and F/B in either order. Class thresholds advance at `floor(base × level^slope)`, capped at level 20; a level-20 class graduates and stops receiving new per-session class XP.

Class switching validates the slot/class and prevents equipping the same class twice. It recomputes progress from awarded completed sessions, not active/cancelled sets, and preserves higher existing recorded progress for the selected class. Switching does not add global XP. The old design's mandatory graduation-before-switch restriction is not implemented.

## Achievements and limits

The server grants unique achievements for the first completed workout, ten completed workouts, a seven-day streak and global level 10. They do not grant additional XP. Their uniqueness prevents duplicate unlocks.

Weekly/main/hidden quest chains, breakthrough locks, level-decay penalties, notification rewards and a larger achievement catalog are future designs. They are not implied by the retained design documents.

The app cannot independently verify that a person physically performed a logged exercise. Server authority protects database consistency, authorization and reward calculations; truthful logging and safe exercise choices remain part of user acceptance.


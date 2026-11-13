# P9.3 progression consistency plan

## Evidence and decision boundary

- D-043 defines the class level `n` threshold as `floor(xp_base * n^xp_slope)`.
- Dart `RPGBridge.levelForXP` uses the threshold for `level + 1`, while the effective SQL `complete_workout` and `switch_class` loops compare the current level. Existing SQL test `progression_regression.sql` expects level 2 at `xp_base`; this conflicts with D-043 and Dart.
- The progression view computes a class next-level threshold but subtracts global `totalXP`; it must subtract the selected class's `currentXP` and report zero for a graduated class.
- `user_unlocks` is readable and owner-insertable but no award path inserts a row. Changing unlock award semantics or correcting stored class levels requires a data policy decision.

## Ordered work

1. Add a view-provider regression with unequal global and primary class XP; observe RED, then fix the display-only calculation and rerun focused/full Flutter checks.
2. Add SQL golden boundaries for each class definition and document the current failure without modifying existing user progression.
3. D-052 accepted: preserve stored class levels/graduation as a private per-class floor; apply the D-043 threshold to future awards/switches. D-053 accepted: backfill unlocks from verified evidence and sync future unlocks inside completion reward transactions.
4. Additive SQL migrations and two-user/idempotency/threshold tests are implemented locally. Preserve XP and already-earned rewards; deny client unlock forgery.

No production operation or Git write is authorized by this plan.

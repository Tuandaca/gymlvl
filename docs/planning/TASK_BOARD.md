# GymLvl — Task Board

## Current phase — P7: Remaining OpenGym Parity & Optional Integrations (2026-11-06)

**Task:** Execute P7 — close the seven frozen CORE gates (custom exercises, favourites + aliases, import framework + supported imports, backup restore, health-platform integration boundary, optional media integration boundary, focused tests + regression/security).

**Execution order:** audit parity → preflight → implement gates sequentially → focused tests → regression → docs → stop. Do NOT start P8.

**Status:** `IN PROGRESS` (Gates 1–3 complete; 4–7 pending)

**Commit:** `main` @ `180f3cb0ce2a49ac43eaea26f6bc94c029bb8f0c` (P6 baseline, matches mission). Working tree is dirty with pre-existing owner work + uncommitted P6 implementation files — all PRESERVED, untouched. Additionally, **P7 implementation** files added/committed (import framework, exercise personalization migration, P7 SQL test).

**Frozen P7 CORE gates (exactly seven; no new acceptance criteria may be added):**
1. Custom exercise support — DB migration DONE; Exercise model + repository + providers DONE; UI + tests PENDING
2. Exercise favourites + aliases — DB migration DONE; repository + providers DONE; UI + tests PENDING
3. Import framework + supported workout-data imports — **GATE 3 COMPLETE**
4. Backup restore / GymLvl portable import — PENDING (P4 export v1 format defined)
5. Health-platform integration boundary — PENDING
6. Optional media integration boundary — PENDING
7. Focused tests + regression/security — P7 SQL test PASS; Dart tests + regression PENDING

**Invariants to preserve (do not violate):**
- Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL; existing workout engine/history/bodyweight/analytics/progression/RPG.
- `complete_workout` remains sole authoritative reward path; P7 actions grant ZERO XP; imported historical workouts = no retroactive RPG rewards.
- Additive DB migrations only; no existing tables/columns dropped; no RLS weakened; no production `supabase db push`.
- Bold Candy Neubrutalism UI; VI/EN diacritics; no AGPL code/media; no third-party media.
- OpenGym = behavioral reference only; no code/text/asset copying.
- `main` is the only development branch; no automatic commit/push/tag.
- Pre-existing owner dirty/untracked files preserved (see SESSION_HANDOFF.md).

**Known unrelated failure that may remain:** `release_config_test.dart` (Gradle wrapper 9.7.1 vs expected 8.13 — owner Gradle file, do not modify); `m3_superset_modes.sql` CHECK behavior (pre-existing SQL debt, not P7).

**Verification results:**
- P7 SQL test `supabase/tests/p7_exercise_personalization.sql`: PASS (owner CRUD, archive, favourites, aliases, unique constraints, structural ACL policies)
- Gate 3 import framework: unit-tests implemented, `csv_import_service.dart`, `import_models.dart`, migration `p7_import_records.sql` — **code compiles**, `flutter analyze` no errors, test evidence pending in focused Dart tests.
- `flutter analyze`: only pre-existing warnings/infos remain; no new errors from P7 code
- `npm test` full suite: stopped at pre-existing `m3_superset_modes.sql` debt (unrelated to P7); P7 migration + p7 SQL test run clean in isolation

**No commit/push** without owner approval. P8 NOT started.
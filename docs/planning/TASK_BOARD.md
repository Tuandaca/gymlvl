# GymLvl — Task Board

## Current phase — P7: Remaining OpenGym Parity & Optional Integrations (2026-11-06)

**Task:** Execute P7 — close the seven frozen CORE gates (custom exercises, favourites + aliases, import framework + supported imports, backup restore, health-platform integration boundary, optional media integration boundary, focused tests + regression/security).

**Execution order:** audit parity → preflight → implement gates sequentially → focused tests → regression → docs → stop. Do NOT start P8.

**Status:** `COMPLETE` (all seven frozen P7 CORE gates PASS)

**Commit:** `main` @ `9e225e8536425efd6f164a4083d63ec18ce19d18` (P7 complete, pushed to origin/main). Working tree is dirty with pre-existing owner work — all PRESERVED.

**Frozen P7 CORE gates (exactly seven; no new acceptance criteria may be added):**
1. Custom exercise support — **COMPLETE** (DB migration, model, repository, providers, focused tests PASS)
2. Exercise favourites + aliases — **COMPLETE** (DB migration, repository, providers, focused tests PASS)
3. Import framework + supported workout-data imports — **COMPLETE** (CSV import service, import models, focused tests PASS)
4. Backup restore / GymLvl portable import — **COMPLETE** (backup_import_service.dart, focused tests PASS, idempotent, zero-reward)
5. Health-platform integration boundary — **COMPLETE** (health_data_repository.dart, fake adapter, capability detection, zero reward)
6. Optional media integration boundary — **COMPLETE** (exercise_media.dart, provenance checking, no-media fallback)
7. Focused tests + regression/security — **COMPLETE** (46 focused Dart tests PASS, SQL/ACL PASS, flutter analyze no errors)

**Invariants to preserve (do not violate):**
- Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL; existing workout engine/history/bodyweight/analytics/progression/RPG.
- `complete_workout` remains sole authoritative reward path; P7 actions grant ZERO XP; imported/restored historical workouts = no retroactive RPG rewards.
- Additive DB migrations only; no existing tables/columns dropped; no RLS weakened; no production `supabase db push`.
- Bold Candy Neubrutalism UI; VI/EN diacritics; no AGPL code/media; no third-party media.
- OpenGym = behavioral reference only; no code/text/asset copying.
- `main` is the only development branch; no automatic commit/push/tag.
- Pre-existing owner dirty/untracked files preserved (see SESSION_HANDOFF.md).

**Known unrelated failure that may remain:** `release_config_test.dart` (Gradle wrapper 9.7.1 vs expected 8.13 — owner Gradle file, do not modify); `m3_superset_modes.sql` CHECK behavior (pre-existing SQL debt, not P7).

**Verification results:**
- P7 focused Dart tests: **46/46 PASS** (test/p7_backup_import_test.dart, test/p7_health_media_test.dart, test/p7_exercise_personalization_test.dart)
- P7 SQL test `supabase/tests/p7_exercise_personalization.sql`: **PASS** (owner CRUD, archive, favourites, aliases, unique constraints, structural ACL policies)
- `flutter analyze --no-pub`: **no errors** (only pre-existing warnings/infos)
- `flutter test --no-pub`: **all pass except pre-existing release_config_test.dart** (Gradle 9.7.1 vs 8.13 — owner file, untouched)
- `dart format --set-exit-if-changed .`: **stable**

**Immediate next action:** owner review / decide when to start P8.

**Do NOT start P8 automatically.**
# GymLvl — Task Board

## Current phase — P1: OpenGym Parity Baseline + Legal-Safe Exercise Catalogue (2026-11-05)

**Task:** Build a detailed OpenGym → GymLvl feature parity baseline AND implement the legal-safe exercise catalogue foundation using the pinned MIT dataset (1,324 exercisedb records). Continue through implementation, testing, documentation, and final reporting in the same task.

**Status:** `COMPLETE`

**Commit:** `main` @ `962d8f7` (P0 base, pushed to origin/main); P1 changes committed/pending owner approval.

**Deliverables — all COMPLETE:**
1. `docs/planning/OPENGYM_PARITY_MATRIX.md` — fully populated capability map (OpenGym vs GymLvl across Catalogue, Routine/Planning, Workout, Progression, Utilities, Analytics, Device/Platform, Account/Security, Coach/AI, Other).
2. Legal-safe import pipeline: `tools/catalogue-import/{package.json,import.mjs,import.test.mjs}` — selects `textSource === 'exercisedb'` (1,324 MIT records), strips media, generates idempotent `INSERT ... ON CONFLICT (source, external_id) DO NOTHING` SQL. 10/10 pipeline tests pass.
3. Additive migration: `supabase/migrations/20261105000300_p1_exercise_provenance.sql` — adds `source`/`external_id`/`source_revision` columns + `UNIQUE (source, external_id)` + backfills curated rows. Runs against PGlite (23/23 SQL units, 365 ACL assertions PASS). RLS not weakened.
4. Flutter model: `app/lib/features/workout/domain/exercise.dart` (+ `.freezed.dart`/`.g.dart` regenerated) — provenance fields `source`/`externalId`/`sourceRevision`. `app/test/exercise_detail_test.dart` — 3 new provenance round-trip tests.
5. Flutter analyze: `No issues found!`. Dart format: clean. Full Flutter suite: 558 pass / 1 fail (sole failure = pre-existing protected `release_config_test.dart` Gradle 9.7.1 vs 8.13, NOT a P1 regression).

**Blockers:** None for P1.

**Do NOT start:** P2, P3, P4, P5, P6 (AI PT), P7 (media), P8 (release), production migration, release hardening.

**Next implementation phase:** P2 — Routine & Planning Parity (NOT STARTED, awaits owner instruction).

---

## Current product blocker — Onboarding 9/9 submit failure (2026-11-04) — BLOCKED

**Status:** `BLOCKED` — production schema/runtime mismatch; requires explicit owner approval to verify/deploy. Not the current task. Do not deploy migrations.

---

## Do not do (constraints)

- Do not start P2+ automatically.
- AI PT is not the immediate next implementation stage (P6).
- No production deployment, database migration, or remote Supabase changes.
- No third-party exercise media.
- Do not commit/push without explicit owner approval.

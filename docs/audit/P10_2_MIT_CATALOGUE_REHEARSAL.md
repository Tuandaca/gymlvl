# P10.2 — Pinned MIT catalogue local rehearsal

**Date:** 2026-11-13
**Source commit:** `main` `7e21abb7649d108bf9b54ae59e874e816f2b54ff` plus the scoped uncommitted changes listed below.
**Status:** `PASS` for local importer, isolated database replay and focused Flutter catalogue loading. Production import, live gateway and device UX are `NOT RUN`.

## Scope and provenance

- Source: `D:\Projects\exercises-dataset-reference` at pinned `7455efae41b330c265e7cd4b78dfa848e7ce5ebd`; exactly 1,324 records from `data/exercises.json`.
- Only text and metadata are mapped. `image_url` is null, media/link fields are excluded, and generated SQL carries the upstream MIT copyright, permission and warranty notice. OpenGym AGPL catalogue text/assets are not used.
- Review artifact: `D:\Projects\gymlvl_p10_catalogue_backup_20261113_184248\catalogue-import-rehearsal.sql` (1,087,856 bytes). It is outside Git and was generated for review; no production SQL execution occurred.
- Verified pre-edit repository preservation: `D:\Projects\gymlvl_p10_catalogue_backup_20261113_184248`; bundle clone matched HEAD, Git archive matched 841 tree paths, and 890 current workspace files matched their ZIP hashes.

## Verification

| Check | Status | Evidence and limit |
|---|---|---|
| Pinned importer | `PASS` | `EXERCISEDB_SOURCE_DIR=D:\Projects\exercises-dataset-reference; npm test` in `tools/catalogue-import` exited 0: 14/14 tests. Covers Windows direct CLI with a space-containing path, 1,324 rows, source keys, slug uniqueness, `text[]` SQL, media absence, deterministic output and full MIT notice. The previous CLI silently exited 0 without writing output; the RED case reproduced this before the fix. |
| Isolated database import/replay | `PASS` | `npm run test:catalogue` in `tools/db-tests` exited 0 after 28 ordered migrations and two configured seeds. Both applications yielded 1,474 total exercises, including 1,324 `exercisedb` rows. All 150 curated complete rows/UUIDs and a synthetic workout-exercise FK reference remained unchanged. All imported rows/UUIDs remained unchanged on replay; source keys and slugs were unique; arrays and pinned provenance matched the importer; no media URL appeared. |
| Search/filter at full catalogue size | `PASS` | The isolated SQL rehearsal found 164 imported names matching `press` and two rows matching a selected category/equipment pair. This proves those database queries work on the 1,474-row fixture, not live PostgREST performance. |
| Flutter catalogue loading | `PASS` | `flutter test test/p10_catalogue_pagination_test.dart test/p9_custom_exercise_repository_test.dart --reporter expanded` in `app` exited 0: 6/6 tests. The 1,474- and 2,000-row HTTP fixtures were RED at the prior 1,000-row cap, then passed with bounded 1,000-row pages ordered by `name,id`. Empty and exact-page cases pass. `Exercise.localizedName('vi')` falls back to English for untranslated rows. |
| Static quality | `PASS` | `dart analyze` on the changed repository and test: `No issues found!`; `dart format --output=none --set-exit-if-changed` on the same files: 2 files, 0 changed. `npm test` in `tools/db-tests` passed 53 SQL units/365 synthetic ACL assertions in the implementer run. |
| Production import and user-device flow | `NOT RUN` | No production write/deploy is authorized. P10.1 rollout gate remains `BLOCKED`; no live gateway, authenticated RLS session, device UX or full Flutter suite was used to claim production readiness. |

## Changed paths

- `tools/catalogue-import/import.mjs`, `import.test.mjs`
- `tools/db-tests/catalogue-import.mjs`, `package.json`
- `app/lib/features/workout/data/supabase_exercise_repository.dart`
- `app/test/p10_catalogue_pagination_test.dart`
- `docs/superpowers/plans/2026-11-13-p10-2-mit-catalogue-local.md`
- This audit and the required planning checkpoint files.

**Next action:** P10.3a designs a versioned, source-backed placement threshold table for owner approval. P10.2 production import requires its own rollout review after P10.1 safety/data gates are resolved.

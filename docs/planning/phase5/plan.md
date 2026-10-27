# Phase 5 — tests and security

Updated: 2026-10-26. This local plan is a scope/reference note, not a separate completion checklist.

Gates: formatting/analyzer/build; meaningful Flutter unit/widget tests; Edge input/auth/failure tests; fresh migration application; grants plus RLS; current-user/cross-user/anonymous tests; ownership spoofing; privilege manipulation; transaction rollback and duplicate/concurrent rewards; rendered VI/EN viewport checks.

Record PASS, FAIL, BLOCKED, NOT RUN or NOT APPLICABLE with actual commands and evidence in IMPLEMENTATION_STATUS.md. A PostgreSQL-equivalent harness can verify SQL when Docker is unavailable, but it does not prove Supabase Auth/PostgREST/Edge end-to-end behavior. Do not infer release readiness from passing pure engine tests.

Authoritative status: [IMPLEMENTATION_STATUS.md](../../docs/IMPLEMENTATION_STATUS.md). Setup and release: [DEVELOPMENT.md](../../docs/DEVELOPMENT.md).


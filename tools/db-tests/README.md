# Reproducible verification

From this directory run `npm ci`, then `npm test` for isolated PostgreSQL migration,
seed replay, RLS, privilege, and progression regressions. The runner applies the
actual versioned SQL without rewriting it to an in-memory PGlite PostgreSQL engine.
The small Auth bootstrap provides the same identity/role contract used by policies.
Broad Supabase-style default grants ensure tests also check that migrations narrow
client privileges. The database is disposable and never contacts a remote project.

The pinned PGlite version embeds PostgreSQL 17.5, matching the project's configured
PostgreSQL major version. For a populated-schema rehearsal, set
`GYMLVL_LEGACY_BACKUP` to a private JSON backup containing `rows[0].backup`, then run
`npm run test:legacy`. It restores records only into a new in-memory database,
replays the baseline and hardening migrations, and checks original data remains.
Only table counts are printed. Never add the private backup to the repository.

Run `npm run check:edge` to typecheck every Edge entrypoint and `npm run test:edge`
for Deno authentication, request, and AI Coach tests. Dependencies are recorded in
`supabase/functions/deno.lock`.

Run `npm run test:web` after building the web app with test configuration. The
script serves `app/build/web` on a temporary loopback port and uses installed
Google Chrome in headless mode. `CHROME_PATH` selects a different Chrome binary,
`GYMLVL_WEB_ROOT` selects another build, and `GYMLVL_SCREENSHOTS` selects the output
directory (default `tmp/qa-browser`). It captures VI/EN login/register at 320, 390,
768, and 1440 pixels, including browser errors and Flutter accessibility text.
The script does not register a real user or access authenticated records.

These checks supplement a disposable `supabase start` / `supabase db reset` stack.
Run the same plain SQL regression on that local stack with
`psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -v ON_ERROR_STOP=1 -f ../../supabase/tests/security_regression.sql`.
They do not verify GoTrue email delivery, the deployed JWT gateway, Edge runtime,
Storage, or true multiple-session concurrency. Those checks require the local
Supabase stack or a separately verified staging project. PGlite documentation:
https://pglite.dev/docs/ and https://pglite.dev/extensions/.

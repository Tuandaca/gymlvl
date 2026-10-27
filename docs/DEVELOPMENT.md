# Run, test, and release GymLevel

Updated: 2026-10-26. Commands below describe the workflow; they are not execution evidence. See [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) for actual results and blockers.

## Prerequisites

Use Flutter/Dart satisfying `app/pubspec.yaml` and the lockfile. The verified installed baseline is Flutter 3.38.5 / Dart 3.10.4. The complete backend requires Supabase CLI and a running Docker-compatible engine. Deno runs TypeScript checks. Android needs its SDK/licenses; iOS/macOS builds require macOS/Xcode.

```powershell
flutter --version
flutter doctor -v
supabase --version
docker version
deno --version
```

## Start an isolated backend

From the repository root:

```powershell
supabase start
```

Project ID: `gymlvl`. Default local endpoints: API `http://127.0.0.1:54321`, Studio `http://127.0.0.1:54323`, email viewer `http://127.0.0.1:54324`. Check actual startup output. Use the email viewer for confirmation links when enabled.

For a **verified disposable local database only**, rebuild migrations and seed data:

```powershell
supabase db reset --local
supabase test db
```

Reset deletes local data. Never reset a linked/production database. Migrations are the only schema-install path. Seeds contain catalogs/templates, not real users.

Serve functions in a second terminal:

```powershell
supabase functions serve
```

Keep JWT verification enabled. A client key alone does not establish identity; sign in before protected operations. The local runtime supplies Supabase platform variables. Optional provider settings belong in an ignored server-only environment file.

## Run Flutter

Obtain the local publishable key from your private CLI/Studio output. From `app/`:

```powershell
flutter pub get
flutter run -d chrome --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_LOCAL_PUBLISHABLE_KEY
```

`SUPABASE_ANON_KEY` is accepted as a legacy fallback. Use only client-safe keys. Missing configuration opens setup instructions; no hosted target is silently selected. Compile-time configuration changes require restarting the run/build.

Alternatively copy `app/config.example.json` to an ignored local JSON file, replace its key placeholder, and run `flutter run -d chrome --web-port 8080 --dart-define-from-file=config.local.json`. Set `AUTH_REDIRECT_URL` to the browser URL used for password recovery, and include that URL in Supabase Auth's site URL/redirect allowlist. Keep local configuration out of commits.

For a hosted project, use its URL/key only after the reviewed schema/functions are deployed. For an Android emulator, use `http://10.0.2.2:54321` to reach the host. For a phone, use a reachable development host address and firewall access; loopback on the phone points to the phone itself. Configure auth redirects for the actual client address. Production requires HTTPS.

Register a fresh test account, complete email confirmation if enabled, sign in, finish onboarding, and log a legitimate workout. No manual XP/profile SQL edits should be required. Keep test data separate from real accounts.

## AI Coach

The Phase 4 design listed Gemini/Claude as examples without selecting or provisioning a provider. The implementation uses a server-configured compatible chat endpoint; no named provider or credentials are silently added. A Python service is unnecessary.

Configure these server-only variables in an ignored local function environment file or hosted function secrets:

| Variable | Value |
|---|---|
| `COACH_API_URL` | Full HTTPS chat-completions-compatible endpoint from your chosen provider |
| `COACH_API_KEY` | Provider credential, never a Flutter define |
| `COACH_MODEL` | Model identifier supported by that endpoint |

For example, serve with `supabase functions serve --env-file supabase/.env.local` after creating that ignored file yourself. No example credential is included. Hosted configuration can use `supabase secrets set --env-file supabase/.env.local` only after confirming the linked target; never include a real key as a command-line literal or in a report.

Coach sends only training preferences/goals and up to seven completed workouts from the previous seven days; it excludes names, email addresses and body measurements. Conversation history stays in memory. It accepts at most eight prior messages, validates request sizes, uses a 25-second upstream timeout, and permits 20 requests per user per UTC day. A provider attempt consumes quota even if the upstream service fails.

Expected failures: 503 unconfigured/unavailable, 429 daily/provider quota, 504 timeout, 502 invalid/provider failure. Missing provider configuration leaves manual workouts usable. Responses are guidance, not diagnoses or verified activity, and never write workout/XP/quest records. Live provider testing remains separate from mocked integration tests.

## Generate and verify

From `app/`:

```powershell
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_LOCAL_PUBLISHABLE_KEY
```

Run generation only when annotations change. Wait for success and inspect generated diffs.

From `tools/db-tests/`, run the isolated verification harness:

```powershell
npm ci
npm test
npm run check:edge
npm run test:edge
npm run test:web
```

`npm test` applies the actual versioned migrations and replays seed data in disposable PGlite PostgreSQL, then runs SQL authorization/progression regressions. It uses real PostgreSQL roles/RLS with an Auth identity shim. It does not contact a remote project or verify GoTrue, PostgREST, Edge gateway JWT behavior, or true multi-session concurrency. `npm run check:edge` typechecks function entrypoints; `npm run test:edge` runs Deno tests. `npm run test:web` serves a previously built `app/build/web` and captures public auth screens; Chrome must be installed or supplied with `CHROME_PATH`. See [harness details](../tools/db-tests/README.md) and the evidence report for the exact verified scope.

## Remote deployment

First identify the target project, compare remote schema and migration history, and review pending SQL for compatibility with existing records. Reconcile prior dashboard changes before deployment. [Official migration guide](https://supabase.com/docs/guides/local-development/database-migrations).

```powershell
supabase link --project-ref YOUR_VERIFIED_PROJECT_REF
supabase migration list --linked
supabase db push --dry-run
```

After the review, local gates, and recovery checks pass:

```powershell
supabase db push
supabase functions deploy
```

Do not alter migration history to hide a mismatch. Existing legacy SQL installations need a reviewed adoption/baseline process. Back up affected data before changes that can invalidate records. Never use `supabase db reset --linked` or disable JWT verification to work around authentication errors.

Build web with the verified hosted URL/client key and publish `app/build/web` using the selected host. Configure SPA fallback to `index.html`, HTTPS, auth redirects, and appropriate cache headers. No hosting destination or signing identity is assumed.

Android releases require real application ID/signing configuration. iOS requires an Apple signing team and macOS host. Privacy policy, store assets, and real-device acceptance remain release requirements until verified.

# GymLvl

GymLvl is a Flutter fitness app with an RPG-style dashboard, workout logging, class progression, daily quests, and Vietnamese/English interfaces. Supabase Auth and PostgreSQL are the source of truth; authenticated Edge Functions and database transactions own progression and rewards.

P0–P9 implementation is complete in committed history; P9 is published and its remote CI passed. P9 production migrations and live validation remain gated. See the [current task board](docs/planning/TASK_BOARD.md), [handoff](docs/planning/SESSION_HANDOFF.md), and [roadmap](docs/planning/MASTER_PLAN.md) for the current state. The [October implementation audit](docs/IMPLEMENTATION_STATUS.md) is preserved as historical evidence.

## Start here

- [Run and test the app locally](docs/DEVELOPMENT.md)
- [Architecture and security boundaries](docs/ARCHITECTURE.md)
- [Current implementation and release state](docs/planning/TASK_BOARD.md)
- [Historical October implementation audit](docs/IMPLEMENTATION_STATUS.md)
- [Progression rules](docs/PROGRESSION_GUIDE.md)
- [Historical debugging record](ERRORS.md)

## Run the client

Install Flutter with Dart compatible with `app/pubspec.yaml` (`^3.10.4`), then start the backend using the [development guide](docs/DEVELOPMENT.md). From `app/`:

```powershell
flutter pub get
flutter run -d chrome --web-port 8080 --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_LOCAL_PUBLISHABLE_KEY
```

Use a publishable key or supported legacy anon key. Never put a secret/service-role key or AI-provider key in Flutter configuration. Missing configuration opens an actionable setup screen.

## Repository

```text
app/                   Flutter client, generated models, localization, tests
supabase/migrations/   Versioned schema and privileged database operations
supabase/functions/    Authenticated Deno Edge Functions and tests
docs/                  Setup, architecture, verification, design references
docs/admin/            Future proposal; no running admin application
ERRORS.md              Historical incidents and regression notes
```

There is no separate Python/FastAPI service or alternate backend. AI credentials belong in the server environment; see the development guide for provider configuration and limitations.

## Development checks

```powershell
Set-Location app
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_LOCAL_PUBLISHABLE_KEY
```

When annotated models or providers change, run `dart run build_runner build --delete-conflicting-outputs`, wait for successful completion, and review generated changes before testing.

Platform scaffolds exist for Android, iOS, web, Windows, macOS, and Linux. Only platforms with executed build and runtime evidence in the status report should be treated as verified.

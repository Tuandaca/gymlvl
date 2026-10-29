# GymLvl Flutter client

Run from this directory after configuring the Supabase backend:

```powershell
flutter pub get
flutter run -d chrome --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_LOCAL_PUBLISHABLE_KEY
```

Use [the full development guide](../docs/DEVELOPMENT.md) for backend startup, authentication, configuration, generated code, tests, and deployment. Executed checks and release limitations are in [implementation status](../docs/IMPLEMENTATION_STATUS.md).

The app uses Riverpod and GoRouter. Features live under `lib/features/`, shared configuration/navigation under `lib/core/`, and reusable widgets under `lib/ui/`. Supabase owns persistent data and authoritative progression; local workout state and XP estimates do not grant rewards.

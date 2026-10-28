# A2 retained controller probes

Baseline: `main` at `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`, 2026-10-28.
Audit-only; no product code or permanent tests changed. The tests exercise the actual
`ActiveWorkoutController`, with an in-memory mock `SharedPreferences`, synthetic auth
sessions and a fake workout repository. They do not initialize Supabase, contact a
backend, or use production identities or data. The test asserts the **observed** defects,
not the desired behavior: its green result is evidence of reproduction, not a fix.

## Procedure (PowerShell, Windows)

Use an unused temporary directory and copy only the explicit paths below. `lib` is
source only: inspect it for secrets or production data before copying, and stop if
any are present. Never copy the whole app, hidden environment files, user data, or
credentials. The dependency cache referenced by `package_config.json` must already
exist; do not run `pub get` or modify the original app. The temp copy is retained.
The font files and package graph are required by the Flutter runner on this host.

```powershell
$root = 'D:\Projects\gymlvl'
$dest = 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-minimal-20261028'
if (Test-Path $dest) { throw 'Destination already exists; choose another unused path' }
New-Item -ItemType Directory -Path "$dest\app\test", "$dest\app\.dart_tool", "$dest\app\assets\fonts" -Force -ErrorAction Stop | Out-Null
Copy-Item "$root\app\lib" "$dest\app\lib" -Recurse -ErrorAction Stop
Copy-Item "$root\app\pubspec.yaml", "$root\app\pubspec.lock" "$dest\app" -ErrorAction Stop
Copy-Item "$root\app\.dart_tool\package_config.json", "$root\app\.dart_tool\package_graph.json" "$dest\app\.dart_tool" -ErrorAction Stop
$fonts = 'InterVariable.ttf','InterItalicVariable.ttf','ArchivoVariable.ttf','SpaceGroteskVariable.ttf','SpaceMono-Regular.ttf','SpaceMono-Bold.ttf','OrbitronVariable.ttf'
foreach ($font in $fonts) { Copy-Item "$root\app\assets\fonts\$font" "$dest\app\assets\fonts" -ErrorAction Stop }
# Save the exact Dart source below as UTF-8 at $dest\app\test\a2_retained_probe_test.dart
Set-Location "$dest\app"
flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart
$LASTEXITCODE
Set-Location $root
git status --porcelain=v1
```

The initial historical run below used a full app copy, which could have copied secret
files. It is retained for provenance, not recommended as a procedure. The second run
used only the explicit paths above. Neither test used production accounts or data.

The controller is held alive through a provider listener. The fake cancel method
returns promptly and increments a counter; the direct-cancel control proves the fake
can complete. The active-discard timeout is bounded; it does not prove an infinite
hang independently of source inspection. The inactive-discard control also completes.
The backup is created synthetically after the auth event, without an actual login.
The same-owner control demonstrates a valid local restore. Null and throwing remote
responses are separate cases. A successful remote response, live RLS, real device
storage, sign-out cleanup, and data exfiltration are not tested.

## Exact test source

```dart

import 'dart:async';
import 'dart:convert';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_repository.dart';
import 'package:app/features/workout/presentation/controllers/active_workout_controller.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Workout draft(String owner) => Workout(id: 'draft-$owner', userId: owner, startedAt: DateTime.utc(2026));
Session session(String id) => Session(accessToken: 'synthetic-token', tokenType: 'bearer', user: User(id: id, appMetadata: {}, userMetadata: {}, aud: 'authenticated', createdAt: '2026-01-01T00:00:00Z'));

class Repo extends Fake implements WorkoutRepository {
  int cancels = 0;
  bool detailError = false;
  bool activeError = false;
  Workout? remote;
  @override
  Future<Workout> startWorkout() async => draft('A');
  @override
  Future<void> cancelWorkout(String id) async { cancels++; }
  @override
  Future<Workout?> getWorkoutDetail(String id) async {
    if (detailError) throw StateError('synthetic offline');
    return remote;
  }
  @override
  Future<Workout?> getActiveWorkout() async {
    if (activeError) throw StateError('synthetic offline');
    return null;
  }
}

void main() {
  late Repo repo;
  late ProviderContainer container;
  late StreamController<AuthState> events;
  late ActiveWorkoutController controller;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = Repo();
    events = StreamController<AuthState>.broadcast();
    container = ProviderContainer(overrides: [
      authStateStreamProvider.overrideWith((ref) => events.stream),
      workoutRepositoryProvider.overrideWithValue(repo),
    ]);
    container.listen(activeWorkoutControllerProvider, (_, _) {});
    controller = container.read(activeWorkoutControllerProvider.notifier);
  });
  tearDown(() async { container.dispose(); await events.close(); });
  Future<void> identity(String id) async {
    events.add(AuthState(AuthChangeEvent.signedIn, session(id)));
    await Future<void>.delayed(Duration.zero);
    await container.pump();
  }
  Future<void> backup(String owner) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ActiveWorkoutController.backupKey, jsonEncode({'workout': draft(owner).toJson()}));
  }

  test('discard active cycle versus direct cancel and inactive discard controls', () async {
    await identity('A');
    await controller.startWorkout();
    await controller.cancelWorkout().timeout(const Duration(seconds: 2));
    expect(repo.cancels, 1);
    expect(container.read(activeWorkoutControllerProvider).hasActiveWorkout, false);
    await controller.discardLocalBackup().timeout(const Duration(seconds: 2));
    await controller.startWorkout();
    var timedOut = false;
    try { await controller.discardLocalBackup().timeout(const Duration(milliseconds: 300)); }
    on TimeoutException { timedOut = true; }
    final state = container.read(activeWorkoutControllerProvider);
    print('DISCARD direct_cancel=1 inactive_discard=completed active_timeout=$timedOut cancel_calls=${repo.cancels} active=${state.hasActiveWorkout}');
    expect(timedOut, true);
    expect(repo.cancels, 1);
    expect(state.hasActiveWorkout, true);
  });

  for (final remoteError in [false, true]) {
    test('cross owner restore remote ${remoteError ? "error" : "null"}', () async {
      await identity('B');
      await backup('A');
      repo.detailError = remoteError;
      await controller.restoreFromLocalBackup().timeout(const Duration(seconds: 2));
      final owner = container.read(activeWorkoutControllerProvider).workout?.userId;
      print('RESTORE B backup=A remote=${remoteError ? "error" : "null"} observed_owner=$owner expected_owner=null');
      expect(owner, 'A');
    });
  }
  test('same owner restore control', () async {
    await identity('A');
    await backup('A');
    await controller.restoreFromLocalBackup().timeout(const Duration(seconds: 2));
    final owner = container.read(activeWorkoutControllerProvider).workout?.userId;
    print('RESTORE A backup=A remote=null observed_owner=$owner expected_owner=A');
    expect(owner, 'A');
  });
  for (final remoteError in [false, true]) {
    test('checkForActiveWorkout cross owner remote ${remoteError ? "error" : "null"}', () async {
      await identity('B');
      await backup('A');
      repo.activeError = remoteError;
      await controller.checkForActiveWorkout().timeout(const Duration(seconds: 2));
      final owner = container.read(activeWorkoutControllerProvider).workout?.userId;
      print('CHECK B backup=A remote=${remoteError ? "error" : "null"} observed_owner=$owner expected_owner=null');
      expect(owner, 'A');
    });
  }
  test('checkForActiveWorkout same owner control', () async {
    await identity('A');
    await backup('A');
    await controller.checkForActiveWorkout().timeout(const Duration(seconds: 2));
    final owner = container.read(activeWorkoutControllerProvider).workout?.userId;
    print('CHECK A backup=A remote=null observed_owner=$owner expected_owner=A');
    expect(owner, 'A');
  });
}

```

## Observations and expected behavior

- Active discard: expected completion, one additional prompt fake cancel and inactive
  state. Observed timeout at 300 ms, cancel counter still 1 (only the direct control),
  active state still true. Source inspection shows `discardLocalBackup` enqueues an
  action that awaits another `cancelWorkout` enqueue behind itself. Direct cancel and
  inactive discard both completed. The backup removal occurs before the stall; this
  probe does not assert durable deletion or follow-on app behavior.
- Owner B restoring owner A: expected no A draft in B state; observed owner A with
  both null and error fake remote responses. Same-owner A control observed A. This
  demonstrates client-state adoption, not server access or a live account leak.
- Post-await identity-reset race: **NOT RUN**. A deterministic gate at the local
  preference await was not implemented; no claim is made about that separate race.

## Historical first run (full app copy; not the current recommended setup)

Working directory: `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028\app`.
Command: `flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart`.
Result **PASS** (exit 0; assertions intentionally encode observed defect):

```text
00:00 +0: loading C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a2-probe-20261028/app/test/a2_retained_probe_test.dart
00:00 +0: discard active cycle versus direct cancel and inactive discard controls
DISCARD direct_cancel=1 inactive_discard=completed active_timeout=true cancel_calls=1 active=true
00:00 +1: cross owner restore remote null
RESTORE B backup=A remote=null observed_owner=A expected_owner=null
00:00 +2: cross owner restore remote error
RESTORE B backup=A remote=error observed_owner=A expected_owner=null
00:00 +3: same owner restore control
RESTORE A backup=A remote=null observed_owner=A expected_owner=A
00:00 +4: All tests passed!
EXIT=0
```

`git status --porcelain=v1` in the original workspace immediately before this new
artifact was written returned the eight pre-authorized orchestrator-owned paths:

```text
 M docs/audit/AUDIT_COVERAGE.md
 M docs/audit/FINDINGS_REGISTER.json
 M docs/audit/MASTER_FINDINGS.md
 M docs/audit/SESSION_HANDOFF.md
 M docs/planning/CHANGELOG_AI.md
 M docs/planning/SESSION_HANDOFF.md
 M docs/planning/TASK_BOARD.md
?? docs/audit/phases/A2_FLUTTER.md
```

After writing this artifact the expected additional status entry is
`?? docs/audit/phases/A2_PROBES.md`. `flutter analyze` is **NOT RUN**: no Dart
product files or dependencies were changed; the isolated probe was compiled by the
command above. No production code, account, or backend was exercised.
## Additional UI-path probe: minimal copy

`checkForActiveWorkout` is the UI recovery path; `restoreFromLocalBackup` alone is
not evidence of the UI path. Fake `getActiveWorkout` returns null or throws, and
synthetic owner B sees owner A in both cases, contrary to expected no A draft. The
same-owner A/null control returns A. These are client state observations only.

Setup initially failed with `PathNotFoundException` for `.dart_tool/package_graph.json`
(exit 1); after copying that explicit generated file it failed with `unable to locate
asset entry in pubspec.yaml: "assets/fonts/InterVariable.ttf"` and `Failed to build
asset bundle` (exit 1). After copying the seven explicit font assets, the run below
passed; no dependency resolution was performed.

Working directory: `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-minimal-20261028\app`

`flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart`:

```text
00:00 +0: loading C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a2-minimal-20261028/app/test/a2_retained_probe_test.dart
00:00 +0: discard active cycle versus direct cancel and inactive discard controls
DISCARD direct_cancel=1 inactive_discard=completed active_timeout=true cancel_calls=1 active=true
00:00 +1: cross owner restore remote null
RESTORE B backup=A remote=null observed_owner=A expected_owner=null
00:00 +2: cross owner restore remote error
RESTORE B backup=A remote=error observed_owner=A expected_owner=null
00:00 +3: same owner restore control
RESTORE A backup=A remote=null observed_owner=A expected_owner=A
00:00 +4: checkForActiveWorkout cross owner remote null
CHECK B backup=A remote=null observed_owner=A expected_owner=null
00:00 +5: checkForActiveWorkout cross owner remote error
CHECK B backup=A remote=error observed_owner=A expected_owner=null
00:00 +6: checkForActiveWorkout same owner control
CHECK A backup=A remote=null observed_owner=A expected_owner=A
00:00 +7: All tests passed!
EXIT=0
```

**PASS** is reproduction of the observed behavior, not acceptance of it as correct.

## Final reconciliation — metadata-only disposal review (2026-10-28)

No successful probe was rerun in this reconciliation; the retained outputs above are dated evidence
from the prior continuation, not fresh runtime PASS. The orchestrator independently re-read the real
controller enqueue/restore/completion code. QA reviews source/setup read-only; synthetic identity
adoption is not live account disclosure, device storage behavior, or a server authorization bypass.
FND-CONC-001 is now narrowed to the queue cycle (P2/Confirmed/Accepted); the distinct post-await race
remains an A5 deferred investigation. FND-SEC-002 Confirmed scope is controller adoption only.

Directory inspected without file-content reads:
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028`.
Commands: `Get-Item -LiteralPath $p`; `Get-ChildItem -LiteralPath $p -Recurse -Force -File`;
metadata-only grouping, filename filtering and `Export-Csv`; reparse attributes enumerated separately.

Observed metadata: creation and last-write UTC `2026-10-28 10:11:09`; only top-level entry `app`;
1,351 files / 1,369,316,592 bytes; zero observed reparse points. Groups (file count): root files 11,
`.dart_tool` 204, `.idea` 5, android 48, assets 10, build 389, ios 45, lib 113, linux 129, macos 30,
test 15, web 7, windows 345. Names matching the limited secret/config filename filter were
`app/config.example.json` (177 bytes) and `app/.dart_tool/package_config.json` (29,990 bytes).
This is **not** a content scan or assurance that no secret is embedded elsewhere; none was opened.

Complete relative-path/size/time/attribute inventory (1,351 rows) is preserved externally at
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-final-backup-20261028-174845\probe-inventory.csv`.
The inventory contains metadata only and is not staged into Git. No broad Temp traversal/cleanup.

Ownership/disposal decision: path, creation time and prior tool transcript are consistent with the
task-created full-copy probe. Exclusivity and absence of later user additions cannot be proved from
metadata alone; no creation manifest or independent access log was retained. Therefore **disposal
safety is not established**, and the directory was not deleted. The operator must review this exact
path/inventory, confirm no wanted additions or data, and explicitly approve removal of this exact
task-created directory before an agent can act. No approval for bulk cleanup is implied. Original
repository, minimal probe copy and verified backups are outside that removal request.

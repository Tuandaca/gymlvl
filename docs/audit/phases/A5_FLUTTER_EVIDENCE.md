# A5 — Bounded Flutter test architecture and synthetic reliability evidence

**Task/date:** A5 only, 2026-10-28. **Author:** delegated flutter-specialist.
**Measured commit:** main `1763ab55e8da994bc1d854ad8fd2cd2299678b45`.
**Result:** PASS for finite audit execution/18 observation tests; the behavioral invariants identified
below FAIL in the stated synthetic schedules. Green observation tests are not fixes or product certification.
Registers, coverage and closure are owned by the orchestrator; this file proposes dispositions only.

## 1. Entry, ownership and boundaries

Entry `git status --porcelain=v1` showed exactly the five expected orchestrator-owned paths:
`docs/audit/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`,
`docs/planning/SESSION_HANDOFF.md`, `docs/planning/TASK_BOARD.md` and the new
`docs/audit/phases/A5_TEST_RELIABILITY.md`. Branch/HEAD were main/the SHA above. The primary already
verified the external backup (A5 phase2); this specialist did not modify those dirty paths.
Both this evidence path and `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028`
were absent before creation: `A5_FLUTTER_PATHS_ABSENT`. Ownership is restricted to those two new paths.

Loaded flutter-expert, systematic-debugging and test-driven-development. Read mandatory planning files
in order, then reused A2 lead dispositions and A4 section8/C6 rather than re-auditing all source.
Read all14 `app/test/*.dart` files completely (2,624 lines including blanks;13 default-discovered
`*_test.dart` files and one manual wrapper), the single CI workflow, and only source required by the
six inherited contracts. No whole-repository content scan or numerical coverage claim was made.
An initially guessed `data/exercise_repository.dart` path did not exist; read the actual seven-line
domain interface instead. This was an inspection correction, not a product failure.

Installed Flutter3.38.5/Dart3.10.4, http1.6.0, supabase2.10.4/gotrue2.19.0,
shared_preferences2.5.5/platform_interface2.4.2 were reused. No install, pub get, secret-file read,
live Auth/backend/provider, media, full-app copy, deletion, deployment, Git write, application,
permanent-test, configuration or dependency edit occurred. HTTP is intercepted by `MockClient` at
`http://a5.invalid`; no socket/backend assertion. The extractor's `fetch` is disabled/counts zero.
Synthetic session/workout/row IDs are not catalog IDs. All exercise IDs came from fresh seeded
PGlite catalog rows selected by actual `sync_daily_data`; none was invented or imported into the app.

## 2. C24 — Complete bounded test inventory (inspection, not a suite run)

- `adversarial_edge_test.dart` (444): static repository numeric guards, pure preview extremes,
  SetRow callbacks at320/390, fake Coach failures across locales/widths, shell fixtures. Despite its
  name this is not an Edge Function/gateway test. Reps1500/weight2500 assertions examine callbacks,
  not canonical visible text/rejection. Most fixtures use `AppTheme.darkTheme` compatibility alias.
- `auth_controller_test.dart` (158): actual AuthController with fake repository; one-flight sign-in,
  retries, registration/reset/update/signout error state. No forms/router, SDK callback or disposed
  operation completion. G1 below closes only the focused inherited synthetic recovery assertion.
- `auth_redirect_test.dart` (55): pure boolean redirect cases for loading/error/session/recovery;
  not actual refresh scheduling, async profile lookup, incoming URI/fragment or Auth allowlist tests.
- `candy_ui_test.dart` (619): **no production app import**. Defines its own palette,
  `TactileCandyButton` and `CandyCardWidget`, then tests those same reference implementations,
  contrast, press/loading and320/1.5x layout. Useful written specification, but cannot detect changes
  to production CandyButton/Card. Other files do render some real primitives; not zero real UI tests.
- `client_config_test.dart` (16): pure public-key allowlist guard; no initialization retry/network.
- `coach_controller_test.dart` (69): actual notifier/fake repository; empty/inflight/history count8,
  error retry. No accepted4001-character answer continuation or HTTP error/timeout decoding.
- `navigation_integration_test.dart` (261): real theme/banner/navigation primitive with overridden
  active notifier; route-tree enumeration and a lib-only Orbitron text assertion. The route test
  proves configured paths, **not navigation accessibility or authenticated traversal**; the lib-only
  font check does not cover pubspec/assets/platform config. No real workout timer/identity lifecycle.
- `progression_engine_test.dart` (103): pure client preview tables/caps/pace/level thresholds;
  not authoritative SQL progression or current client/server cross-language equivalence.
- `session_isolation_test.dart` (67): actual onboarding/recovery providers with synthetic Auth stream;
  same-user token refresh, changed-user draft reset, signout recovery reset. Does not test active
  workout storage-await identity races or prove real-account/RLS isolation.
- `ui_regression_test.dart` (415): real screens with provider/controller overrides, four widths and
  VI/EN,1.5x/short-height examples, safe auth/quest errors, onboarding step reachability. Optional
  `CAPTURE_UI` writes images but there is **no golden comparison**. Assertions are mostly no-exception/
  text-presence, not glyph raster correctness, contrast, semantic/tap bounds, focus, screen reader,
 200% text, or frame budgets. Auth override sets errors directly, bypassing the real controller.
- `verify_logic.dart` (4): manual import/forwarder to progression tests, not another default suite.
- `widget_test.dart` (38): real ConfigurationApp setup/failure/narrow rendering, not initialized app.
- `workout_controller_test.dart` (268): actual controller/fake repository; start dedup, setup/begin,
  elapsed pause math, double finish, failed finish, invalid values, queued edits, reload gate and
  pending-start provider invalidation. Fake implements no addSet/reorder/delete transport, no
  committed-lost ACK, no post-commit hydration and no post-storage-await identity schedule. It does
  not initialize SharedPreferences or assert backup outcomes; local exceptions are swallowed.
- `workout_widgets_test.dart` (107): real tile/delete callback and rest selector across widths/VI-EN,
  calendar date unit. Not controller-persisted edit/delete, time-based default paths, live rest
  timing/background, full summary or reordering.

CI `.github/workflows/verify.yml:10-52` runs separate SQL/Edge and Flutter analyze/test/web jobs, pinned
Flutter3.38.5, no format/codegen-drift/coverage/golden/Android/iOS/device or Flutter-to-gateway test
step. Existing TEST001 already owns platform/format/generated-code CI gaps; do not duplicate it.
Neither an absent coverage metric nor absent golden is by itself a product defect. Important bounded
regression gaps are actual transport contracts, operation-scoped auth state, late async identity/
dispose behavior, real Candy primitive activation and mode-specific controller/UI/server contracts.

## 3. Six groups — observed facts, controls and proposed reconciliation

### G1 — A2 Lead10, real AuthController + forms + actual router

Real login form submits a rejected synthetic sign-in; synthetic `passwordRecovery` Auth event drives
the actual appRouter to `/reset-password`. ResetPasswordScreen immediately renders
`Could not update your password. Retry or request a new recovery link.` with **zero update calls**.
Pristine recovery has no such error. Both paths then use the real Save password button: rejected
update shows the error/keeps recovery; successful update clears action error/recovery and leaves
the reset route. Expected no pre-submit update error: **FAIL** in the stale-error path.
Cause: shared AsyncError is reused across operations (`auth_providers.dart:65-115`, reset:29,84-94).
This is actual static widget output/state under synthetic Auth events, **not a live recovery link**.
Propose a **new P2/Confirmed synthetic client candidate**, Flutter/Auth owner, W2; do not merge with
INTG001's callback/allowlist contract. Operation-keyed state/reset-on-entry is a future option only.

### G2 — Separate CONC001 post-backup-await schedule

Gate SharedPreferences removal after successful completion/cancel repository response. Same-identity
completion succeeds. Reset-only while waiting returns null/no error and stays empty: the null-state
failure is caught, **not an uncaught crash**. If identity B starts a new workout before A's removal
resolves, A's completion **clears B's controller state** and returns A's completion; A's cancel also
clears B. Expected B retained: **FAIL**, both schedules. Auth event rebuilds the real same notifier;
no SEC002 cross-owner snapshot adoption or accepted active-discard enqueue cycle was rerun.
Cause: generation guard precedes `_clearLocalBackup` but not its await exit (controller659-670,
694-699). Propose a clearly separate scoped **CONC001 A5 addendum, P2/Confirmed synthetic**, Flutter
W1; retain original queue-cycle scope/history and distinguish these mechanisms. No server mutation
under B, real-account disclosure, irreversible DB loss or process crash is established.

### G3 — Actual repository HTTP addSet + modeled commit boundary

Actual controller/repository issue two identical INSERT bodies with set_number2 when first response
is lost **after modeled commit**: fake server rows `s1,s100,s101`/numbers`1,2,2`, local `s1,s101`.
Rejected-before-commit control ends with two rows`1,2`. Reload-before-retry sees the committed row
and sends3, retaining all three unique IDs/numbers`1,2,3`. After the first failure, completion is
blocked/no finish RPC. This proves repeated real request payloads/local divergence for the fixture;
the HTTP fixture deliberately permits both inserts and is **not SQL duplicate/XP proof**.
Baseline table210-219 has row PK but no per-exercise set_number unique constraint (inspection only).
Propose **new P2/High/Needs Verification transport-retry candidate**, Flutter/Supabase W1, with
gateway/SQL confirmation deferred; do not merge with legacy DATA001. Future regression: explicit
commit/lost-response versus rejected write, reload/retry, reconcile local row IDs, no assumed retry.

### G4 — Actual sequential reorder and legitimate zero-row delete

Move e3 to0: local optimistic order`e3,e1,e2`; first HTTP update commits e3=0, second returns400.
Server mapping becomes e1=0/e2=1/e3=0; local stays optimistic with`save_failed`. Reload adopts server
mapping/observed tie order`e1,e3,e2`. All-success control sends three updates and reload matches the
intended order. No tie-order guarantee is claimed. Propose **new P2/High/Needs Verification partial
reorder candidate**, Flutter/Supabase W1; actual nontransactional repository sequence confirmed,
partial server persistence remains modeled, no XP consequence. No backend transaction patch here.

Delete of an already-absent owned row returns204, legitimately removes stale local row, no error.
Explicit403 control retains local row and sets`save_failed`. Do **not** turn zero affected rows into
an unauthorized bypass finding. RLS-hidden foreign rows/gateway semantics remain unexecuted; this
fake does not decide authorization or conflate an idempotent delete with hidden data.

### G5 — INTG002 post-award hydration and elapsed fields

Actual SupabaseWorkoutRepository sends completion RPC then detail SELECT. Synthetic commit + lost
hydrate or null hydrate yields controller`completion_failed`, null result, retained active local
session. Retry with successful hydrate consumes replay reward; modeled commit count stays1 while
RPC attempts2. Success control returns hydrated workout duration7 and rewards5, but controller
summary duration120 is its local elapsed. This second field split is an **observation**, not a new
duration/XP defect absent approved summary semantics; the active screen snapshots local elapsed too.
Propose **INTG002 scoped evidence addendum, P2/Confirmed synthetic client error mapping**, Flutter W1.
Idempotency, commit and exact rewards are supplied by fake transport, **not newly tested SQL**.

### G6 — Actual generated JSON -> real Dart model/controller/repository payloads

Fresh catalog150 and actual `sync_daily_data` with deterministic seeded full_body template produce
Ab Wheel Rollout(carry), Arnold Press and Back Extension, all3x12. QuestInstance.fromJson/startQuest
run in Dart. Recorded actual INSERTs: timed target3x(reps0,duration30); rep targets3x(reps12,no
duration field). Ordinary addExercise defaults independently show timed0/30 versus rep10/0.
All9 sets can be marked completed; real update payload leaves timed reps0, model.isValid=true, zero
sets satisfy required reps12 in a **local predicate count**. Completion reaches the real repository
RPC payload; its fixture22023 rejection maps to`completion_failed`. It is intentionally a **fake
rejection**, not a SQL gateway run, and is never bypassed or rewritten to make the journey succeed.
Positive-rep control is an explicitly separate synthetic update/success-response fixture.

Actual Add Set call used by active-screen531 adds timed set4 with hidden reps10/duration0; marking
complete is accepted. Keep **INTG004** (Add Set defaults/hidden reps), **INTG005** (server rejects
CHECK-valid timed completed sets; A4 SQL evidence only), and **INTG007** (generated prescription versus
timed defaults) distinct. Propose actual-Dart evidence addenda to004/007, owner Flutter/catalog W2,
without automatically promoting their full UI/SQL journey status. There is no duration-prescription
field in the Dart prescription model. All IDs/provenance retained below. No exercise-science
judgment, catalog edit, fabricated UUID, award-path bypass or live account was used.

### Test-architecture proposal and residual checks

Consider a **new P3/High test-quality candidate**, Flutter/QA W3: Candy specification-clone tests
cannot catch changes to the corresponding production primitives (candy test imports/definitions
and own-class expectations above). No production behavior is disproved by these self-contained
tests; allocate only if the register includes test quality gaps. Keep separate from TEST001 CI gates.

NOT RUN: full126 suite (orchestrator runs once); live callback URI/fragment/confirmation, pending
profile escape/retry policy, Auth operation completion after dispose, Coach4001 continuation,
unknown/malformed summary rewards, post-frame dispose and measured1Hz rebuild budgets. Finite
assertions/owners: Flutter/QA next authorized regression task must hold profile Future pending and
exercise retry/signout, complete auth after dispose with no ref-after-dispose, send4001 answer then
next request, mount/remove before callback with no async exception, compare shell rebuilds over a
fixed interval against an approved budget. UI agent owns keyboard/tap bounds/200% VI-EN/glyph checks;
device screen-reader/frame budgets need a supported device and approved budget, not guessed limits.
Full RLS/JWT/gateway transport and independent SQL scheduling belong to backend/QA's separately
bounded A5 work; fake HTTP cannot satisfy them. These gaps do not authorize remediation or A6.

## 4. Exact commands, original failures and corrections

All Flutter commands ran from `D:\Projects\gymlvl\app`, Node from repository root. Paths abbreviated
only in this explanation; executable commands below use the literal external path. Each Tee-Object
log preserves output; wrapper exit markers are printed after the log, not inside its SHA256.

```powershell
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\extract.mjs' 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\extract.log'; $c=$LASTEXITCODE; Write-Output "EXTRACT_EXIT=$c"; exit $c
flutter test --no-pub --reporter expanded 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\a5_probe_test.dart' 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\run-01.log'; $c=$LASTEXITCODE; Write-Output "FLUTTER_PROBE_EXIT=$c"; exit $c
flutter test --no-pub --reporter expanded 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\diagnostic_test.dart' 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\a5_probe_test.dart' --name 'one direct transport diagnostic|G1' 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\diagnostic.log'; $c=$LASTEXITCODE; Write-Output "DIAGNOSTIC_EXIT=$c"; exit $c
flutter test --no-pub --reporter expanded 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\a5_probe_test.dart' 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\run-02.log'; $c=$LASTEXITCODE; Write-Output "FLUTTER_PROBE_EXIT=$c"; exit $c
flutter test --no-pub --reporter expanded 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\a5_probe_test.dart' --name G1 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\g1-widget-success.log'; $c=$LASTEXITCODE; Write-Output "G1_WIDGET_SUCCESS_EXIT=$c"; exit $c
flutter test --no-pub --reporter expanded 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\a5_probe_test.dart' 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\run-03-final.log'; $c=$LASTEXITCODE; Write-Output "FINAL_FLUTTER_PROBE_EXIT=$c"; exit $c
flutter analyze --no-pub 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-flutter-20261028\analyze.log'; $c=$LASTEXITCODE; Write-Output "ANALYZE_EXIT=$c"; exit $c
```

- Extractor first run PASS: `EXTRACT_PASS catalog=150 targets=3 fresh_seed_runtime_ids=3 fetches=0`,
  `EXTRACT_EXIT=0`. No extractor revision/rerun.
- Probe run01 **FAIL**: `+0 -18: Some tests failed.`, `FLUTTER_PROBE_EXIT=1`. G1 twice found0
  ResetPasswordScreen; G2 four storage-entry timeouts2s; G3 three empty-list errors; G4 two empty
  order assertions/two empty-list errors; G5 three expected1/actual0 commits; G6 startup false and
  empty-list error. These were harness setup failures, not18 product defects; no passing run hidden.
- One diagnostic **FAIL**: direct real repository start throws `Null check operator used on a null
  value`, `PostgrestBuilder._parseResponse ... postgrest_builder.dart:186:27`, with actual
  `POST /rest/v1/rpc/start_workout` recorded. Installed parser dereferences `response.request!`;
  MockClient Response lacked that required request. G1 diagnostic still showed signedOut,
  recoveryfalse and `/login`: externally read router's dependencies were paused without listeners.
  Result`+0 -3: Some tests failed.`, `DIAGNOSTIC_EXIT=1`. No further diagnostic hunt was needed.
- Corrected only external harness: `Server.transport` attaches originating request to synthetic
  responses; Harness uses it instead of s.handle; G1 keeps appRouter/Auth stream listened while
  externally reading router. No product guard/state change or assertion weakening. Run02 PASS:
  `+18: All tests passed!`, `FLUTTER_PROBE_EXIT=0`; observations preserved in section3/final output.
- Strengthened successful G1 control from direct real-controller submit to actual Save password
  button; narrow G1 PASS`+2: All tests passed!`, `G1_WIDGET_SUCCESS_EXIT=0`. Final full bounded18
  run verifies the retained source: `+18: All tests passed!`, `FINAL_FLUTTER_PROBE_EXIT=0`.
- Analyzer PASS: `No issues found! (ran in 2.5s)`, `ANALYZE_EXIT=0`. It analyzes the app, not an
  assertion that the external probe follows every lint policy. No full permanent suite was rerun.

For original probe reconstruction, remove the final source's Server.transport method, use
`MockClient(s.handle)`, remove the two G1 c.listen lines and G1 diagnostic obs, and replace successful
Save-button tap with `await c.read(authControllerProvider.notifier).updatePassword('new-password');`.
The diagnostic version adds only G1 diagnostic obs. Run02 has transport/listeners corrected but the
direct-controller success control. All later behavior checks remain unchanged.

## 5. Full setup/extraction source — extract.mjs

```javascript
import assert from 'node:assert/strict';
import { readFile, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { pathToFileURL } from 'node:url';
const root = 'D:/Projects/gymlvl';
const out = 'C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a5-flutter-20261028';
let fetches = 0;
globalThis.fetch = async () => { fetches++; throw Error('No network allowed'); };
const { PGlite } = await import(pathToFileURL(root + '/tools/db-tests/node_modules/@electric-sql/pglite/dist/index.js'));
const { pgcrypto } = await import(pathToFileURL(root + '/tools/db-tests/node_modules/@electric-sql/pglite/dist/contrib/pgcrypto.js'));
const paths = ['tools/db-tests/bootstrap.sql', 'supabase/migrations/20261026000100_baseline.sql', 'supabase/migrations/20261026000200_authoritative_progression.sql', 'supabase/migrations/20261027000100_exercise_catalog_metadata.sql', 'supabase/seed.sql', 'supabase/seed_exercises.sql'];
const db = new PGlite({ extensions: { pgcrypto } });
try {
  for (const path of paths) {
    const b = await readFile(root + '/' + path);
    console.log('SOURCE ' + JSON.stringify({path, sha256:createHash('sha256').update(b).digest('hex')}));
    await db.exec(b.toString('utf8'));
  }
  assert.equal((await db.query('SELECT count(*)::integer n FROM public.exercises')).rows[0].n, 150);
  await db.exec('BEGIN');
  const uid = 'a5555555-5555-4555-8555-555555555555'; // Synthetic user, not catalog ID.
  await db.query("INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES($1,'a5@example.test','{}')", [uid]);
  await db.query("SELECT set_config('request.jwt.claim.sub',$1,true),set_config('request.jwt.claims',$2,true)", [uid, JSON.stringify({sub:uid,role:'authenticated'})]);
  const profile = {environment:'home',goals:['hypertrophy'],experience_level:'beginner',age:25,gender:'other',height_cm:170,weight_kg:65,weekly_gym_days:0,weekly_home_days:3,preferred_training_days:['mon','wed','fri'],primary_class_id:'B',timezone:'Asia/Ho_Chi_Minh'};
  await db.exec('SET LOCAL ROLE authenticated');
  await db.query('SELECT public.initialize_user($1::jsonb)', [JSON.stringify(profile)]);
  await db.exec('RESET ROLE');
  // Same deterministic template selection as retained A4 C6; do not change catalog or functions.
  await db.exec("UPDATE public.quests SET type='a5_fixture_unused' WHERE category<>'full_body'");
  await db.exec('SET LOCAL ROLE authenticated');
  const generated = (await db.query('SELECT public.sync_daily_data() AS v')).rows[0].v;
  await db.exec('RESET ROLE');
  assert.equal(generated.quest.prescribed_config.length, 3);
  const catalog = (await db.query('SELECT id,name,category,equipment,force_type,movement_pattern,slug FROM public.exercises WHERE id = ANY($1::uuid[]) ORDER BY slug', [generated.quest.prescribed_config.map(t=>t.exercise_id)])).rows;
  assert.equal(catalog.length, 3);
  assert.equal(catalog.filter(e=>e.movement_pattern==='carry').length, 1);
  const fixture = {provenance:'Fresh seeded PGlite IDs, actual sync_daily_data output; deterministic full_body selection only, no catalog or RPC mutation', quest:generated.quest, catalog};
  await writeFile(out + '/generated.json', JSON.stringify(fixture,null,2)+'\n');
  console.log('GENERATED ' + JSON.stringify(fixture));
  await db.exec('ROLLBACK');
  assert.equal(fetches,0);
  console.log('EXTRACT_PASS catalog=150 targets=3 fresh_seed_runtime_ids=3 fetches=0');
} finally { await db.close(); }
```

## 6. Full retained diagnostic source — diagnostic_test.dart (intentionally failing old response setup)

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/features/workout/data/supabase_workout_repository.dart';
import 'a5_probe_test.dart' as p;
void main() {
 test('one direct transport diagnostic',() async {
   final s=p.Server(p.fixture());
   final client=SupabaseClient('http://a5.invalid','sb_publishable_synthetic',httpClient:MockClient(s.handle),authOptions:const AuthClientOptions(autoRefreshToken:false));
   await client.auth.setInitialSession(jsonEncode(p.session('A').toJson()));
   try { print('DIRECT_START ${await SupabaseWorkoutRepository(client).startWorkout()}'); }
   catch(e,st) { print('DIRECT_ERROR $e\n$st'); rethrow; }
   finally { print('DIRECT_REQUESTS ${s.requests}'); await client.dispose(); }
 });
}
```

## 7. Full final probe source — a5_probe_test.dart

```dart
// Audit-only observations. No product repair or authoritative backend claims.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app/core/localization/localization_engine.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/theme/candy_theme.dart';
import 'package:app/features/auth/domain/auth_repository.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:app/features/quests/domain/quest_instance.dart';
import 'package:app/features/workout/data/supabase_workout_repository.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/exercise_repository.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/controllers/active_workout_controller.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const external = 'C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a5-flutter-20261028';
final generated = jsonDecode(File('$external/generated.json').readAsStringSync()) as Map<String, dynamic>;
final catalog = (generated['catalog'] as List).map((e) => Exercise.fromJson(Map<String, dynamic>.from(e as Map))).toList();
void obs(String name, Object? data) => print('OBS $name ${jsonEncode(data)}');
Session session(String id) => Session(accessToken:'a5-synthetic-token', tokenType:'bearer', user:User(id:id, appMetadata:{}, userMetadata:{}, aud:'authenticated', createdAt:'2026-10-28T00:00:00Z'));
class English extends LocalizationModeNotifier {
  @override AppLangMode build() => AppLangMode.en;
}
class AuthFake extends Fake implements AuthRepository {
  final events = StreamController<AuthState>.broadcast();
  int signIns=0, updates=0;
  bool rejectUpdate=false;
  @override Stream<AuthState> get authStateChange => events.stream;
  @override User? get currentUser => null;
  @override Future<void> signInWithEmail(String email, String password) async { signIns++; throw const AuthException('synthetic invalid credentials'); }
  @override Future<void> updatePassword(String password) async { updates++; if(rejectUpdate) throw const AuthException('synthetic rejection'); }
}
class GateStore extends InMemorySharedPreferencesStore {
  GateStore():super.empty();
  Completer<void>? gate, entered;
  void arm() { gate=Completer<void>(); entered=Completer<void>(); }
  @override Future<bool> remove(String key) async {
    if (gate != null && !entered!.isCompleted) { entered!.complete(); await gate!.future; }
    return super.remove(key);
  }
}
class Catalog extends Fake implements ExerciseRepository {
  @override Future<List<Exercise>> getExercises() async => catalog;
}
Workout fixture({String owner='A', bool setup=false, int count=1}) {
  final now=DateTime.now().toUtc();
  return Workout(id:'w-$owner',userId:owner,startedAt:now.subtract(const Duration(seconds:120)),trainingStartedAt:setup?null:now.subtract(const Duration(seconds:120)),pausedAt:setup?null:now,exercises:List.generate(count,(i)=>WorkoutExercise(id:'e${i+1}',workoutId:'w-$owner',exerciseId:catalog[i%catalog.length].id,exercise:catalog[i%catalog.length],orderIndex:i,sets:[WorkoutSet(id:'s${i+1}',workoutExerciseId:'e${i+1}',setNumber:1,reps:12,isCompleted:true)])));
}

// Finite synthetic PostgREST/RPC transport. Models commits independently of responses.
// It does not execute RLS, SQL constraints, reward arithmetic, or real Auth.
class Server {
  Server(this.w);
  Workout w;
  String insertMode='ok', hydrateMode='ok', completionMode='ok', deleteMode='ok';
  int nextId=100, insertCalls=0, reorderCalls=0, failReorderAt=0, finishes=0, awardCommits=0;
  bool awarded=false;
  final requests=<Map<String,dynamic>>[];
  List<WorkoutSet> get sets => w.exercises.expand((e)=>e.sets).toList();
  void replaceExercise(WorkoutExercise updated) { w=w.copyWith(exercises:w.exercises.map((e)=>e.id==updated.id?updated:e).toList()); }
  http.Response json(Object? value, [int status=200]) => http.Response(jsonEncode(value),status,headers:{'content-type':'application/json'});
  http.Response error(String message, [int status=400, String code='A5_FIXTURE']) => json({'message':message,'code':code,'details':null,'hint':null},status);
  Future<http.Response> transport(http.Request r) async {
    final response=await handle(r);
    return http.Response.bytes(response.bodyBytes,response.statusCode,headers:response.headers,request:r);
  }
  Future<http.Response> handle(http.Request r) async {
    final p=r.url.path; final method=r.method;
    final body=r.body.isEmpty?null:jsonDecode(r.body);
    requests.add({'method':method,'path':p,'query':r.url.queryParameters,'body':body});
    if (p.endsWith('/rpc/start_workout')) return json(w.toJson());
    if (p.endsWith('/rpc/begin_workout')) { w=w.copyWith(trainingStartedAt:DateTime.now().toUtc()); return json(w.toJson()); }
    if (p.endsWith('/rpc/cancel_workout')) { w=w.copyWith(status:WorkoutStatus.cancelled); return json(null); }
    if (p.endsWith('/rpc/complete_workout')) {
      finishes++;
      if (completionMode=='reject') return error('Invalid workout measurements',400,'22023');
      if (!awarded) { awarded=true; awardCommits++; }
      w=w.copyWith(status:WorkoutStatus.completed,durationSeconds:7,completedAt:DateTime.now().toUtc());
      return json({'earnedXP':5,'durationSeconds':7,'isQuest':false});
    }
    if (p.endsWith('/workouts') && method=='GET') {
      if (hydrateMode=='error') throw http.ClientException('synthetic hydrate lost');
      if (hydrateMode=='null') return json(null);
      return json(w.toJson());
    }
    if (p.endsWith('/workout_exercises') && method=='POST') {
      final b=Map<String,dynamic>.from(body as Map);
      final ex=WorkoutExercise(id:'e${nextId++}',workoutId:b['workout_id'] as String,exerciseId:b['exercise_id'] as String,orderIndex:b['order_index'] as int,exercise:catalog.firstWhere((e)=>e.id==b['exercise_id']));
      w=w.copyWith(exercises:[...w.exercises,ex]); return json(ex.toJson(),201);
    }
    if (p.endsWith('/workout_exercises') && method=='PATCH') {
      reorderCalls++;
      if (reorderCalls==failReorderAt) return error('synthetic second update rejected');
      final id=r.url.queryParameters['id']!.substring(3);
      replaceExercise(w.exercises.firstWhere((e)=>e.id==id).copyWith(orderIndex:(body as Map)['order_index'] as int));
      return http.Response('',204);
    }
    if (p.endsWith('/workout_sets') && method=='GET') return json(null); // Historical suggestion absent.
    if (p.endsWith('/workout_sets') && method=='POST') {
      insertCalls++;
      if (insertMode=='reject') { insertMode='ok'; throw http.ClientException('synthetic rejection before commit'); }
      final b=Map<String,dynamic>.from(body as Map);
      final ex=w.exercises.firstWhere((e)=>e.id==b['workout_exercise_id']);
      final set=WorkoutSet.fromJson({...b,'id':'s${nextId++}'});
      replaceExercise(ex.copyWith(sets:[...ex.sets,set]));
      if (insertMode=='lost') { insertMode='ok'; throw http.ClientException('synthetic committed response lost'); }
      return json(set.toJson(),201);
    }
    if (p.endsWith('/workout_sets') && method=='PATCH') {
      final id=r.url.queryParameters['id']!.substring(3);
      final ex=w.exercises.firstWhere((e)=>e.sets.any((s)=>s.id==id));
      final old=ex.sets.firstWhere((s)=>s.id==id);
      final set=WorkoutSet.fromJson({...old.toJson(),...Map<String,dynamic>.from(body as Map)});
      replaceExercise(ex.copyWith(sets:ex.sets.map((s)=>s.id==id?set:s).toList())); return json(set.toJson());
    }
    if (p.endsWith('/workout_sets') && method=='DELETE') {
      if (deleteMode=='forbidden') return error('synthetic forbidden',403,'42501');
      final id=r.url.queryParameters['id']!.substring(3);
      w=w.copyWith(exercises:w.exercises.map((e)=>e.copyWith(sets:e.sets.where((s)=>s.id!=id).toList())).toList());
      return http.Response('',204); // Also legitimate when the owned row is already absent.
    }
    throw StateError('UNEXPECTED_REQUEST $method $p');
  }
}
class Harness {
  Harness(this.server,this.client,this.c,this.events);
  final Server server; final SupabaseClient client; final ProviderContainer c; final StreamController<AuthState> events;
  ActiveWorkoutController get ctrl => c.read(activeWorkoutControllerProvider.notifier);
  ActiveWorkoutState get state => c.read(activeWorkoutControllerProvider);
  static Future<Harness> create(Workout workout) async {
    final s=Server(workout);
    final client=SupabaseClient('http://a5.invalid','sb_publishable_synthetic',httpClient:MockClient(s.transport),authOptions:const AuthClientOptions(autoRefreshToken:false));
    await client.auth.setInitialSession(jsonEncode(session(workout.userId).toJson()));
    final events=StreamController<AuthState>.broadcast();
    final c=ProviderContainer(overrides:[authStateStreamProvider.overrideWith((ref)=>events.stream),workoutRepositoryProvider.overrideWithValue(SupabaseWorkoutRepository(client)),exerciseRepositoryProvider.overrideWithValue(Catalog())]);
    final h=Harness(s,client,c,events);
    c.listen(activeWorkoutControllerProvider,(_,_){});
    await h.identity(workout.userId);
    addTearDown(() async { c.dispose(); await events.close(); await client.dispose(); });
    return h;
  }
  Future<void> identity(String id) async {
    events.add(AuthState(AuthChangeEvent.signedIn,session(id)));
    await c.pump(); await Future<void>.delayed(Duration.zero); await c.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(()=>SharedPreferences.setMockInitialValues({}));

  group('G1 real AuthController router and reset screen',(){
    for (final stale in [false,true]) {
      testWidgets('recovery entry staleSignIn=$stale with rejected and successful submit controls',(tester) async {
        final repo=AuthFake();
        final c=ProviderContainer(overrides:[authRepositoryProvider.overrideWithValue(repo),localizationModeProvider.overrideWith(English.new),currentUserProvider.overrideWith((ref) async => null)]);
        addTearDown(() async { c.dispose(); await repo.events.close(); });
        // Keep the externally-read router's dependencies active under Riverpod 3 pausing.
        c.listen(appRouterProvider,(_,_){});
        c.listen(authStateStreamProvider,(_,_){});
        final router=c.read(appRouterProvider);
        await tester.pumpWidget(UncontrolledProviderScope(container:c,child:MaterialApp.router(theme:CandyTheme.theme,routerConfig:router,locale:const Locale('en'),supportedLocales:const [Locale('en'),Locale('vi')],localizationsDelegates:GlobalMaterialLocalizations.delegates)));
        repo.events.add(AuthState(AuthChangeEvent.signedOut,null)); await tester.pumpAndSettle();
        await c.read(authControllerProvider.future);
        if (stale) {
          await tester.enterText(find.byType(TextFormField).at(0),'a5@example.test');
          await tester.enterText(find.byType(TextFormField).at(1),'wrong-password');
          await tester.tap(find.widgetWithText(FilledButton,'Sign in')); await tester.pumpAndSettle();
          expect(repo.signIns,1); expect(c.read(authControllerProvider).hasError,isTrue);
        }
        repo.events.add(AuthState(AuthChangeEvent.passwordRecovery,session('A'))); await tester.pumpAndSettle();
        obs('G1/diagnostic',{'auth':c.read(authStateStreamProvider).toString(),'profile':c.read(currentUserProvider).toString(),'recovery':c.read(passwordRecoveryProvider),'route':router.routeInformationProvider.value.uri.path});
        expect(find.byType(ResetPasswordScreen),findsOneWidget); expect(repo.updates,0);
        final premature=find.textContaining('Could not update your password.');
        expect(premature,stale?findsOneWidget:findsNothing);
        obs('G1/entry',{'failedSignIn':stale,'prematureUpdateError':stale,'updateCalls':repo.updates,'route':router.routeInformationProvider.value.uri.path});
        await tester.enterText(find.byType(TextFormField).at(0),'new-password');
        await tester.enterText(find.byType(TextFormField).at(1),'new-password');
        repo.rejectUpdate=true;
        await tester.tap(find.widgetWithText(FilledButton,'Save password')); await tester.pumpAndSettle();
        expect(repo.updates,1); expect(premature,findsOneWidget); expect(c.read(passwordRecoveryProvider),isTrue);
        repo.rejectUpdate=false;
        await tester.tap(find.widgetWithText(FilledButton,'Save password')); await tester.pumpAndSettle();
        expect(repo.updates,2); expect(c.read(authControllerProvider).hasError,isFalse); expect(c.read(passwordRecoveryProvider),isFalse);
        await tester.pumpAndSettle(); expect(find.byType(ResetPasswordScreen),findsNothing);
        expect(tester.takeException(),isNull);
        obs('G1/controls',{'failedSignIn':stale,'rejectedShowsError':true,'successClearsErrorAndRecovery':true});
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  });

  group('G2 post-backup-await identity race (not discard queue cycle)',(){
    for (final mode in ['same','reset','new']) {
      test('completion backup remove identity=$mode',() async {
        final h=await Harness.create(fixture()); await h.ctrl.startWorkout();
        final store=GateStore(); SharedPreferencesStorePlatform.instance=store; store.arm();
        final pending=h.ctrl.completeWorkout(); await store.entered!.future.timeout(const Duration(seconds:2));
        expect(h.server.awarded,isTrue);
        if (mode!='same') await h.identity('B');
        if (mode=='new') { h.server.w=fixture(owner:'B'); await h.ctrl.startWorkout(); expect(h.state.workout?.userId,'B'); }
        store.gate!.complete(); final result=await pending.timeout(const Duration(seconds:2));
        if (mode=='same') { expect(result,isNotNull); expect(h.state.workout,isNull); }
        if (mode=='reset') { expect(result,isNull); expect(h.state.workout,isNull); expect(h.state.errorMessage,isNull); }
        if (mode=='new') { expect(result?['workout'],isA<Workout>()); expect((result!['workout'] as Workout).userId,'A'); expect(h.state.workout,isNull); }
        obs('G2/complete/$mode',{'resultOwner':(result?['workout'] as Workout?)?.userId,'remainingOwner':h.state.workout?.userId,'error':h.state.errorMessage,'newIdentityErased':mode=='new'});
      });
    }
    test('cancel backup remove erases a new user workout',() async {
      final h=await Harness.create(fixture()); await h.ctrl.startWorkout();
      final store=GateStore(); SharedPreferencesStorePlatform.instance=store; store.arm();
      final pending=h.ctrl.cancelWorkout(); await store.entered!.future.timeout(const Duration(seconds:2));
      await h.identity('B'); h.server.w=fixture(owner:'B'); await h.ctrl.startWorkout(); expect(h.state.workout?.userId,'B');
      store.gate!.complete(); await pending.timeout(const Duration(seconds:2));
      expect(h.state.workout,isNull); expect(h.state.errorMessage,isNull);
      obs('G2/cancel/new',{'newIdentityErased':true,'error':h.state.errorMessage});
    });
  });

  group('G3 actual addSet transport with modeled commit boundary',(){
    for (final mode in ['lost','reject','lost-reload']) {
      test('addSet $mode',() async {
        final h=await Harness.create(fixture()); await h.ctrl.startWorkout();
        h.server.insertMode=mode.startsWith('lost')?'lost':'reject';
        await h.ctrl.addSet('e1');
        expect(h.state.errorMessage,'save_failed'); expect(h.state.exercises.single.sets.length,1);
        expect(h.server.sets.length,mode=='reject'?1:2);
        expect(await h.ctrl.completeWorkout(),isNull); expect(h.server.finishes,0);
        if(mode=='lost-reload') await h.ctrl.checkForActiveWorkout();
        await h.ctrl.addSet('e1');
        final nums=h.server.sets.map((s)=>s.setNumber).toList();
        expect(nums,mode=='lost'?[1,2,2]:mode=='reject'?[1,2]:[1,2,3]);
        expect(h.server.sets.map((s)=>s.id).toSet().length,h.server.sets.length);
        final local=h.state.exercises.single.sets;
        expect(local.length,mode=='lost-reload'?3:2);
        obs('G3/$mode',{'serverIDs':h.server.sets.map((s)=>s.id).toList(),'serverNumbers':nums,'localIDs':local.map((s)=>s.id).toList(),'localNumbers':local.map((s)=>s.setNumber).toList(),'httpInsertCalls':h.server.insertCalls,'payloads':h.server.requests.where((r)=>r['method']=='POST'&&(r['path'] as String).endsWith('/workout_sets')).map((r)=>r['body']).toList()});
      });
    }
  });

  group('G4 actual reorder and legitimate delete transports',(){
    for (final fail in [true,false]) {
      test('reorder second update fail=$fail',() async {
        final h=await Harness.create(fixture(count:3)); await h.ctrl.startWorkout(); h.server.failReorderAt=fail?2:0;
        await h.ctrl.reorderExercises(2,0);
        expect(h.state.exercises.map((e)=>e.id).toList(),['e3','e1','e2']);
        final before={for(final e in h.server.w.exercises)e.id:e.orderIndex};
        expect(before,fail?{'e1':0,'e2':1,'e3':0}:{'e1':1,'e2':2,'e3':0});
        expect(h.state.errorMessage,fail?'save_failed':null);
        await h.ctrl.checkForActiveWorkout();
        expect({for(final e in h.state.exercises)e.id:e.orderIndex},before);
        obs('G4/reorder/$fail',{'serverOrderIndices':before,'reloadedIDs':h.state.exercises.map((e)=>e.id).toList(),'httpUpdates':h.server.reorderCalls,'duplicateServerOrder':fail});
      });
    }
    for(final forbidden in [false,true]) {
      test('delete already absent owned row forbidden=$forbidden',() async {
        final h=await Harness.create(fixture()); await h.ctrl.startWorkout();
        if (forbidden) {h.server.deleteMode='forbidden';} else {h.server.w=h.server.w.copyWith(exercises:[h.server.w.exercises.single.copyWith(sets:[])]);}
        await h.ctrl.deleteSet('e1','s1');
        expect(h.state.exercises.single.sets.length,forbidden?1:0); expect(h.state.errorMessage,forbidden?'save_failed':null);
        obs('G4/delete',{'forbiddenResponse':forbidden,'localCount':h.state.exercises.single.sets.length,'error':h.state.errorMessage});
      });
    }
  });

  group('G5 actual finish repository committed RPC then hydrate',(){
    for(final mode in ['error','null','ok']) {
      test('hydrate $mode',() async {
        final h=await Harness.create(fixture()); await h.ctrl.startWorkout(); final localElapsed=h.state.elapsedSeconds;
        h.server.hydrateMode=mode; final first=await h.ctrl.completeWorkout();
        expect(h.server.awardCommits,1); expect(h.server.finishes,1);
        if(mode!='ok') {
          expect(first,isNull); expect(h.state.hasActiveWorkout,isTrue); expect(h.state.errorMessage,'completion_failed');
          h.server.hydrateMode='ok'; final retry=await h.ctrl.completeWorkout(); expect(retry,isNotNull); expect(h.server.awardCommits,1); expect(h.server.finishes,2);
          obs('G5/$mode',{'commitCount':h.server.awardCommits,'rpcAttempts':h.server.finishes,'firstReportedFailure':true,'retryReward':retry!['xpResult'],'retrySummarySeconds':retry['durationSeconds'],'authoritativeSeconds':(retry['workout'] as Workout).durationSeconds});
        } else {
          expect(first,isNotNull); expect((first!['workout'] as Workout).durationSeconds,7); expect(first['durationSeconds'],localElapsed); expect(localElapsed,120);
          obs('G5/ok',{'localSummarySeconds':first['durationSeconds'],'hydratedWorkoutSeconds':(first['workout'] as Workout).durationSeconds,'rpcReward':first['xpResult']});
        }
      });
    }
  });

  group('G6 actual generated quest decoded into real Dart controller',(){
    test('quest startup update completion and Add Set payload separation',() async {
      final quest=QuestInstance.fromJson(Map<String,dynamic>.from(generated['quest'] as Map));
      final h=await Harness.create(fixture(setup:true).copyWith(exercises:[]));
      expect(await h.ctrl.startQuest(quest),isTrue);
      expect(h.state.exercises.length,3); expect(h.server.sets.length,9);
      final timed=h.state.exercises.singleWhere((e)=>e.exercise!.isTimeBased);
      expect(timed.exercise!.slug,'ab-wheel-rollout'); expect(quest.config.singleWhere((p)=>p.exerciseId==timed.exerciseId).reps,12);
      expect(timed.sets.every((s)=>s.reps==0&&s.durationSeconds==30),isTrue);
      final reps=h.state.exercises.where((e)=>!e.exercise!.isTimeBased).toList();
      expect(reps.every((e)=>e.sets.every((s)=>s.reps==12&&s.durationSeconds==0)),isTrue);
      await h.ctrl.beginTraining();
      for(final ex in [...h.state.exercises]) {
        for(final set in ex.sets) await h.ctrl.updateSet(ex.id,set.id,isCompleted:true);
      }
      expect(h.state.completedSets,9);
      final timedSaved=h.server.w.exercises.singleWhere((e)=>e.id==timed.id);
      expect(timedSaved.sets.where((s)=>s.isCompleted&&s.reps>=12).length,0);
      expect(timedSaved.sets.every((s)=>s.isValid),isTrue);
      h.server.completionMode='reject'; expect(await h.ctrl.completeWorkout(),isNull); expect(h.state.errorMessage,'completion_failed'); expect(h.server.finishes,1);
      final initialBodies=h.server.requests.where((r)=>r['method']=='POST'&&(r['path'] as String).endsWith('/workout_sets')).map((r)=>r['body']).toList();
      obs('G6/quest',{'questID':quest.id,'catalogIDs':catalog.map((e)=>e.id).toList(),'timedSlug':timed.exercise!.slug,'requiredReps':12,'actualInitialPayloads':initialBodies,'completedZeroRepTimedSets':timedSaved.sets.length,'rpcRejectionIsFixtureNotSQL':true,'finishRPC':h.server.requests.lastWhere((r)=>(r['path'] as String).endsWith('/rpc/complete_workout'))['body']});
      h.ctrl.clearError(); await h.ctrl.addSet(timed.id); final added=h.state.exercises.singleWhere((e)=>e.id==timed.id).sets.last;
      expect(added.reps,10); expect(added.durationSeconds,0);
      await h.ctrl.updateSet(timed.id,added.id,isCompleted:true);
      expect(h.server.sets.singleWhere((s)=>s.id==added.id).isCompleted,isTrue); expect(added.copyWith(isCompleted:true).isValid,isTrue);
      obs('G6/AddSet',{'setNumber':added.setNumber,'hiddenReps':added.reps,'displayDuration':added.durationSeconds,'clientAcceptedCompletion':true});
      // Positive-rep transport control only: not a remedy, not SQL quest eligibility verification.
      for(final s in timedSaved.sets) await h.ctrl.updateSet(timed.id,s.id,reps:12);
      h.server.completionMode='ok'; expect(await h.ctrl.completeWorkout(),isNotNull); expect(h.server.awardCommits,1);
      obs('G6/control',{'positiveRepUpdatePayloadSent':true,'fixtureSuccessConsumed':true,'sqlOrGatewayE2E':false});
    });
    test('unprescribed addExercise default timed and rep controls',() async {
      final h=await Harness.create(fixture(setup:true).copyWith(exercises:[])); await h.ctrl.startWorkout();
      await h.ctrl.addExercise(catalog.firstWhere((e)=>e.isTimeBased)); await h.ctrl.addExercise(catalog.firstWhere((e)=>!e.isTimeBased));
      expect(h.state.exercises.first.sets.every((s)=>s.reps==0&&s.durationSeconds==30),isTrue);
      expect(h.state.exercises.last.sets.every((s)=>s.reps==10&&s.durationSeconds==0),isTrue);
      obs('G6/defaults',{'timed':'3x0reps/30seconds','repControl':'3x10reps/0seconds','catalogIDsResolvedFromSeeds':true});
    });
  });
}
```

## 8. Generated fixture and complete final results

Extractor output (all six SQL SOURCE records are repeated in section9):

```text
GENERATED {"provenance":"Fresh seeded PGlite IDs, actual sync_daily_data output; deterministic full_body selection only, no catalog or RPC mutation","quest":{"id":"8e36f397-f550-4c6b-807b-eb8eb6ab97e5","status":"active","user_id":"a5555555-5555-4555-8555-555555555555","quest_id":"e399e226-65ea-4e4c-bb1b-5f17fac45da1","earned_xp":0,"created_at":"2026-10-28T15:21:37.352+07:00","expires_at":"2026-10-29T00:00:00+07:00","quest_date":"2026-10-28","completed_at":null,"is_main_routine":true,"prescribed_config":[{"reps":12,"sets":3,"weight_kg":0,"exercise_id":"b60b0790-91b5-4cc9-accb-8baa24af3fe4","exercise_name":"Ab Wheel Rollout"},{"reps":12,"sets":3,"weight_kg":0,"exercise_id":"b6c74ab9-77bb-48ef-bd29-8d783d8f106e","exercise_name":"Arnold Press"},{"reps":12,"sets":3,"weight_kg":0,"exercise_id":"977915bd-4f72-4f21-b7a0-8a2580f6f7e0","exercise_name":"Back Extension (Hyperextension)"}]},"catalog":[{"id":"b60b0790-91b5-4cc9-accb-8baa24af3fe4","name":"Ab Wheel Rollout","category":"Core","equipment":"Bodyweight","force_type":"Pull","movement_pattern":"carry","slug":"ab-wheel-rollout"},{"id":"b6c74ab9-77bb-48ef-bd29-8d783d8f106e","name":"Arnold Press","category":"Shoulders","equipment":"Dumbbell","force_type":"Push","movement_pattern":"push","slug":"arnold-press"},{"id":"977915bd-4f72-4f21-b7a0-8a2580f6f7e0","name":"Back Extension (Hyperextension)","category":"Back","equipment":"Bodyweight","force_type":"Pull","movement_pattern":"hinge","slug":"back-extension-hyperextension"}]}
EXTRACT_PASS catalog=150 targets=3 fresh_seed_runtime_ids=3 fetches=0
EXTRACT_EXIT=0
```

The GENERATED object is the full original fixture. To restore exact `generated.json` formatting use
`JSON.stringify(object,null,2)+'\n'` (no extractor rerun required; a rerun generates different fresh IDs).
Complete final probe output, followed by wrapper marker:

```text
00:00 +0: loading C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a5-flutter-20261028/a5_probe_test.dart
00:00 +0: G1 real AuthController router and reset screen recovery entry staleSignIn=false with rejected and successful submit controls
OBS G1/diagnostic {"auth":"AsyncData<AuthState>(value: AuthState(event: AuthChangeEvent.passwordRecovery, session: Session(providerToken: null, providerRefreshToken: null, expiresIn: null, tokenType: bearer, user: User(id: A, appMetadata: {}, userMetadata: {}, aud: authenticated, confirmationSentAt: null, recoverySentAt: null, emailChangeSentAt: null, newEmail: null, invitedAt: null, actionLink: null, email: null, phone: null, createdAt: 2026-10-28T00:00:00Z, confirmedAt: null, emailConfirmedAt: null, phoneConfirmedAt: null, lastSignInAt: null, role: null, updatedAt: null, identities: null, factors: null, isAnonymous: false), accessToken: a5-synthetic-token, refreshToken: null), fromBroadcast: false))","profile":"AsyncData<Map<String, dynamic>?>(value: null)","recovery":true,"route":"/reset-password"}
OBS G1/entry {"failedSignIn":false,"prematureUpdateError":false,"updateCalls":0,"route":"/reset-password"}
OBS G1/controls {"failedSignIn":false,"rejectedShowsError":true,"successClearsErrorAndRecovery":true}
00:01 +1: G1 real AuthController router and reset screen recovery entry staleSignIn=true with rejected and successful submit controls
OBS G1/diagnostic {"auth":"AsyncData<AuthState>(value: AuthState(event: AuthChangeEvent.passwordRecovery, session: Session(providerToken: null, providerRefreshToken: null, expiresIn: null, tokenType: bearer, user: User(id: A, appMetadata: {}, userMetadata: {}, aud: authenticated, confirmationSentAt: null, recoverySentAt: null, emailChangeSentAt: null, newEmail: null, invitedAt: null, actionLink: null, email: null, phone: null, createdAt: 2026-10-28T00:00:00Z, confirmedAt: null, emailConfirmedAt: null, phoneConfirmedAt: null, lastSignInAt: null, role: null, updatedAt: null, identities: null, factors: null, isAnonymous: false), accessToken: a5-synthetic-token, refreshToken: null), fromBroadcast: false))","profile":"AsyncData<Map<String, dynamic>?>(value: null)","recovery":true,"route":"/reset-password"}
OBS G1/entry {"failedSignIn":true,"prematureUpdateError":true,"updateCalls":0,"route":"/reset-password"}
OBS G1/controls {"failedSignIn":true,"rejectedShowsError":true,"successClearsErrorAndRecovery":true}
00:02 +2: G2 post-backup-await identity race (not discard queue cycle) completion backup remove identity=same
OBS G2/complete/same {"resultOwner":"A","remainingOwner":null,"error":null,"newIdentityErased":false}
00:02 +3: G2 post-backup-await identity race (not discard queue cycle) completion backup remove identity=reset
OBS G2/complete/reset {"resultOwner":null,"remainingOwner":null,"error":null,"newIdentityErased":false}
00:02 +4: G2 post-backup-await identity race (not discard queue cycle) completion backup remove identity=new
OBS G2/complete/new {"resultOwner":"A","remainingOwner":null,"error":null,"newIdentityErased":true}
00:02 +5: G2 post-backup-await identity race (not discard queue cycle) cancel backup remove erases a new user workout
OBS G2/cancel/new {"newIdentityErased":true,"error":null}
00:02 +6: G3 actual addSet transport with modeled commit boundary addSet lost
OBS G3/lost {"serverIDs":["s1","s100","s101"],"serverNumbers":[1,2,2],"localIDs":["s1","s101"],"localNumbers":[1,2],"httpInsertCalls":2,"payloads":[{"workout_exercise_id":"e1","set_number":2,"reps":10,"weight_kg":0.0},{"workout_exercise_id":"e1","set_number":2,"reps":10,"weight_kg":0.0}]}
00:03 +7: G3 actual addSet transport with modeled commit boundary addSet reject
OBS G3/reject {"serverIDs":["s1","s100"],"serverNumbers":[1,2],"localIDs":["s1","s100"],"localNumbers":[1,2],"httpInsertCalls":2,"payloads":[{"workout_exercise_id":"e1","set_number":2,"reps":10,"weight_kg":0.0},{"workout_exercise_id":"e1","set_number":2,"reps":10,"weight_kg":0.0}]}
00:03 +8: G3 actual addSet transport with modeled commit boundary addSet lost-reload
OBS G3/lost-reload {"serverIDs":["s1","s100","s101"],"serverNumbers":[1,2,3],"localIDs":["s1","s100","s101"],"localNumbers":[1,2,3],"httpInsertCalls":2,"payloads":[{"workout_exercise_id":"e1","set_number":2,"reps":10,"weight_kg":0.0},{"workout_exercise_id":"e1","set_number":3,"reps":10,"weight_kg":0.0}]}
00:03 +9: G4 actual reorder and legitimate delete transports reorder second update fail=true
OBS G4/reorder/true {"serverOrderIndices":{"e1":0,"e2":1,"e3":0},"reloadedIDs":["e1","e3","e2"],"httpUpdates":2,"duplicateServerOrder":true}
00:03 +10: G4 actual reorder and legitimate delete transports reorder second update fail=false
OBS G4/reorder/false {"serverOrderIndices":{"e1":1,"e2":2,"e3":0},"reloadedIDs":["e3","e1","e2"],"httpUpdates":3,"duplicateServerOrder":false}
00:03 +11: G4 actual reorder and legitimate delete transports delete already absent owned row forbidden=false
OBS G4/delete {"forbiddenResponse":false,"localCount":0,"error":null}
00:03 +12: G4 actual reorder and legitimate delete transports delete already absent owned row forbidden=true
OBS G4/delete {"forbiddenResponse":true,"localCount":1,"error":"save_failed"}
00:03 +13: G5 actual finish repository committed RPC then hydrate hydrate error
OBS G5/error {"commitCount":1,"rpcAttempts":2,"firstReportedFailure":true,"retryReward":{"earnedXP":5,"durationSeconds":7,"isQuest":false},"retrySummarySeconds":120,"authoritativeSeconds":7}
00:03 +14: G5 actual finish repository committed RPC then hydrate hydrate null
OBS G5/null {"commitCount":1,"rpcAttempts":2,"firstReportedFailure":true,"retryReward":{"earnedXP":5,"durationSeconds":7,"isQuest":false},"retrySummarySeconds":120,"authoritativeSeconds":7}
00:03 +15: G5 actual finish repository committed RPC then hydrate hydrate ok
OBS G5/ok {"localSummarySeconds":120,"hydratedWorkoutSeconds":7,"rpcReward":{"earnedXP":5,"durationSeconds":7,"isQuest":false}}
00:03 +16: G6 actual generated quest decoded into real Dart controller quest startup update completion and Add Set payload separation
OBS G6/quest {"questID":"8e36f397-f550-4c6b-807b-eb8eb6ab97e5","catalogIDs":["b60b0790-91b5-4cc9-accb-8baa24af3fe4","b6c74ab9-77bb-48ef-bd29-8d783d8f106e","977915bd-4f72-4f21-b7a0-8a2580f6f7e0"],"timedSlug":"ab-wheel-rollout","requiredReps":12,"actualInitialPayloads":[{"workout_exercise_id":"e100","set_number":1,"reps":0,"weight_kg":0.0,"duration_seconds":30},{"workout_exercise_id":"e100","set_number":2,"reps":0,"weight_kg":0.0,"duration_seconds":30},{"workout_exercise_id":"e100","set_number":3,"reps":0,"weight_kg":0.0,"duration_seconds":30},{"workout_exercise_id":"e104","set_number":1,"reps":12,"weight_kg":0.0},{"workout_exercise_id":"e104","set_number":2,"reps":12,"weight_kg":0.0},{"workout_exercise_id":"e104","set_number":3,"reps":12,"weight_kg":0.0},{"workout_exercise_id":"e108","set_number":1,"reps":12,"weight_kg":0.0},{"workout_exercise_id":"e108","set_number":2,"reps":12,"weight_kg":0.0},{"workout_exercise_id":"e108","set_number":3,"reps":12,"weight_kg":0.0}],"completedZeroRepTimedSets":3,"rpcRejectionIsFixtureNotSQL":true,"finishRPC":{"p_workout_id":"w-A","p_notes":null}}
OBS G6/AddSet {"setNumber":4,"hiddenReps":10,"displayDuration":0,"clientAcceptedCompletion":true}
OBS G6/control {"positiveRepUpdatePayloadSent":true,"fixtureSuccessConsumed":true,"sqlOrGatewayE2E":false}
00:03 +17: G6 actual generated quest decoded into real Dart controller unprescribed addExercise default timed and rep controls
OBS G6/defaults {"timed":"3x0reps/30seconds","repControl":"3x10reps/0seconds","catalogIDsResolvedFromSeeds":true}
00:03 +18: All tests passed!
FINAL_FLUTTER_PROBE_EXIT=0
```

## 9. SHA256 manifests and scope checks

Commands executed from repository root: explicit Get-FileHash SHA256 for14 enumerated test files,
15 named source/CI paths and11 files in the new external directory; Get-Content line counts;
`git status --porcelain=v1`; `git diff --check`; `git diff --name-only -- app .github supabase tools`.
This is a bounded file census, not recursive repository scanning. Result before evidence creation:
five expected dirty docs, product diff empty, `SCOPE_CHECK_EXIT=0`, whitespace conversion warnings
only. Final evidence source/output equality and six-path scope check is recorded below after writing.

SHA256 recorded from actual bytes (line counts above, hashes below):

```text
SOURCE app/test/adversarial_edge_test.dart adb55855044674a5ae720d22e2e7889962c347c60b7f4b225b5794c6259045f4
SOURCE app/test/auth_controller_test.dart 99a8cea808738ca1d26405bfc171775f8422953aa2388c73f04fcd1e9215923b
SOURCE app/test/auth_redirect_test.dart 86c780c50e39f47e21c4ff2544bf93aa831cb92896ccd66155dbf9e47d567382
SOURCE app/test/candy_ui_test.dart b0424f590916baf702c584e1cba16d21523139f349239bbf90d573750bd2d219
SOURCE app/test/client_config_test.dart c229a8809977a782e00e2ba4c1f0c83434c89db4fb198428d393976079286f68
SOURCE app/test/coach_controller_test.dart af5724c057b219280173d779e0a9e5ae903143aa997ea8e712ed100004688982
SOURCE app/test/navigation_integration_test.dart 60a8855c74fb3772192fe9397400a71b675de8a0bd51c8a93debfd47f78654a6
SOURCE app/test/progression_engine_test.dart 02990a0ef52933dfbf7b5a46dea902acfdb4c33ef3809f38df3b55c6bfa63eaf
SOURCE app/test/session_isolation_test.dart 939efdbd009466e5c87712db158313c7642be6dd3bb18a124e5333c98e0581e6
SOURCE app/test/ui_regression_test.dart f5907741882344bb892db1be28e2a8f712fa1a9175a4c38bbcd46215e217c5cd
SOURCE app/test/verify_logic.dart 16f2d2db40ea1d9cde9399c8b76bfad8043e1e64582d0fddbbac839a91814852
SOURCE app/test/widget_test.dart 3ed19523e052b40ad702a509a7701e51bf45ca48acbe280d1da5f65910634f4a
SOURCE app/test/workout_controller_test.dart 36bd8254dc8518c83f7e24b372a460d4f41d66bd87e961ce9882ce044e204ffc
SOURCE app/test/workout_widgets_test.dart e206e89e42392aa8281a0b89082e82995039acc9de0c059cc49496f5da6cb8d6
SOURCE app/lib/features/workout/presentation/controllers/active_workout_controller.dart ea33a79b61171d62e12877ec9c31b0871e67d6cde44fd298394db95432aa5222
SOURCE app/lib/features/workout/data/supabase_workout_repository.dart 2649199ecfafa65d4b7dc5069b834c975d2a2a45ae3bc69c09a8a209c79bbb78
SOURCE app/lib/features/auth/presentation/providers/auth_providers.dart 67cb415d0ced415c7ce5750697e4f2226db165d93405223c11225011a486db62
SOURCE app/lib/features/auth/presentation/screens/reset_password_screen.dart 991ccfa3a7f6decfbff17f21f2b0c3f4b43e3c23da11f0b4d1dd1f5c122c4681
SOURCE app/lib/features/auth/presentation/screens/auth_form_screen.dart 2b1fb21390c41f7c8c7cdc181b7140664efe8a0e0edbb11e0a3b22808d797fb3
SOURCE app/lib/core/router/app_router.dart 06bd07e9c189b320279294082679006a9e752294659e477d231bb0d7eed86eb6
SOURCE app/lib/core/router/auth_redirect.dart 5daf3c3b776050cf39983faf019a12c7502060eeba1838b653df9bb5f8fccd0e
SOURCE app/lib/features/quests/domain/quest_instance.dart b20f683683fcebdb95a4459c37ad294d276b7b9dcaabf25e791c4956a7d0d18f
SOURCE app/lib/features/workout/domain/exercise.dart 45e026d03b04792a045dbd374222fb92b7ec127feb85c4ab346fbb97a8084b91
SOURCE app/lib/features/workout/domain/workout.dart 8919382efbfba75cdcc97de15a1dbb704a9761b5fcdfd9de4cab4824060c5c58
SOURCE app/lib/features/workout/domain/workout_exercise.dart 0822e500612a9776d29164da4748c05c9bf7b56d09b71d190d50bf9d818e5c22
SOURCE app/lib/features/workout/domain/workout_set.dart 612bbe0aa31b2fda00aebc2c6d0145c03b473f04778b90a0db7e232386836de8
SOURCE app/lib/features/workout/domain/workout_repository.dart af17d058b49367ce948886a673b768edc922c33ed49dab5fdab006aebdaa25bb
SOURCE app/lib/features/workout/presentation/providers/exercise_providers.dart dd233fded429ad8c4ba751b0c9d057c0ec6c7332961820181379a2c2e9cd3724
SOURCE .github/workflows/verify.yml 8018f554ba146571883678bf115de37f89ccbea2b71472b1fe8135371a4ed55e
SOURCE tools/db-tests/bootstrap.sql fbfdd130ab2a2db10f9c5f850589fee746bee1b327e366c41179ca5931a7f250
SOURCE supabase/migrations/20261026000100_baseline.sql e4e56bd1a1bb770fb28fec09ee5590302b89554d33f255b559499d1d8c21fc44
SOURCE supabase/migrations/20261026000200_authoritative_progression.sql 4b5f5682a25da4abbba8ca0aa3c4b6ed22ab92bc30021a9cef8b5f750b2dfc62
SOURCE supabase/migrations/20261027000100_exercise_catalog_metadata.sql 143b69653bb9b178fbc8b3fda6380ee1021be958a39d32f7bfac4f53727fbefb
SOURCE supabase/seed.sql a96d9f5830b8cab1b99501725d1a9ff31fedb8a18900a463240ac246db392c68
SOURCE supabase/seed_exercises.sql 9af8382923d798fee30ccbe32986873440f5fd25588a0cea00acf408ad00c748
ARTIFACT a5_probe_test.dart bytes=23934 sha256=9ed2242cd9b7e0fadccb26914dd428a7339101c7429fd150a796706ff033dd0c
ARTIFACT analyze.log bytes=198 sha256=4b4b24b815412d6d4fe4cc0df3de7a50a59d5f452a569ca70d2761c7a2bae5c4
ARTIFACT diagnostic.log bytes=12028 sha256=8db72720a3a3a21763731b7225996d9d61520dd7162a9fb14c3e36e00c9ceb0f
ARTIFACT diagnostic_test.dart bytes=861 sha256=ee386972a115d262e1bac484709fc667ed7c01dbfde6c81dc62132473b664726
ARTIFACT extract.log bytes=4772 sha256=281ffe182b3a7a209bbb5a88e2c3bcc66e64f4b5124d4bf48747822702767d60
ARTIFACT extract.mjs bytes=3436 sha256=f05a7c8f63d9395e5cd209f165eb5b622b61297f1456ec0bd2bd0da21afa97c8
ARTIFACT g1-widget-success.log bytes=4912 sha256=a0d51598d0b396d36f7ca022a80287f1d3e0731750347e875310d7bfdbf2828a
ARTIFACT generated.json bytes=1960 sha256=8532cede32d336a5aff92f32a4c71ddc643f1313e4bae417852ec54f03a18834
ARTIFACT run-01.log bytes=23874 sha256=8105db1b5f2bfc8c8749eb29795ee0b165055cfd956e7187e7bdde9f085a5cb0
ARTIFACT run-02.log bytes=15372 sha256=0faabeb51ad4eaebd337260c47b7c515a39c8eed26b3f3e623ca3c58ef4573f2
ARTIFACT run-03-final.log bytes=15372 sha256=71fd5d2b84e3e39984e0e02ca6c387347a28f53b1263b0a1ce48fd8d6eb417f2
```

No decisions changed; no register IDs/classifications/history were edited by this specialist.
Next action: orchestrator obtains independent material QA on these scoped facts, reconciles new
candidates/addenda while preserving baseline30, then continues only bounded authorized A5 work.

## 10. Retained documentary equality/scope verification

Executed from `D:\Projects\gymlvl` after sections1-9 were written, no unexpected failure/correction:

```powershell
@'
const fs=require('node:fs'),assert=require('node:assert/strict'),crypto=require('node:crypto'),cp=require('node:child_process');
const doc=fs.readFileSync('docs/audit/phases/A5_FLUTTER_EVIDENCE.md','utf8').replace(/\r\n/g,'\n');
const ext='C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a5-flutter-20261028/';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const section=n=>doc.split(new RegExp('\\n## '+n+'\\. '))[1].split(/\n## \d+\. /)[0];
for(const [n,lang,file] of [[5,'javascript','extract.mjs'],[6,'dart','diagnostic_test.dart'],[7,'dart','a5_probe_test.dart']]) {
 const body=section(n).match(new RegExp('```'+lang+'\\n([\\s\\S]*?)\\n```'))[1]+'\n';
 assert.equal(body,fs.readFileSync(ext+file,'utf8').replace(/\r\n/g,'\n'),file);
}
const fixture=JSON.parse(section(8).match(/^GENERATED (.+)$/m)[1]);
assert.equal(hash(JSON.stringify(fixture,null,2)+'\n'),hash(fs.readFileSync(ext+'generated.json')));
const result=section(8).match(/```text\n(00:00 \+0: loading[\s\S]*?)\nFINAL_FLUTTER_PROBE_EXIT=0\n```/)[1];
const b=fs.readFileSync(ext+'run-03-final.log');
const decoded=(b[0]===255&&b[1]===254?b.subarray(2).toString('utf16le'):b.toString('utf8')).replace(/\r\n/g,'\n').trimEnd();
assert.equal(result.trimEnd(),decoded,'full final log');
const sources=[...doc.matchAll(/^SOURCE (\S+) ([a-f0-9]{64})$/gm)];assert.equal(sources.length,35);
for(const [,p,h] of sources)assert.equal(hash(fs.readFileSync(p)),h,p);
for(const [,file,bytes,h] of doc.matchAll(/^ARTIFACT (\S+) bytes=(\d+) sha256=([a-f0-9]{64})$/gm)){const b=fs.readFileSync(ext+file);assert.equal(b.length,+bytes);assert.equal(hash(b),h,file);}
const git=(...a)=>cp.execFileSync('git',a,{encoding:'utf8'}).trimEnd();
assert.equal(git('rev-parse','HEAD'),'1763ab55e8da994bc1d854ad8fd2cd2299678b45');assert.equal(git('branch','--show-current'),'main');
const allowed=['docs/audit/SESSION_HANDOFF.md','docs/planning/CHANGELOG_AI.md','docs/planning/SESSION_HANDOFF.md','docs/planning/TASK_BOARD.md','docs/audit/phases/A5_TEST_RELIABILITY.md','docs/audit/phases/A5_FLUTTER_EVIDENCE.md'];
const paths=git('status','--porcelain=v1','-uall').split(/\r?\n/).filter(Boolean).map(l=>l.slice(3));assert.deepEqual(paths.sort(),allowed.sort());
assert.equal(git('diff','--name-only','--','app','.github','supabase','tools','docs/audit/FINDINGS_REGISTER.json','docs/audit/MASTER_FINDINGS.md'),'');
console.log('A5_FLUTTER_EVIDENCE_CHECK source_blocks=3 exact_fixture=1 exact_final_output=1 source_hashes=35 artifact_hashes=11 allowed_paths=6 product_register_diff=0 errors=0');
'@ | node; $v=$LASTEXITCODE; git diff --check; $d=$LASTEXITCODE; git status --porcelain=v1; Write-Output "A5_FLUTTER_FINAL_CHECK node=$v diff=$d"; if($v -ne 0 -or $d -ne 0){exit 1}
```

Result **PASS**, exit0 (only existing docs' LF/CRLF conversion warnings):

```text
A5_FLUTTER_EVIDENCE_CHECK source_blocks=3 exact_fixture=1 exact_final_output=1 source_hashes=35 artifact_hashes=11 allowed_paths=6 product_register_diff=0 errors=0
 M docs/audit/SESSION_HANDOFF.md
 M docs/planning/CHANGELOG_AI.md
 M docs/planning/SESSION_HANDOFF.md
 M docs/planning/TASK_BOARD.md
?? docs/audit/phases/A5_FLUTTER_EVIDENCE.md
?? docs/audit/phases/A5_TEST_RELIABILITY.md
A5_FLUTTER_FINAL_CHECK node=0 diff=0
```

The six-path set includes the original five orchestrator paths plus only this specialist's new
evidence doc. Existing30 register objects, product and permanent tests are unchanged by this work.
No commit/push/cleanup or new material decision. A5 stage closure/independent QA are NOT RUN here.

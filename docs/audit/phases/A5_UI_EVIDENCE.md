# A5 — Bounded UI, accessibility, localization and navigation evidence

**Date/reviewer:** 2026-10-28, ui-ux-specialist (delegated A5 audit only).
**Measured commit:** `main` @ `614ee7cb6f99846b00fd71eec43637cb296268be`.
**Disposition:** bounded review complete; external run **FAIL** (8 passing, 2 harness failures).
This is not A5 closure, an accessibility certification, a redesign, or remediation.
**Owned repository path:** this new file only. Planning/register reconciliation belongs to the
orchestrator. No finding ID is allocated here; all existing 30 finding objects remain untouched.

## 1. Entry, boundaries and source reading

Executed at `D:\Projects\gymlvl`:

```powershell
git status --porcelain=v1
git branch --show-current
git rev-parse HEAD
git rev-parse main
if (Test-Path 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-ui-20261028') {
  Write-Output 'STOP: external directory already exists'; exit 2
}
```

Output: empty status, `main`, twice `614ee7cb6f99846b00fd71eec43637cb296268be`, exit 0.
External directory was absent; only the new audit harness, its two screen captures and text evidence
were created there. No app copy, prior-directory read/deletion, secret, network/backend initialization,
install, dependency, permanent test, CI/config, product edit, commit, push, or tag occurred.
Remote equality was supplied by the orchestrator, **NOT RUN** independently here.

Read the seven planning prerequisites in contract order. Their PARTIAL checkpoint text predates this
entry SHA; it is historical checkpoint provenance, not a conflicting current-HEAD assertion.
Read A2 sections 8.2 leads 1/2/5/6/7 and the relevant coverage rows. Broad A2 UI inspection and the
other Flutter agent's full 14-test-file review were not repeated.

Bounded fresh reads (line references are the measured source, not inferred runtime coverage):

- `app/test/ui_regression_test.dart:1-415`: imports real production screens/providers and CandyButton;
  normal-scale VI/EN layout grid (320/390/768/1440), safe auth/error, seeded nine-step onboarding,
  quest error/empty controls; dashboard/completion large-text checks are EN at **150%**, not 200%.
  Its MaterialApp uses **AppTheme.darkTheme** (:163), whereas production `app/lib/app.dart:22-25`
  forces Candy light. Thus those assertions are meaningful production-widget coverage with fake
  data, but do not protect actual light-theme contrast. It loads Inter/Orbitron only (:207-223), not
  the Archivo/Space Grotesk production families. Optional `CAPTURE_UI` image export is not a golden
  comparison or asserted visual baseline.
- `app/test/candy_ui_test.dart:1-619`: no production import. Local token specification, local
  `TactileCandyButton` and `CandyCardWidget` are **reference fixtures**. Token self-comparisons,
  pointer animation, local contrast math, 320dp and 150% tests do not prove real Candy primitives'
  keyboard, focus, hit bounds, production theme or l10n behavior. Do not count this as zero useful
  tests, but do not substitute it for production component coverage.
- `app/test/widget_test.dart:1-38`: actual ConfigurationApp, actionable/narrow configuration failure;
  no configured app startup, route traversal, locales, screen reader, or large-text claim.
- Requested `app/test/router_test.dart` **does not exist** (read and glob returned not found).
  Read actual `navigation_integration_test.dart:1-261` and `auth_redirect_test.dart:1-55` instead.
  The former checks theme API, source text for Orbitron, actual banner with fake active state,
  pointer tap of actual navigation item, and route-path enumeration (:220-258). The name
  “wired and accessible” does **not** execute GoRouter navigation. The latter exercises the actual
  pure redirect helper and recovery precedence, not live callbacks/deep links or device back behavior.
- Read real `ui/candy/candy_button.dart:1-210`, `candy_text_field.dart:1-198`,
  `candy_dialog.dart:1-167`, `candy_bottom_sheet.dart:1-146`, relevant Card (:80-125),
  NavigationItem (:1-110), and ExerciseCard (:1-127). There are no `CandyIconButton`, `CandyChip`
  or `CandyInput` classes/files in this tree. Relevant real equivalents are the TextField suffix
  IconButton, bottom-sheet GestureDetector close, and onboarding FilterChip/gender choices.
- Read shared SystemButton/SystemTextField/SystemPanel/StatusPanel completely, actual localization
  mode/dictionary/wrapper (:1-230 plus `.tr` location), light tokens/theme, AppTheme and app root;
  profile header/edit/close/language/validation (:1-205,360-724), onboarding shell/language
  (:1-300), gender (:825-934), day chip (:1080-1129), and choice tile (:1303-1343).
  Production SystemButton delegates to FilledButton; SystemTextField already supplies a tooltip
  and three error lines. These existing affordances must not be lost in remediation.

Missing golden files and coverage percentages remain **gaps**, not automatically defects.
No coverage percentage was measured or invented. C24 test architecture is owned by the other writer.

## 2. Finite harness, commands and exact dispositions

External root (all further `$p` references):
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-ui-20261028`.
The complete, byte-preserving sources of both runs, complete stdout/stderr, hashes and retention
helpers are embedded in section 6. There is no reliance on an ephemeral file for text evidence.

Setup: tools.patch created only `ui_probe_test.dart`; a bounded Copy-Item retained run 1 source
before the correction. The harness imports actual `package:app` widgets, CandyTheme.theme,
AppLocalizations plus Flutter locale delegates and real `.tr`/localizationModeProvider, with a fake
language notifier and fake current-user/profile/class providers. It loads the existing local fonts
Archivo, Space Grotesk, Space Mono, Inter and MaterialIcons; it does not copy them or fetch assets.
Widgets are tested inside MaterialApp/Scaffold from the **app working directory**, installed deps.
This is not MainApp/router/device end-to-end execution. Fixture English strings in the two minimal
mechanics tests are test labels only; localized tests obtain copy from production resources.

Executed from `D:\Projects\gymlvl\app`:

```powershell
$p='C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-ui-20261028'
Get-Command flutter | Select-Object Source
flutter test --no-pub --reporter expanded "$p\ui_probe_test.dart" *> "$p\run1.txt"
$code=$LASTEXITCODE; Get-Content "$p\run1.txt"; Write-Output "FLUTTER_EXIT=$code"; exit $code
```

Flutter resolved to `C:\tools\flutter\bin\flutter.bat`. **FAIL**, exit 1, `+5 -5: Some tests failed.`
Three audit-fixture mistakes, not app defects: close assumed 26dp while actual border-inclusive size
was 29dp; SemanticsHandle disposal registered in addTearDown ran after widget end verification;
day-chip Material.color was nullable. One diagnostic correction per issue was made: assert actual
29dp, explicitly dispose the semantics handles before end-of-test, inspect RawChip's generated Ink
ShapeDecoration rather than nullable Material.color (installed Flutter `chip.dart:1404-1437` read).

```powershell
Copy-Item "$p\ui_probe_test.dart" "$p\ui_probe_run1.dart"
# This copy occurred BEFORE the above correction, not after it.
Get-FileHash "$p\ui_probe_run1.dart" -Algorithm SHA256
flutter test --no-pub --reporter expanded "$p\ui_probe_test.dart" *> "$p\run2.txt"
$code=$LASTEXITCODE; Get-Content "$p\run2.txt"; Write-Output "FLUTTER_EXIT=$code"; exit $code
```

Run 1 retained SHA256: `f430bc99ecb2a31bf00acb222841ee202066de4fa776a3664500c2b7a62164da`.
Run 2 source SHA256: `2f0adaef0b56594678f62dd4bf4375c50d2e9efa9b03455d11bebcb985fc4fce`.
Run 2 **FAIL**, exit 1, `+8 -2: Some tests failed.` Two onboarding tests still fail on nullable
Ink decoration color (:265). The finite diagnostic budget is exhausted; no second chip setup fix,
third runtime run, guessed background, or production contrast claim for day chips follows.

Eight test cases passed (the aggregate command is still FAIL):

- Keyboard: actual enabled CandyButton has no descendant Focus. Tab lands on production SystemButton;
  Enter then Space increment System exactly once each (1 then 2), Candy remains 0. Pointer increments
  Candy once; disabled Candy remains inert. Output:
  `KEYBOARD candyFocusNodes=0 Tab->System Enter=1 Space=2 CandyKeys=0 pointerCandy=1 disabled=0`.
  This is a **defect-observing assertion**, not a passing accessibility requirement. The disabled
  fixture has `onPressed:null`; it does not test a loading button, every key sequence or key repeat.
- Hit/semantics: small default CandyButton is **390x48**, suffix IconButton **48x48** (positive size
  controls); sheet close is **29x29**. Tap 18dp below center (inside a hypothetical centered 48dp
  target, outside actual rectangle) fires 0, center fires 1. Both sheet-close and password suffix
  semantics labels are empty; native CloseButton label is `Close`. No 44dp paint-to-hit inference.
- VI and EN controls at **320x844, 200%**, production light tokens/resources/fonts: error, StatusPanel,
  helper and sheet render without framework layout exceptions. EN password-required error has
  `didExceedMaxLines=false`; VI has **true** (visible ellipsis despite no overflow exception).
  Native CloseButton provides `Close` / `Đóng`; Candy sheet close remains unnamed, each center tap
  fires once. Actual custom sheet is instantiated inside the synthetic scroll fixture, not a live
  showModalBottomSheet route. The two captures are retained externally, hashes in the manifest.
  Reviewer opened the VI capture: `Cấp độ`, `kết nối`, `dữ liệu` diacritics are visible in this
  widget-test raster; this is **not** small-size or physical-device glyph/screen-reader coverage.
- VI and EN CandyDialog at **390x844/100%** then **320x844/200%**: actual localized action labels
  have normal ellipsis `[false,true]`, large ellipsis `[true,true]`; no framework layout errors.
  Each actual pointer action fires exactly once. No assertion of full label readability, dialog
  keyboard access, short-height resilience or whole-flow accessibility is made.
- VI and EN **actual ProfileScreen**, fake data, **390x844/100%**, production light theme:
  display name and first edit TextField both resolve to white-on-white **1.0:1**;
  actual ink-on-card positive contrast is **18.883060964594996:1**. Both report `errors=[]`.

Two tests failed after the existing onboarding unselected-gender 1.0 contrast assertion and selected
state tap had executed, before day-chip extraction could finish. Do not call these whole tests PASS,
or claim selected/day contrast from the unprinted local value. Profile evidence alone suffices for
the existing BUG004 merge. Gender static evidence already belongs to that finding.

Analyzer diagnostic, same app working directory:

```powershell
flutter analyze --no-pub "$p\ui_probe_test.dart" *> "$p\analyze.txt"
$code=$LASTEXITCODE; Get-Content "$p\analyze.txt"; Write-Output "ANALYZE_EXIT=$code"; exit $code
```

**FAIL**, exit 1, `296 issues found. (ran in 3.0s)`. First errors are missing `dart:ui` and Flutter/app
package URIs for the external file. Static analysis did not inherit app package context outside the
package root, unlike the Flutter test compiler. This does **not** establish 296 app defects. No
external package/config creation or dependency install was attempted. Product analysis/full 126
regression suite **NOT RUN** by this agent (orchestrator owns the once-only current suite run).

## 3. Proposed reconciliation, not register edits

1. **Merge existing FND-BUG-004, W2, ui-ux-specialist + QA.** Profile runtime style evidence in both
   locales supports Confirmed for this narrow white-on-white identity/edit mechanism. Severity
   remains **P2**: unreadable identity/edit text; no data-integrity claim. Do not allocate a duplicate
   gender/selected-white finding or extend to every profile/onboarding state. Whole-screen large
   text and day-chip contrast remain outside this successful evidence.
2. **One new candidate only: CandyButton not keyboard reachable/activatable.** Mechanism:
   `candy_button.dart:189-207` uses Semantics + pointer GestureDetector without Focus/Actions.
   Runtime negative and production SystemButton positive controls are above. Existing production
   usages: `core/router/persistent_active_workout_banner.dart:147` and
   `features/progression/presentation/widgets/level_up_overlay.dart:143`. **Severity P2** (keyboard
   users cannot operate these Candy actions); **confidence Confirmed for primitive fixture**, High
   for integrated screen impact (those routes not traversed). Owner UI/Flutter, **W2**, QA to verify
   Tab/visible focus/Enter/Space exactly once and disabled/loading controls after authorization.
   Card/NavigationItem have related static gestures, but were not keyboard-probed; no blanket
   keyboard failure finding for all widgets/screens. The candidate is distinct from color BUG004
   and localization ARCH002; orchestrator decides an ID only after QA.
3. **Unnamed/tiny close, suffix label, dialog/error truncation: bounded component observations.**
   Actual source widgets, not local replicas, demonstrate the mechanisms above, but a bounded
   `grep` found no production call sites for CandyDialog/CandyBottomSheet/CandyTextField beyond
   their own definitions/helpers. Do **not** turn their synthetic composition into an affected
   live profile/workout journey. No additional new finding proposed without a reachable call site.
   Carry as W2 UI/QA component regression assertions. Profile's real sheet IconButton (:196-199)
   also lacks tooltip statically; its modal was **NOT RUN** and its actual hit bounds/semantics are
   not established by the generic Candy sheet. Missing localized naming can extend existing
   ARCH002's copy-integration evidence only with explicit primitive-only scope; no duplicate
   localization architecture finding. Text clipping is not a new architecture by itself.

**Independent QA correction (A5, ses_e7cb5a850ffeEKOCUhDgig3neH):** the fixture's disabled counter
has no incrementing callback, so zero is a weak/tautological disabled assertion. Retain raw source/
output above, but do not advertise comprehensive disabled/loading protection or use that control to
support the keyboard finding. Actual enabled Candy pointer activation and production SystemButton
Tab/Enter/Space positive controls support the narrower keyboard reachability conclusion independently.

## 4. Coverage/gap reconciliation for orchestrator

- **C03:** add narrow runtime evidence for actual CandyButton keyboard/default small hit size and
  selected minimal controls, while keeping overall row `Reviewed (static)`. Not all tokens, custom
  dimensions, variants, cards/navigation/focus states or contrast pairs were executed.
- **C04:** SystemButton is a positive keyboard control; StatusPanel renders actual VI/EN copy at
  320/200. Remaining shared-widget interactions, semantics and focus order **NOT RUN**.
- **C05:** actual `.tr`/provider/delegates plus loaded production fonts were used for two locales;
  generated AppLocalizations is loaded, not mistaken for the main product dictionary. Bilingual
  newline mode, all translations, small-size glyphs and TalkBack/VoiceOver **NOT RUN**. Existing
  ARCH002 remains the owner of parallel mechanisms/hardcoded copy, not a new duplicate ID.
- **C07:** actual gender style assertion reached in both otherwise-failing onboarding tests;
  unselected/selected **day-chip resolved contrast remains NOT RUN to completion** due nullable
  background sampling. Required next assertion: capture the actual composited unselected and
  selected chip paint pair, not a guessed theme surface; measure both under Candy light.
  Full nine-step VI/EN/bilingual 320/200 interaction **NOT RUN**. UI/QA, W2 authorized follow-up.
- **C11:** no new workout-screen runtime claim. Minimal button fixture is not an exercise picker,
  rest timer, locale/numeric input, active-workout lifecycle, summary or back-stack test. Timed quest
  journey already belongs to the Flutter probe; not repeated here. UI/QA own future real-screen
  320/200, dialog close/actions, focus-order and numeric/locale fixtures with safe fake data.
- **C16:** add actual profile identity/edit runtime contrast at 390/100 in VI/EN, not full profile
  verification. 320/200 profile editing/modal/screen-reader paths **NOT RUN**, UI/QA W2 follow-up.
- **Navigation:** real path enumeration and pure redirect coverage are distinguished above. No live
  deep-link, shell back-stack, platform callback or route keyboard traversal result is invented.
- Device screen readers, physical touch exploration, physical font fallback/diacritic quality,
  low-end frame performance and frame budgets **NOT RUN** (require an authorized device/profile
  harness and explicitly chosen budget). No “120” frame budget or whole-device performance claim.

These explicit dispositions close this bounded review, not every deferred runtime assertion or A5.
No design-system token, locale, affordance or copy semantics were changed.

## 5. Retention and Git safety checks

Before creating this evidence file, executed at repository root:

```powershell
if (Test-Path 'docs/audit/phases/A5_UI_EVIDENCE.md') { Write-Output 'STOP: evidence path already exists'; exit 2 }
git status --porcelain=v1
git diff --check
$c=$LASTEXITCODE; Write-Output "DIFF_CHECK_EXIT=$c"
git rev-parse HEAD
git diff --name-only
```

**PASS:** path absent; status/diff-name empty, `DIFF_CHECK_EXIT=0`, HEAD unchanged. Explicit SHA256
manifest command used `Get-FileHash -Algorithm SHA256` for the 30 named source/test/font/manifest
inputs and 7 then-existing external files, serialized to `hashes.json` (37 entries). All full hashes
are embedded below. No secret/config.local file is included. Final only-owned-path and payload
round-trip checks are recorded after section 6.

Retention setup diagnostic (not hidden): executing
`& 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-ui-20261028\package_evidence.ps1'`
at repository root returned exit 1 / **BLOCKED**:

```text
File ...\package_evidence.ps1 cannot be loaded because running scripts is disabled on this system.
CategoryInfo : SecurityError: (:) [], PSSecurityException
FullyQualifiedErrorId : UnauthorizedAccess
```

No execution policy or permission was changed. Instead the installed Node serializer only read
explicit harness/log files and gzip-serialized text (it does not run PowerShell). Exact command:
`node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-ui-20261028\package_evidence.mjs'`.
First byte-base64-per-file representation: `RETAINED_FILES=8 JSON_BYTES=221207 BASE64_CHARS=37036`,
exit 0. Serializer changed to encoding-tagged text for compactness, not probe logic; final command
same, `RETAINED_FILES=8 JSON_BYTES=111127 BASE64_CHARS=18124`, exit 0. Both helper source files
are included. UTF-16LE redirected logs retain their BOM/text and reconstruct byte-identically.

## 6. Complete retained text payload

The following gzip/Base64 JSON contains **full**, unabridged `ui_probe_run1.dart`,
`ui_probe_test.dart`, `run1.txt`, `run2.txt`, `analyze.txt`, `hashes.json`,
`package_evidence.ps1` and `package_evidence.mjs`. Each entry has name, encoding, text and SHA256.
This keeps all 296 analyzer diagnostics and both initial/final failures, not only selected lines.
Decode read-only with installed Node; `Buffer.from(entry.text,entry.encoding)` reconstructs bytes.
No decoding requires executing either embedded helper. To print a source, use `.find(x =>
x.name === 'ui_probe_test.dart').text` on the parsed array. The external PNGs are not bundled:
EN SHA256 `56355bebc1479ba194a2243ad1526e295ea2e9286cef70c48614bce84b2461bf`;
VI SHA256 `b04249dc62d75e4f53f071e0b280148162414d1345c6abc35f83bfaa2e00ced9`.

<!-- A5_UI_RETAINED_TEXT_START -->
```base64
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
```
<!-- A5_UI_RETAINED_TEXT_END -->

## 7. Final scope/retention verification

Initial artifact validation used this exact `node -e` source inside a PowerShell single-quoted
argument (repository root; redirected to external `validation.txt`):

```javascript
const fs=require("fs"),z=require("zlib"),c=require("crypto"); const d=fs.readFileSync("docs/audit/phases/A5_UI_EVIDENCE.md","utf8"); const b=d.split("<!-- A5_UI_RETAINED_TEXT_START -->")[1].split("```base64")[1].split("```")[0].trim(); const a=JSON.parse(z.gunzipSync(Buffer.from(b,"base64"))); const sha=x=>c.createHash("sha256").update(x).digest("hex"); let n=0; for(const x of a){const v=Buffer.from(x.text,x.encoding); if(sha(v)!==x.sha256) throw Error("embedded hash "+x.name); if(sha(fs.readFileSync("C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a5-ui-20261028/"+x.name))!==x.sha256) throw Error("external hash "+x.name); n++;} const m=JSON.parse(a.find(x=>x.name==="hashes.json").text.replace(/^\uFEFF/,"")); for(const x of m){if(sha(fs.readFileSync(x.path))!==x.sha256) throw Error("input hash "+x.path);} if(d.split(/\r?\n/).some(l=>/[ \t]+$/.test(l))) throw Error("trailing whitespace"); console.log("A5_UI_RETENTION_PASS embedded="+n+" external="+n+" inputs="+m.length+" trailingWhitespace=0");
```

**FAIL**, exit 1 (`RETENTION_EXIT=1`). Windows PowerShell native-argument quoting stripped the JavaScript
double quotes; Node failed before reading the evidence. Full native error body:

```text
[eval]:1
(crypto=>{{const fs=require(fs),z=require(zlib),c=require(crypto); const
d=fs.readFileSync(docs/audit/phases/A5_UI_EVIDENCE.md,utf8); const b=d.split(<!--}})(require('node:crypto'))
SyntaxError: Unexpected end of input
    at makeContextifyScript (node:internal/vm:185:14)
    at compileScript (node:internal/process/execution:386:10)
    at node:internal/process/execution:450:25
    at [eval]-wrapper:6:24
    at runScriptInContext (node:internal/process/execution:447:60)
    at evalFunction (node:internal/process/execution:87:30)
    at evalScript (node:internal/process/execution:99:3)
    at node:internal/main/eval_string:74:3
Node.js v22.17.1
```

No product/probe code was changed. One artifact-validator correction moved equivalent read-only
logic into external `validate_retention.mjs`, complete source:

```javascript
import fs from 'node:fs';
import z from 'node:zlib';
import c from 'node:crypto';
const d = fs.readFileSync('docs/audit/phases/A5_UI_EVIDENCE.md', 'utf8');
const b = d.split('<!-- A5_UI_RETAINED_TEXT_START -->')[1]
  .split('```base64')[1].split('```')[0].trim();
const a = JSON.parse(z.gunzipSync(Buffer.from(b, 'base64')));
const sha = x => c.createHash('sha256').update(x).digest('hex');
let n = 0;
for (const x of a) {
  const v = Buffer.from(x.text, x.encoding);
  if (sha(v) !== x.sha256) throw Error('embedded hash ' + x.name);
  if (sha(fs.readFileSync('C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a5-ui-20261028/' + x.name)) !== x.sha256) {
    throw Error('external hash ' + x.name);
  }
  n++;
}
const m = JSON.parse(a.find(x => x.name === 'hashes.json').text.replace(/^\uFEFF/, ''));
for (const x of m) {
  if (sha(fs.readFileSync(x.path)) !== x.sha256) throw Error('input hash ' + x.path);
}
if (d.split(/\r?\n/).some(l => /[ \t]+$/.test(l))) throw Error('trailing whitespace');
console.log('A5_UI_RETENTION_PASS embedded=' + n + ' external=' + n + ' inputs=' + m.length + ' trailingWhitespace=0');
```

Executed from `D:\Projects\gymlvl`:

```powershell
$p='C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-ui-20261028'
node "$p\validate_retention.mjs" *> "$p\validation2.txt"
$n=$LASTEXITCODE; Get-Content "$p\validation2.txt"; Write-Output "RETENTION_EXIT=$n"
git status --porcelain=v1
git diff --name-only
git diff --check
Write-Output "DIFF_CHECK_EXIT=$LASTEXITCODE"
git rev-parse HEAD
exit $n
```

**PASS**, exit 0:

```text
A5_UI_RETENTION_PASS embedded=8 external=8 inputs=37 trailingWhitespace=0
RETENTION_EXIT=0
?? docs/audit/phases/A5_UI_EVIDENCE.md
DIFF_CHECK_EXIT=0
614ee7cb6f99846b00fd71eec43637cb296268be
```

Tracked diff-name output is empty; the only new/untracked path is this authorized evidence file.
Because `git diff --check` does not inspect untracked content, the validator explicitly checks this
new file for trailing whitespace too. Eight embedded files reconstruct to their full recorded
SHA256s and equal the external retained originals; all 37 input/artifact hashes still match.
This validation was rerun after final text retention. No commit/push occurred.

**Next action:** orchestrator/QA reconcile this one keyboard candidate, existing BUG004 merge and
owned gaps into A5 records, without product edits or a false all-tests-passed claim.

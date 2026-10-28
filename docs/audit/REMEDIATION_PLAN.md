# A6 proposed remediation roadmap

**Status:** proposal only, 2026-10-29, based on the 35-record A5 register at `main` entry
`6d8e89bf6eba7b393ef2d0e0d52e9b0d5eb4f2c3`. No implementation, product decision, migration,
configuration change or deployment is authorized by this roadmap. A6 is reconciliation, not a
remediation wave. Every task below requires its own explicit authorization; material product,
architecture, schema, privacy, permission, signing and historical-data policies require user approval.
Historical wave names are not binding. Old M1 task IDs and milestone scope remain unchanged; the new
`R` IDs are planning identifiers, not an implied M1 renumbering or authorization.

## Operating rules and priority

W0 safety/development prerequisites; W1 identity and workout reliability; W2 XP, mode and business
rules; W3 UX/auth; W4 tests and maintainability; W5 final regression and migration readiness. Waves
are categories, not a mandatory global waterfall: the task dependencies below form the actual DAG.
One scoped session and one writer at a time; coordinate controller edits instead of concurrent edits.
Independent `qa-reviewer` reviews each task. Fixes carry a defect-observing red test before change,
green after, plus negative and positive controls. Pure documentation and verification-first tasks use
explicit evidence/contradiction assertions rather than inventing a red defect. Capture commands, exit
codes, fixture source, commit and output; past A3–A5 results are historical, not a current PASS. A green
defect-observing reproduction is not a product fix. No estimates or blanket coverage claims.

Priority is **proposed execution order**, not severity: first recommend the narrow privacy task
R1-01 (SEC-002), after R0-01 safety prerequisite and explicit authorization. BUG-001 is P1 release
connectivity, not cross-account privacy; DATA-001 is P1 conditional historical award integrity, not
ordinary-retry duplication. Neither inherits SEC-002's immediate ordering automatically. A true
verification-first safety prerequisite blocks the affected fix or migration, not A6 closure.

## 35-ID disposition matrix

Every row copies current register severity / confidence / status; `R` is the proposed owner task,
not a change in finding status. Root-cause distinctions are intentional.

| Finding | Severity | Confidence | Status | Owner | Distinct root / overlap | Task |
|---|---|---|---|---|---|---|
| FND-CONC-001 | P2 | Confirmed | Accepted | Flutter | Discard re-enqueue cycle; separately identity race after backup await | R1-02 |
| FND-DATA-001 | P1 | Confirmed | Accepted | Supabase | Conditional prior-credit/log false flag without ledger; not ordinary retry | R2-01 |
| FND-ARCH-001 | P2 | High | False Positive | Supabase | Sole awards do not forbid initialization/derived maintenance | No implementation |
| FND-GOV-001 | P2 | Confirmed | Fixed | Governance | Audit write permission was fixed; historical runtime verified later | No implementation |
| FND-GOV-002 | P3 | Confirmed | Accepted | Docs | Baseline and counts stated as timeless facts | R4-03 |
| FND-GOV-003 | P3 | High | False Positive | Governance | Chained-command matcher hypothesis disproved | No implementation |
| FND-BUG-001 | P1 | High | Accepted | Flutter/platform | Release main manifest lacks INTERNET | R1-05 |
| FND-BUG-002 | P2 | High | Accepted | Platform | Release uses debug signing, distinct from manifest access | R1-06 |
| FND-BUG-003 | P4 | High | Accepted | Product/platform | Template launcher name; GymLevel vs GymLvl decision unresolved | R3-06 |
| FND-TEST-001 | P2 | High | Accepted | QA/platform | CI lacks release/format/generated drift gates | R4-01 |
| FND-INTG-001 | P3 | High | Accepted | Supabase/Flutter | Auth redirect allowlist differs from app callback | R3-01 |
| FND-ARCH-002 | P3 | High | Accepted | Flutter/UI | Parallel localization sources, not merely translated copy | R3-05 |
| FND-ARCH-003 | P3 | High | Accepted | Supabase/product | Fixed-timezone wording differs from per-user implementation | R2-06 |
| FND-GOV-004 | P2 | High | Accepted | Governance | Destructive Git spellings bypass pattern gates; overlaps SEC-001 | R0-02 |
| FND-SEC-001 | P2 | High | Accepted | Governance | Alternate secret readers bypass shell gates; distinct protected resource | R0-02 |
| FND-GOV-005 | P4 | High | Accepted | Docs | Tracked obsolete analyzer output, not live analyzer failure | R4-03 |
| FND-SEC-002 | P1 | Confirmed | Accepted | Flutter | Shared backup adopted by another synthetic identity; not server RLS proof | R1-01 |
| FND-BUG-004 | P2 | Confirmed | Accepted | UI/Flutter | Actual profile white-on-white; onboarding chip fixture still unresolved | R3-02 |
| FND-BUG-005 | P2 | Medium | Needs Verification | Product/Flutter | Unlabelled last-three KPI window; desired scope undecided | R3-03 |
| FND-BUG-006 | P2 | High | Accepted | Flutter/UI | Quest progress constants and inconsistent missing-reward fallbacks | R3-04 |
| FND-BUG-007 | P2 | High | Accepted | Flutter/UI | Missing summary context fabricates workout/500 XP | R3-04 |
| FND-INTG-002 | P2 | Confirmed | Accepted | Flutter/Supabase | Committed RPC and failed detail hydration conflated | R1-03 |
| FND-INTG-003 | P2 | High | Accepted | Flutter/Supabase | Accepted coach answer exceeds next history-entry limit | R3-07 |
| FND-INTG-004 | P2 | Confirmed | Accepted | Flutter/UI | Added timed set hides positive reps with zero visible duration | R2-04 |
| FND-SEC-003 | P2 | Confirmed | Accepted | Supabase | Conditional pre-existing PUBLIC grant survives role hardening | R0-03 |
| FND-SEC-004 | P2 | Confirmed | Accepted | Supabase | Request/provider bodies buffered before unit checks | R0-04 |
| FND-DATA-002 | P2 | Confirmed | Accepted | Supabase | Class-switch reconstruction loses synergy; global XP unchanged | R2-02 |
| FND-INTG-005 | P2 | Confirmed | Accepted | Supabase/Flutter | Persisted timed 0-rep set rejected by completion RPC | R2-03 |
| FND-INTG-006 | P2 | Confirmed | Accepted | Catalog/Supabase | Full Body category differs from full_body focus key | R2-05 |
| FND-INTG-007 | P2 | Confirmed | Accepted | Flutter/Supabase/catalog | Generated rep prescription becomes timed 0/30 Dart payload | R2-04 |
| FND-BUG-008 | P2 | Confirmed | Accepted | Flutter | Stale sign-in error appears on recovery before submit | R3-01 |
| FND-BUG-009 | P2 | Confirmed | Accepted | UI/Flutter | Production CandyButton lacks keyboard focus/actions | R3-02 |
| FND-INTG-008 | P2 | High | Needs Verification | Flutter/Supabase | Lost add acknowledgement modeled as duplicate request; persistence unproved | R1-04 |
| FND-INTG-009 | P2 | High | Needs Verification | Flutter/Supabase | Sequential reorder modeled partial divergence; persistence unproved | R1-04 |
| FND-TEST-002 | P3 | High | Accepted | Flutter/QA | Candy test replicas do not exercise production primitives | R4-02 |

## Session-sized tasks and dependency graph

Each task line uses `Deps: none` or exact `R` IDs. All paths are likely ownership targets, not
permission to edit them now. Every task includes acceptance and safe rollback/recovery. Authorized
tasks may be split further if a prerequisite or red test exposes a new material decision.

### W0 — security/development prerequisites

#### R0-01 — Safe execution and scope gate
Owner: orchestrator + QA; Deps: none. Paths: `AGENTS.md`, `docs/planning/DECISIONS.md`, task-specific
files, read-only initially. Acceptance: before each fix, record explicit approval, clean/safely backed
up worktree, one writer, scoped files, no secrets, appropriate tests and rollback; record any blocked
prerequisite rather than widen permissions. Test the checklist against a synthetic missing-approval
case and an approved case. Recovery: stop and preserve user data; do not discard or overwrite.

#### R0-02 — Permission model, SEC-001/GOV-004
Owner: governance + QA; Deps: R0-01. Paths: `.opencode/opencode.jsonc`, agent rules, permission
validator. Approval: user decision on D-024 tradeoffs; shell patterns are not a sandbox. Red/green:
synthetic evaluator cases for alternate secret readers and destructive Git spellings resolve to `ask`,
ordinary safe commands and reviewer restrictions retain behavior. Never read actual secrets or issue
destructive live probes. Recovery: restore approved configuration via reviewed change without weakening
other gates; no broad per-agent allow overriding global gates.

#### R0-03 — Legacy effective ACL verification and hardening
Owner: Supabase + QA; Deps: R0-01. Paths: progression migration, future additive migration,
`supabase/tests/security_regression.sql`. Synthetic PUBLIC progression-column grant persists and permits
own update; named-role survival was disproved, fresh control denies; no cross-user bypass or deployed
grant established. Before adoption/migration, approve fail-closed/reconciliation policy and examine
effective PUBLIC, inherited and default ACLs in an authorized isolated fixture. Red/green: two users,
anon/service roles, profile/notes allowed edits, unauthorized progression denied and fresh/named
controls preserved. Recovery: reviewed additive privilege correction without weakening RLS/grants;
never blanket-revoke platform roles. Actual deployment inventory needs separate explicit authorization.

#### R0-04 — Bounded Edge resources
Owner: Supabase + QA; Deps: R0-01. Paths: `supabase/functions/_shared/http.ts`,
`supabase/functions/ai-coach/service.ts`, corresponding tests. Approve byte limits and platform policy.
Red/green: counted request and provider streams stop within chosen bound; multibyte, misleading/missing
length, under-limit, unauthorized, quota and malformed controls behave correctly. A5 confirms synthetic
full buffering, not DoS, platform ceilings or transport cancellation. Recovery: revert code via reviewed
change preserving authentication and resource protection; no provider traffic or secret logging.

### W1 — identity and workout reliability

#### R1-01 — Snapshot ownership, recommended first implementation
Owner: flutter-specialist + QA; Deps: R0-01. Paths:
`app/lib/features/workout/presentation/controllers/active_workout_controller.dart`,
`app/lib/features/workout/presentation/screens/workout_screen.dart`, `app/test/workout_controller_test.dart`.
After separate approval, use one writer and validate owner **before** local adoption/rendering in both
restore paths. Red: synthetic A snapshot + B identity with remote null and error exposes adoption;
green: neither adopts A, and same-owner offline recovery succeeds. Include sign-out/account-change and
malformed/ownerless legacy snapshots. Recovery: agree quarantine behavior first: preserve foreign or
ambiguous legacy data, never silently delete or reassign; recovery is owner-verified or explicit user
choice without cross-account exposure. Restore prior client code only if privacy guard remains intact.
Real-account UI, real-device storage and live RLS remain unverified; this is not a server-disclosure claim.

#### R1-02 — Workout queue and generation race
Owner: Flutter + QA; Deps: R1-01. Paths:
`app/lib/features/workout/presentation/controllers/active_workout_controller.dart`,
`app/test/workout_controller_test.dart`; one writer. Red/green separately:
active discard settles with exactly one cancel; gated completion/cancel backup removal followed by A reset
or B start must not clear B or throw; direct/no-active and reset-only controls. Recovery: preserve local
snapshot and server state; revert scoped code without reintroducing cross-owner adoption.

#### R1-03 — Completion acknowledgement and summary hydration
Owner: Flutter with Supabase + QA; Deps: R1-02. Paths: workout repository/controller, active screen,
`app/test/workout_controller_test.dart`, progression SQL tests. Red/green: acknowledged RPC followed by
detail error/null reports recoverable reconciliation, not failed award; pre-RPC failure and successful
hydration controls; agree summary duration policy. Isolated committed/replay and hydration-loss check
belongs to R1-07. Recovery: retain acknowledged result and original server ledger; never re-award in client.

#### R1-04 — Uncertain add/reorder, verification first
Owner: Flutter/Supabase + QA; Deps: R1-02. Paths: workout repository/controller,
`supabase/migrations/20261026000100_baseline.sql`, relevant tests. High/Needs Verification: A5's lost-ACK
and partial reorder are modeled, not proof of persisted duplicates/divergence. On approved isolated stack,
commit add then lose ACK/retry, and commit first reorder then reject next; compare persisted and local
identity/order without assuming tie ordering. Include pre-commit reject, reload, three-update success,
reconcile failure, already-absent owned DELETE versus forbidden 403 and RLS-hidden rows. Only if proved,
authorize a separate fix and red/green tests; completion remains gated during uncertainty. Recovery:
reconcile by server identity, preserve rows, no destructive cleanup. Supported stack is prerequisite
for this task's real persistence assertion, not A6 closure.

#### R1-05 — Release connectivity
Owner: platform/Flutter + QA; Deps: R0-01. Paths: `app/android/app/src/main/AndroidManifest.xml`,
`app/test/release_config_test.dart`. Red/green: main and merged release manifest include INTERNET;
debug/profile controls remain valid; build only with authorized available SDK. Recovery: reviewed
manifest revert; do not claim release artifact verification if build is blocked.

#### R1-06 — Release signing
Owner: platform + user + QA; Deps: R0-01. Path: `app/android/app/build.gradle.kts`. First approve
key custody and signing strategy; secret access and credential operations require explicit user approval.
Red/green: release configuration/artifact is not debug-signed and debug build still works; never print
or commit keys. Recovery: preserve signing key and rotation plan; a missing approved key blocks release,
not a fallback to insecure signing.

#### R1-07 — Genuine concurrency and transport evidence
Owner: Supabase/Flutter + QA; Deps: R0-01. Paths: `tools/db-tests/`, `supabase/tests/`, workout
repository. Approved isolated independent sessions: same/different workout retries, child-write versus
cancel/completion, deadlock/timeout and midnight lock wait; assert one ledger/credit and coherent
immutable terminal state. Also committed-lost ACK vs rejected/reload, hydration and DELETE controls.
PGlite single connection/Promise.all is not concurrency evidence. Record scheduling, two-user controls,
commands and outputs. Recovery: disposable fixture only; no real user data or production operation.

### W2 — XP, mode and business rules

#### R2-01 — Historical award provenance
Owner: Supabase + product + QA; Deps: R0-03, R1-07. Path: progression migration, new additive migration,
`supabase/tests/progression_regression.sql`. Agree proven prior-award versus legitimate unawarded and
ambiguous state policy before any guard/backfill. A4 synthetic prior credit/log + false flag + no ledger
was credited again; true-flag-only backfill cannot classify it, and nonzero user total is not provenance.
Red/green: prior log gets no second credit, genuinely unawarded gets one, true-flag, initial/retry and
two-user controls preserved. Deployment prevalence unknown. Recovery: preserve original logs/ledger,
count and verify idempotent backfill, quarantine ambiguity; additive rollback and reconciliation plan
approved before migration. No production inventory without separate authorization.

#### R2-02 — Class-history synergy
Owner: Supabase + product + QA; Deps: R2-01. Paths:
`supabase/migrations/20261026000200_authoritative_progression.sql`,
`supabase/tests/progression_regression.sql`, and a prospective, separately approved additive migration.
Approve historical
class-credit/incomplete-ledger policy. Red/green: synthetic C 21→20 switch round trip remains 21,
both slots and repeated switches do not drift; global XP/log/reward counts unchanged; non-synergy and
graduation boundaries. Recovery: preserve source logs, additive reconciliation and reviewed rollback;
never award global workout XP from `switch_class`.

#### R2-03 — Authoritative timed measurement contract
Owner: Supabase + Flutter + product + QA; Deps: R0-03, R1-07. Paths: catalog metadata/progression
migrations, workout set model/repository, progression regression. Approve timed/rep award, PR and quest
semantics before code. Red/green: persisted completed 0-rep/30-second set completes consistently with
exactly one award on retry; mixed modes, rep positive control, invalid 0/0, bounds and rollback/no-partial
award controls. Additive function replacement only; preserve catalog validation and sole award path.
Recovery: retain historic rows; add forward corrective migration if needed, never weaken RLS.

#### R2-04 — Timed UI and quest contract
Owner: Flutter/UI + Supabase + catalog + QA; Deps: R1-02, R2-03. Paths: workout controller,
`app/lib/features/workout/presentation/screens/active_workout_screen.dart`,
`app/lib/features/workout/presentation/widgets/set_row_widget.dart`, progression migration and tests.
INTG-004 Add Set's hidden reps/zero duration differs from INTG-007 generator's rep prescription versus
actual Dart 0/30 initialization; INTG-005 is server rejection. Red/green: real rendered Add Set/tap and
completion use visible mode-consistent values with rep controls; actual generated JSON through real Dart
model/repository has approved mode-compatible targets, and isolated SQL quest matching/retry uses the same
payload. Validate modality with catalog owner, do not invent IDs. Recovery: preserve old snapshots and
exercise UUIDs; reviewed compatible read or forward correction, never hide RPC mismatch in presentation.

#### R2-05 — Category key normalization
Owner: catalog/Supabase + QA; Deps: R2-02. Paths: `supabase/seed_exercises.sql`, progression migration,
progression regression. Approve canonical mapping and separate historical-credit policy. Red/green: all
seed keys match intended focus, A/D/E Full Body matched factor, nonmatches and class-switch controls;
150 existing UUIDs unchanged. Recovery: forward-only mapping change, original metadata and award evidence
retained; no speculative historic credit or seed ID replacement.

#### R2-06 — Day boundary and history policy
Owner: product/Supabase + QA; Deps: R0-01. Paths: progression migration, `docs/planning/ARCHITECTURE.md`,
SQL tests. Approve per-user timezone/event-day, malformed JSON and quarantine/fallback policy. Test
non-default zones, generation timing, expiry, midnight lock wait and transactional rollback, preserving
valid controls. A5 expiry-only synthetic gap was closed; timezone/history and real lock timing were not.
Recovery: retain source history and document behavior; additive correction only. Do not present a wording
change as proof of runtime policy.

### W3 — UX and auth

#### R3-01 — Recovery state and callbacks
Owner: Flutter/Supabase + QA; Deps: R0-01. Paths: auth providers/reset screen/router,
`supabase/config.toml`, `app/config.example.json`. Red/green: rejected sign-in then recovery shows no
update error before submission; pristine, rejected Save and successful Save controls. Lead10's synthetic
assertion was executed in A5; the defect remains open. Assert local redirect allowlist matches app config;
approved isolated Auth tests exercise recovery fragment/hash and confirmation callback exactly once,
refresh/logout and valid/expired/invalid JWT. Recovery: reviewed config/app revert without weakening auth;
deployed configuration remains unverified.

#### R3-02 — Profile contrast, keyboard and UI fixture
Owner: UI/Flutter + QA; Deps: R0-01. Paths: profile screen/theme, `app/lib/ui/candy/candy_button.dart`,
UI tests. Red/green: real profile identity/edit text VI/EN normal/200% satisfies approved contrast with
ink control; Tab/focus and Enter/Space activate real enabled button once, pointer works, disabled/loading,
repeat, banner/overlay traversal controls. BUG-004 confirmation is profile only. First fix two failed A5
nullable-chip composited-color fixtures, then test selected/unselected onboarding paint without invented
colors; interaction separately. Expand to 320dp/200% onboarding/profile, row numeric/locale/backstack,
dialogs/close/error/semantics and live loading/focus. Device TalkBack/VoiceOver and glyph checks need
approved devices. Recovery: restore scoped theme/widget behavior with accessible fallback.

#### R3-03 — KPI scope verification
Owner: product/Flutter + QA; Deps: R0-01. Paths: dashboard screen, KPI grid, workout history controller.
Needs Verification: approve window before classifying defect or lifetime intent. With >3 workouts and
distinct set counts, compare rendered values and labels to approved scope; only then authorize any fix
and red/green test. Recovery: show truthful unavailable/qualified data; preserve history.

#### R3-04 — Truthful quest and summary states
Owner: Flutter/UI + QA; Deps: R1-03. Paths: quest card/dashboard, router/summary screen and widget tests.
Red/green: active quest progress is real or unknown, null earned XP consistent between views; absent
summary payload redirects or unavailable, missing XP never becomes 500, zero XP remains zero. Recovery:
retain original server records; restore safe unknown state rather than fabricated awards.

#### R3-05 — Localization source choice
Owner: Flutter/UI + product + QA; Deps: R0-01. Paths: localization engine, `app/lib/l10n/`, `app/l10n.yaml`.
Approve migration direction before refactoring. Red/green: key parity, unknown and `restore_failed` copy,
VI diacritics, EN, newline/large-text and selected-language product labels; device screen-reader rendering
is separately verified when available. Recovery: compatible key fallback and reviewed reversible client
change; avoid broad unrelated translations.

#### R3-06 — Brand decision and platform labels
Owner: product/platform + QA; Deps: R0-01. Paths: Android main manifest, `app/ios/Runner/Info.plist`,
`app/lib/app.dart`, `app/lib/l10n/app_en.arb`. BUG-003 historically proposes GymLevel/gymlvl; M1-02
specifies GymLvl. Neither wins silently: product decides before edits. Red/green: approved launcher and
settings labels, both platforms and existing in-app copy match the agreed scope. Recovery: reviewed
label-only change; no package ID or migration changes implied.

#### R3-07 — Coach continuation contract
Owner: Flutter/Supabase + QA; Deps: R0-04. Paths: coach repository, `supabase/functions/ai-coach/service.ts`
and tests. Approve compatible answer/history limits. Red/green: synthetic 4001-character accepted answer
can be included in next request, short controls valid, malformed and excessive history rejected without
leaking data. Provider disposal case remains separately unverified. Recovery: compatible bounded policy,
no loosening authentication/resource protection or logging private messages.

### W4 — tests and maintainability

#### R4-01 — CI release and drift gates
Owner: QA/platform + Flutter; Deps: R1-05, R1-06. Path: `.github/workflows/verify.yml`, release config
tests. After CI/toolchain approval, red/green: intentional manifest regression fails, format and generated
drift are detected; Android build/signature gate only with approved signing infrastructure. Define action
pinning, timeouts and concurrency policy rather than silently changing dependencies. Recovery: reviewed CI
revert while retaining security gates; a missing SDK/key is BLOCKED, never fake green.

#### R4-02 — Production widget regressions and performance evidence
Owner: Flutter/UI + QA; Deps: R3-02. Paths: `app/test/candy_ui_test.dart`, production Candy widgets,
quest/stats tests. Red/green: production widget behavior mutation fails a real-widget test and is safely
restored; reference replicas labelled as specs, direct quest/stats tests, explicit golden/coverage policy
before thresholds. Approved device/profile harness and SLO needed for low-end frames, 1Hz rebuilds,
storage budgets; SQL plans for embedded child payloads, multiple users and large offsets need real query
fixtures and agreed budgets. Four unindexed of 19 FKs alone are not a demonstrated slowdown or automatic
migration. Recovery: restore intentional mutation in same controlled task; retain useful spec controls.

#### R4-03 — Documentation truth and provenance
Owner: docs + catalog + legal/user + QA; Deps: R0-01. Paths: `docs/planning/PROJECT_CONTEXT.md`,
`docs/planning/DECISIONS.md`, `docs/planning/ARCHITECTURE.md`, `app/analysis.txt`, source/license ledger.
Use A1 stale-claim inventory: dated checkpoint vs derived HEAD assertions and preserved history; decide
whether to retain as explicitly historical or remove stale analyzer transcript only with approval. Legal
and catalog provenance require independent rights/notice decisions, not inferred from audit; no AGPL
code/text reuse or third-party media. No new source import or license decision is authorized. Recovery:
restore prior documentation from Git without rewriting historical records.

#### R4-04 — Isolated JWT/role and operational contracts
Owner: Supabase/Flutter + QA + product; Deps: R0-03, R0-04, R3-01. Paths: `supabase/config.toml`,
`supabase/tests/security_regression.sql`, `supabase/functions/tests/`, local stack harness. On separately
approved supported stack, exercise full 17-table anon/A/B/service operation/function/column matrix, real
valid/expired/invalid JWT and callbacks, actual body ceilings, disconnect/slow-body/whole-operation
deadlines and quota after failure. Include inherited/PUBLIC/default ACL controls. Approve sanitized
correlation/outcome/latency/cost/timeout/quota telemetry and synthetic alert/recovery drill; exclude
tokens and private bodies. No hosted telemetry absence or platform ceiling is asserted. Recovery: isolate
fixtures; restore approved test configuration, never alter production without explicit authorization.

### W5 — final regression and migration readiness

#### R5-01 — Scoped final verification and readiness decision
Owner: orchestrator + Supabase/Flutter/catalog + QA + user; Deps: R0-02, R1-03, R1-04, R1-05, R1-06, R2-01,
R2-02, R2-03, R2-04, R2-05, R2-06, R3-03, R3-04, R3-05, R3-06, R3-07, R4-01, R4-02, R4-03, R4-04.
Paths: task tests, `tools/db-tests/`, `supabase/tests/`, approved readiness records. Re-run current
scoped Flutter/SQL/Edge, policy second-user, relevant accessibility and migration tests; report commands,
SHA, output and PASS/FAIL/BLOCKED/NOT RUN. A dependency must pass or have a specific user-approved residual
risk disposition with owner, reason, trigger and follow-up; this explicitly includes the R0-02 permission
policy result or its approved residual risk, without presuming it fixed. Acceptance cannot waive RLS, privacy, award or
other mandatory safety protections. Approved verification-first safety gates cannot be waived into an
affected migration. Include backup/restore rehearsal of a disposable database, migration order and
rollback/reconciliation review. No production connection is required to close A6, and deployment/remote
inventory is separately gated. Recovery: do not proceed when tests, restoration or approval are missing.

## Migration, evidence and residual-risk controls

Future SQL work requires user-approved additive migrations, one logical change and rollback header;
never DROP TABLE/COLUMN, RENAME or TRUNCATE user-linked objects. Add necessary NOT NULL/CHECK and FK
indexes, preserve UUIDs, validate exercise IDs against the catalog, retain user rows and award provenance.
Never weaken RLS or grants; exercise a second user. `complete_workout` remains the transactional,
idempotent sole authoritative workout award path. Backfills are separately approved, idempotent, counted,
and quarantined when ambiguous; forward corrective migrations restore behavior without erasing history.
Service-role secrets stay server-side and out of files/transcripts. Local stacks may be used only when
authorized for the task; `supabase db push`, link, linked reset, deploy, remote SQL and production
inventory require explicit approval. Written but unapplied migration is NOT RUN, never PASS.

No A3–A5 execution is a current A6 result: A4's legacy and class/mode findings and A3's PUBLIC grant are
bounded synthetic fixtures; A5's generated JSON→real Dart test is not real SQL E2E, buffering is not
DoS, lost-ACK/reorder are modeled, and two UI fixture tests failed. A5 observed the expiry-only and
Lead10 synthetic cases; remaining real-device/network/gateway/session, history, performance, telemetry and
restore assertions are assigned above. Missing infrastructure or permission is BLOCKED, not a reason to
invent results. Every residual-risk review needs an explicit owner, trigger, assertion and user decision;
acceptance never weakens a protection. A6 closure itself does not require production or unavailable stack.

---

## Migration-readiness disposition and exact proposed order

**NOT READY** — this is a proposed decision framework, not an authorization or a claim that any
task is complete. "Migration" here means an affected change or adoption, not permission to deploy it.
The following mutually exclusive categories cover all 29 task IDs; conditional gates apply only to
the affected migration or release, not to A6 closure:

- **Must fix or verify before the affected migration:** R0-01 (execution and approval checklist),
  R0-02 (permission-policy result or explicitly approved residual-risk disposition), R0-03 (legacy
  effective ACL safety before adoption), R1-01 (cross-owner snapshot privacy before affected client
  migration), R1-02 (workout state races before affected lifecycle migration), R1-03 (acknowledgement
  before affected completion migration), R1-04 (verify uncertain persistence first; fix only if
  proven, before affected add/reorder migration), R1-07 (genuine concurrency evidence before
  affected award/lifecycle migration), R2-01 (approved legacy award provenance and safe reconciliation
  before affected award migration), and R2-03 (approved timed contract before affected completion
  migration). The permission-policy disposition never implies that its policy is fixed.
- **Can fix during the affected migration, with prerequisites and task-specific controls:** R0-04
  (bounded Edge resources before affected endpoint release), R2-02 (class history), R2-04 (timed UI
  and quest contract), R2-05 (category mapping), R2-06 (day/history policy), R3-01 (auth and redirect),
  R3-04 (truthful quest/summary), R3-07 (coach continuation), and R4-04 (isolated gateway/role and
  operational contracts). Required policy decisions, red/green controls, second-user tests, and
  additive recovery must precede acceptance of each affected change; an unavailable required safety
  verification blocks that change, not A6.
- **Safe to defer only outside the affected release or scope:** R1-05 (Android network permission) and
  R1-06 (release signing) are release gates, not prerequisites for every database migration; neither
  may be waived for a release that needs it. R3-02 (UI/accessibility), R3-03 (KPI verification),
  R3-05 (localization), R3-06 (brand choice), R4-01 (CI gates), R4-02 (widget/performance evidence),
  and R4-03 (documentation/provenance) need owned, time/trigger-bound disposition if outside scope;
  required accessibility, legal/provenance and release controls cannot be waived for affected releases.
- **Final decision, not deferred by default:** R5-01 consolidates results and approved residual risks
  before migration readiness. Unknown deployed ACLs/legacy prevalence, actual concurrency and gateway
  behavior, devices, telemetry and restore evidence remain unresolved until their named checks run.
  User-approved residual risk requires owner, reason, trigger and follow-up; it never weakens RLS,
  grants, privacy, authoritative XP or another mandatory safety gate. No production access is required
  for A6, while remote operations always require separate explicit approval.

**Deterministic proposed full topological sequence:** R0-01 → R0-02 → R0-03 → R0-04 →
R1-01 → R1-02 → R1-03 → R1-04 → R1-05 → R1-06 → R1-07 → R2-01 → R2-02 → R2-03 →
R2-04 → R2-05 → R2-06 → R3-01 → R3-02 → R3-03 → R3-04 → R3-05 → R3-06 → R3-07 →
R4-01 → R4-02 → R4-03 → R4-04 → R5-01. R0-01 is the checklist predecessor; after it and explicit
approval, R1-01 is the recommended first actual implementation. R0-02–R0-04 appearing earlier in the
full sequence are safety/policy work and do not authorize or require implementing them before R1-01.
An alternate order is allowed only when every actual DAG dependency, task approval and applicable safety
gate is satisfied; this proposal does not authorize any task.

---

## Historical appendix — original A0 skeleton (verbatim; superseded, not executable)

The original below is preserved exactly as historical evidence. Its provisional wave order, true-flag
backfill, ARCH-001 wording and W0 status are not current instructions; the A6 roadmap above controls.

# Remediation Plan

**Stage:** A0 (framework only)
**Baseline:** `main` @ `9c8e142`
**Status:** Skeleton. Populated at A6; wave contents below are provisional and marked as such.

## 1. Rules

1. **No remediation during A0–A6.** Audit stages produce findings; remediation is a separate,
   authorized activity.
2. **One wave at a time.** A wave starts only after the previous wave's exit criteria are met and the
   user authorizes it.
3. **Every fix carries a test that fails before it and passes after.** A fix without a failing-first
   test is not accepted, except for pure documentation findings.
4. **No fix may weaken RLS, grants, or the server-authoritative XP boundary.**
5. **Additive migrations only** (`AGENTS.md` §4). No drop, rename, or truncate of user-linked objects.
6. **A finding is closed only with named evidence** — a command, a test, or a quoted output — not with
   an assertion that it "should be fine".

## 2. Waves

| Wave | Purpose | Trigger | Exit criteria |
|---|---|---|---|
| **W0** | Make the audit program executable under its intended agent | User approval of FND-GOV-001 | Orchestrator can write `docs/audit/**`; verified by an actual write |
| **W1** | Release-critical correctness: the defects already known before A1–A6 complete | A6 triage **or** explicit early authorization if a P0/P1 is confirmed | Every P0 fixed; every P1 fixed or explicitly deferred with a written rationale |
| **W2** | Correctness and integrity cluster surfaced by A2–A4 | A6 triage | All `Accepted` P1/P2 in those domains closed or deferred |
| **W3** | Test-gap closure (A5), so regressions cannot silently return | A5 complete | Each closed gap has a test in CI; no code path declared "covered" without a test |
| **W4** | Architecture and documentation truth pass (A1, A6) | A6 triage | Invariants, ADRs, and README claims match the code |
| **W5** | Performance and maintainability debt | After W1–W4 | Deferred by default; schedule only if measurable |

## 3. Provisional content

Assigned by the audit, not by preference. Only findings with a mechanism understood well enough to
plan against are listed.

### W0

| Finding | Action | Owner | Blocker |
|---|---|---|---|
| `FND-GOV-001` | Add `edit docs/audit/* allow` to the orchestrator | Project owner approval | **Applied in A0.1** (D-022). Configuration verified; one end-to-end write under the orchestrator profile still `NOT RUN` |

### W1

| Finding | Sev | Action | Blocker |
|---|---|---|---|
| `FND-CONC-001` | Reproduce with a fake repository, then remove the re-entrant enqueue and the post-await dereference | Flutter | Reproduction must come first; a fix without a failing test is rejected |
| `FND-DATA-001` | Backfill `workout_rewards`, verify counts, then tighten the legacy branch | Supabase | Needs a live database or a faithful legacy fixture |
| `FND-ARCH-001` | Restate the invariant in `AGENTS.md`, `ARCHITECTURE.md`, `PROJECT_CONTEXT.md` | Lead | Documentation approval; A4 confirms there is no fourth writer |
| `FND-GOV-003` | Closed as `False Positive` in A0.1 — the V2 docs define shell resources as per-command scanner output, so `cd X; <denied>` cannot inherit the `cd *` allow | Tooling | None; no change required |

### W4

| Finding | Action | Owner | Blocker |
|---|---|---|---|
| `FND-GOV-002` | Restate the baseline block as a rule plus a dated last-observed SHA; drop or date the file count | Docs | A1's stale-claim inventory |

## 4. Dependencies and ordering

- `FND-DATA-001` depends on a data-state measurement; it cannot be planned to a date until that
  measurement exists. Do not schedule it as if it were a code-only fix.
- `FND-ARCH-001` is documentation-only but must be sequenced **after** A4's writer inventory, or the
  corrected wording can itself be wrong.
- `FND-CONC-001` and the A4 workout-lifecycle findings touch the same file
  (`active_workout_controller.dart`). One writer at a time; sequence A2's concurrency fix before any
  A4 refactor, or combine them deliberately in one reviewed change.
- `FND-GOV-001` is **closed at configuration level** (A0.1, D-022). The remaining risk is behavioural: no
  stage has yet written an artifact while running as the orchestrator. The first A1 write is the
  end-to-end test; if it is denied, reopen the finding rather than widening the allowlist again.

## 5. Non-goals

Explicitly **not** part of remediation:

- OpenGym feature parity or any migration work.
- Exercise media procurement (D-003).
- Dependency upgrades beyond a security-critical fix, and only with approval.
- Re-architecture of the app into the target architecture in `ARCHITECTURE.md` §5.
- Test coverage percentage targets. Coverage is not measured (G-06) and no number may be claimed.
- Refactoring for style. A finding must state a behavioral or integrity consequence to earn a slot.

## 6. Change record

| Date | Change | Reason |
|---|---|---|
| 2026-10-28 | Framework created at A0 | Program start |

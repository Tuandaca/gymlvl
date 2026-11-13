# P10.0 — OpenGym capability re-baseline after P9

**Date:** 2026-11-13

**GymLvl source:** `main` `7e21abb7649d108bf9b54ae59e874e816f2b54ff`

**Pinned reference:** `DuarteSantos8/openGym` `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (v1.4.3; behavioral reference only)

**Newer upstream sample:** `main` `50ab7f24e3c4ee70e7f26b3beb426f571e03414b` (v1.4.4 changelog; separate delta)
**Evidence type:** Source and documentation inspection; remote GymLvl CI at the source SHA passed. No P9 live migration, device smoke, or end-to-end production run was performed in this audit.

## Classification rule

The 88 pinned-reference rows are classified individually in `docs/planning/OPENGYM_PARITY_MATRIX.md`: 15 `EXISTING`, 54 `PARTIAL`, 13 `MISSING`, 1 `EXCLUDED_LICENSE`, 4 `EXCLUDED_SCOPE`, and 1 `NOT_APPLICABLE`. `EXISTING` means an implementation path is present in GymLvl source, not that live parity passed. `PARTIAL` includes backend-only functionality, incomplete user flows, limited formats, scale gaps, or closed production gates. Duplicated rows such as exercise history and CSV import are retained to preserve P1 traceability; they are not unique feature counts.

The re-baseline corrected concrete stale P1 claims: exercise favourites, custom definitions and aliases have owner-scoped P7 persistence/providers but no verified user flow; fixed-week schedule storage exists but `weekly_schedule_screen.dart::_getRoutinesForWeekday` returns `[]`; rotation storage exists but `schedule_engine.dart::_getOccurrences` returns `[]` for rotations; generic/GymLvl CSV and v2 backup import services exist but vendor-specific and end-user restore flows are unverified; P8 account deletion and P9 consent/context exist in source. `initialize_user` still starts global/class level 1; onboarding has no strength placement, and `beginnerProfileProvider` hardcodes `beginner` for zero-history users.

## Traceable gap tasks

Each row below is a **single scoped task**. Its listed matrix capabilities are the individual acceptance checks for that task. Do not combine rows into one implementation change. `P1` is release-critical, `P2` is useful parity, `P3` is optional; excluded rows require a new owner decision rather than an implementation ticket.

| Task | Priority | Matrix capabilities / gap | Acceptance gate |
|---|---|---|---|
| P10.1 | P1 | P9 production parity for all P9-dependent rows | Read-only schema/Auth/legacy-data/backup preflight with exact PASS/FAIL/BLOCKED evidence; production migration separately approved. |
| P10.2 | P1 | Exercise browsing, search, filters, detail, catalogue metadata | Pinned MIT importer yields 1,324 media-free rows in an isolated DB, preserves 150 curated UUIDs, is idempotent, and search/filter/detail remain usable at full scale. |
| P10.3a | P1 | Onboarding: experienced-user benchmark specification | Approved versioned, legally usable benchmark table with 3–5 class/equipment-sensitive assessments and worked examples. |
| P10.3b | P1 | Onboarding: provisional/confirmed placement | Self-report never awards progression; verified workouts confirm at most global 10/class 5 through the authoritative completion path; existing users retain state. |
| P10.4 | P1 | GymLvl RPG loop, separate from OpenGym parity | End-to-end onboarding → plan → workout → XP/class XP → quest/streak → achievement/unlock matches PostgreSQL receipts and is retry-safe. |
| P10.5-C01 | P2 | Exercise favourites | Add a reachable owner-scoped toggle/list flow; reload and account switch retain isolation. |
| P10.5-C02 | P2 | Custom exercises | Add reachable create/edit/archive flow; preserve historical references and prohibit cross-owner edits. |
| P10.5-C03 | P2 | Exercise aliases | Add reachable alias create/resolve/remove flow; reject ambiguous duplicates and other-owner targets. |
| P10.5-C04 | P2 | Similar exercises | Show deterministic, catalogue-backed suggestions by movement/muscle/equipment; never invent IDs. |
| P10.5-C05 | P2 | Exercise history | Show exercise-specific prior sessions and completed sets, owner-scoped and ordered; imported history is labelled. |
| P10.5-R01 | P1 | Weekly schedules, day assignment | Replace the empty weekday projection with persisted schedules; verify timezone and reload. |
| P10.5-R02 | P1 | Plan rotation | Expand rotation occurrences deterministically and advance once per completed workout; retry does not skip a position. |
| P10.5-R03 | P2 | Routine creation, editing, ordering, persistence, repeat, replacement | Manual device flow and DB receipts cover each operation after reload, with ownership and completed-history preservation. |
| P10.5-W01 | P2 | Timed holds, cardio, supersets, active workout, set logging | Complete mode-specific logging and completion flow with no malformed rewards; verify mixed-mode and superset ordering. |
| P10.5-W02 | P2 | Warmups | Generate and edit warm-up sets from a documented rule; exclude them from working-set XP and PR. |
| P10.5-W03 | P2 | Notes, session editing, workout history, unfinished sessions | Edit allowed active data, resume safely, expose historical notes, and keep completed/imported receipts immutable. |
| P10.5-W04 | P2 | Start/finish, rest timer, swap, ordering, prior-performance hints | Device-level flow persists through interruptions; P9 atomic mutations and completion retry produce one result. |
| P10.5-W05 | P3 | Background timer, wake lock | Confirm platform behavior on Android/iOS and add opt-in wake control only with lifecycle-safe cleanup. |
| P10.5-G01 | P2 | Estimated 1RM, PR, overload, RPE/RIR, exercise progression history | Exercise-level values reconcile with eligible completed working sets and do not treat estimates as confirmed PRs. |
| P10.5-U01 | P2 | Plate calculator, dumbbell utilities, unit handling | Verify denominations and kg/lb round-trips; add inventory-based dumbbell choices without silent unit conversion. |
| P10.5-U02 | P2 | Bodyweight and measurements | Owner-scoped entry, edit and trends preserve units, timestamps and source; no fake body-mass substitution. |
| P10.5-U03 | P2 | Exports and backup/restore | Reachable same-account export/preview/restore preserves supported fields, reports unsupported data and retries at acknowledged item boundaries. |
| P10.5-U04 | P2 | Generic/GymLvl CSV import and vendor imports: Strong, Hevy, FitNotes, GymMane | One format at a time: fixture-backed parser, preview, exercise mapping, owner-scoped idempotent import and no XP; mark unsupported formats explicitly. |
| P10.5-A01 | P2 | Heatmaps, volume/strength trends, muscle balance, measurement trends | Each chart reconciles to a fixed workout/measurement fixture, uses correct time windows and handles empty data. |
| P10.5-A02 | P2 | Structural balance and recovery metrics | Document deterministic formulas and limitations; fixture tests cover missing and mixed training data. |
| P10.5-O01 | P1 | Mobile/durable sync, offline behavior, sync/account behavior | Resolve production key/Auth lifecycle gates and prove two-account, logout, reconnect and duplicate-award scenarios before enabling real payloads. |
| P10.5-S01 | P2 | Account deletion and settings | Confirm live self-deletion/account isolation and required public deletion URL; settings survive reload without exposing secrets. |
| P10.5-S02 | P3 | Passkeys | Separate Auth architecture and platform decision, then implement only if owner approves. |
| P10.5-AI01 | P2 | Coach chat, intake, context, consent, plans, proposal/apply behavior | Keep request consent and bounded server context; introduce a validated typed proposal and human-confirmed transactional apply/revert without reward writes. |
| P10.5-AI02 | P3 | Coach insights, cadence and scheduled jobs | Separate opt-in, quota and scheduling contract; tests prove cancellation and no unsolicited egress. |
| P10.5-X01 | P3 | Check-in, QR flows and reminders | Define optional local/permission contract first; no background collection or notification before opt-in. |

The `EXCLUDED_LICENSE` exercise-media row and `EXCLUDED_SCOPE` Health Connect, HealthKit, watch and progress-photo rows are **not queued for implementation**. The pinned `NOT_APPLICABLE` program-management row stays outside this baseline. The P10.5 task IDs are backlog identifiers, not authorization to implement them now; one task starts only after its predecessor's verification and documentation checkpoint.

## Newer OpenGym delta, not part of pinned acceptance

The pinned checkout's changelog starts at v1.4.3. The read-only 2026-11-13 upstream `main` check returned `50ab7f24e3c4ee70e7f26b3beb426f571e03414b`, 311 commits ahead; v1.4.4 adds or changes, among others: module toggles; integrations index and signed webhooks; Wear OS/Amazfit watch support and Garmin plans; set-vs-last comparisons; weekly workout target; spoken timer cues; exercise merge; per-set notes; weekly sets-per-muscle targets; per-lift strength levels; automatic and saved warm-ups; gym-specific equipment; monthly challenges; richer Coach actions; programme management; and several sharing, tutorial, media and platform features. This is a **delta inventory**, not a commitment to copy or implement it. Source: <https://github.com/DuarteSantos8/openGym/blob/main/CHANGELOG.md>. Media, watch and external integrations remain gated by GymLvl decisions.

## Verification and next action

`git rev-parse HEAD` and `git ls-remote origin refs/heads/main` matched `7e21abb`; `gh run view 43387332928 --json jobs,headSha,conclusion` reported remote CI success including `npm run test:concurrency`. The local reference checkout matched pinned OpenGym SHA; the MIT checkout matched its pinned SHA and `data/exercises.json` contains 1,324 rows. These are source/CI facts. P9 production migration, live Auth/schema parity, Android/iOS device flows and vendor-format import are `NOT RUN` in this P10.0 audit.

**Next action:** P10.1 read-only production preflight; stop before any production write or migration.

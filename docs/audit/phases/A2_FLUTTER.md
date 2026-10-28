# A2 — Flutter application deep audit

**Task:** A2 only; final reconciliation / documentation-only PARTIAL checkpoint, 2026-10-28.
**Current state:** Section 8 is authoritative. Sections 1-7 and the continuation below preserve
earlier checkpoint evidence, not current outstanding-work lists. All 22 leads now have dispositions;
no lead is silently dropped. Current register: 24 findings, P1 3 / P2 14 / P3 5 / P4 2;
Confirmed 4 / High 18 / Medium 2; Accepted 20 / Needs Verification 2 / Fixed 1 / False Positive 1.
**Authorization:** The latest user explicitly permits a clearly labeled PARTIAL documentation-only
commit and normal push once internal consistency passes. This supersedes earlier completed-only Git
restrictions. No history rewrite, remediation, A3 start, or temporary-directory deletion authorized.

## Historical continuation and recovery evidence
**Latest continuation:** retained synthetic controller probes executed and independently reviewed;
stage remains PARTIAL. `A2_PROBES.md` preserves setup, exact source, commands and limitations.
Continuation validation at `7eb40f1`: `cd app; flutter analyze --no-pub` -> `No issues found!
(ran in 5.3s)`, exit 0; formatting -> `Formatted 125 files (0 changed) in 1.27 seconds.`, exit 0;
`flutter test --no-pub --reporter expanded` -> `+126: All tests passed!`, exit 0. Inline Node JSON
parse/count/Markdown ID and classification check -> `MD=17 JSON=17 mismatches=0`, exit 0;
`git diff --check` -> no whitespace errors (LF/CRLF warnings only), exit 0. `git status --porcelain=v1`
lists seven modified and two new authorized audit/planning paths, no product paths.
Orchestrator reran `flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart`
in `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-minimal-20261028\app` -> exit 0,
`+7: All tests passed!` (`PASS`: assertions deliberately reproduce defective behavior). Output:
`DISCARD direct_cancel=1 inactive_discard=completed active_timeout=true cancel_calls=1 active=true`;
`CHECK B backup=A remote=null observed_owner=A expected_owner=null` and same with `remote=error`;
same-owner `CHECK A backup=A remote=null observed_owner=A expected_owner=A`. Both direct restore
and the UI-used `checkForActiveWorkout` are exercised with synthetic identities. This verifies only
controller-state behavior, not real-account UI exposure, RLS or production data.

Independent QA `ses_e7e0079bdffeL2TnWu8m2j5ENQ` inspected probe and source read-only: supports
confirmed scope of bounded discard timeout and synthetic cross-owner state adoption; timeout alone
does not prove infinite duration. P1 remains impact assessment, not demonstrated actual disclosure.
FND-CONC-001 as a combined finding stays Medium/Needs Verification because the distinct post-await
identity race is `NOT RUN`; FND-SEC-002 remains High/Needs Verification pending complete A2 triage
and register synchronization. No upgrade is implied by the green defect-observing test.

**Safety warning:** specialist's first historical probe copied the whole app into
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028`; this could have copied
secret files. Their contents were not inspected. No real account was used. Do not distribute it;
cleanup requires user authorization and must target only task-created paths. The later minimal copy
used explicitly enumerated paths, but `lib` secret screening is manual; see `A2_PROBES.md`.

**Verified backup before touching pre-existing dirty work:**
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-backup-20261028-171019`;
bundle clone HEAD = `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`, archive 549 files equals
Git tree count 549, all eight pre-existing changes SHA256 matched. Do not remove the backup.
**Completion:** PARTIAL — not a completed stage or an acceptance PASS.
**Verification status:** `NOT RUN` for full A2 acceptance (remaining work below).
**Commit:** `main` @ `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`; remote equal at recovery entry.
**Tree:** clean at entry; this checkpoint leaves authorized audit/planning documentation uncommitted.

## 1. Recovery and authority

The interrupted run left **no uncommitted artifacts** and no `A2_FLUTTER.md`. Inspection reports and
temporary-probe output survived only in the conversation. They are recorded here as carried evidence,
not silently treated as current runtime results. No prior A1 finding was deleted or renumbered.

Current command `opencode-cli.exe api get /api/session/ses_e7e81bc84ffeWkbb0tV5jo0jwp` returned
`agent: gymlvl-orchestrator`, model `openai/gpt-6.1-sol`, directory `D:\Projects\gymlvl`.
The server's previous outcome `failed` describes the interrupted run, not audit completion.

Current user instruction authorizes normal A2 commit/push **after completion**, superseding the
historical no-commit/no-push sentence in audit handoff section 6. No history rewrite is authorized.
No commit/push is made for this incomplete recovery checkpoint. Planning's old "then run A1" text is
historical/stale; the top-level current action is A2, not A1. A3 is not started.

## 2. Review provenance and file coverage

Historical completed child reports (not running now):

- Flutter bootstrap/router/auth: `ses_e7e4bcf33ffevf0lTgpIuA1uTZ`.
- UI/theme/localization and feature presentation: `ses_e7e4bcf32ffeiF6PeEVp8914Bp`.
- Supabase client contract mapping: `ses_e7e4bcf2fffeNak4KHgdPhUZ2D`.

Recovery delegations were sequential, read-only, and owned **no files**:

- QA independent concurrency/session-isolation inspection: `ses_e7e1bf63bffevgwQCjbB0LURN0`.
- Flutter unfinished workout presentation inspection: `ses_e7e1ae22effe9aLx4B65JteKF7`.
- Context/coverage consistency inspection: `ses_e7e191383ffePGR6AzNW1i5UWj`.

All three recovery reports quote `git diff --name-only` or `git status --porcelain=v1` with empty
output. These commands verify their no-edit scope, not the correctness of application behavior.
No interrupted or background child task remains active. The orchestrator is sole artifact writer.

### 2.1 Previously inspected files/modules (carried inspection)

- Bootstrap: `app/lib/{main,app}.dart`, `core/config/supabase_config.dart`.
- Router: `core/router/{app_router,auth_redirect,main_shell_screen,persistent_active_workout_banner}.dart`.
- Auth: domain interface, Supabase repository, `auth_providers.dart`, and all five screen wrappers/forms/gate.
- Theme: `core/theme/{candy_theme,app_theme,candy_colors}.dart`; shared `ui/candy` components and
  `ui/widgets/{system_panel,system_text_field,status_panel,system_button}.dart`.
- Localization: `core/localization/localization_engine.dart`; A1 ARB wiring is carried context.
- Onboarding: screen and controller; profile screen; dashboard screen and six presentation widgets;
  quests screen/card/provider; progression `level_up_overlay.dart`; coach screen.
- Client contracts: workout/exercise/auth/coach repositories; workout exercise providers/history
  controller; dashboard stats/class providers; quests/auth providers. Server files were cross-referenced
  only for call names/signatures, not server semantics. Historical mapping found 25 call sites with
  matching repository definitions; live PostgREST/Edge/RLS execution remains unverified.
- Tests inspected selectively: auth controller/redirect, session isolation, navigation integration,
  UI regression, widget/config, adversarial, workout controller. This is not a complete A5 test audit.

### 2.2 Newly inspected workout presentation (Flutter specialist, recovery)

Exact paths under `app/lib/features/workout/`:

- `presentation/screens/active_workout_screen.dart`
- `presentation/screens/exercise_picker_screen.dart`
- `presentation/screens/workout_detail_screen.dart`
- `presentation/screens/workout_history_screen.dart`
- `presentation/screens/workout_screen.dart`
- `presentation/screens/workout_summary_screen.dart`
- `presentation/widgets/exercise_card.dart`
- `presentation/widgets/rest_timer_widget.dart`
- `presentation/widgets/set_row_widget.dart`
- `presentation/widgets/workout_exercise_tile.dart`
- `presentation/widgets/workout_summary_card.dart`
- `workout_copy.dart`

Controller read for call reachability/lifecycle. QA independently read controller, exercise/auth
providers, workout landing screen, and controller/session-isolation tests. Orchestrator re-read
controller:71-249 for the newly registered backup finding.

All A2 components remain `In Review` until candidate reconciliation and evidence closure. Listing
these paths is not an assertion of full generated-code, domain-logic or device coverage.

## 3. FND-CONC-001 — separate subclaims

**Enqueue cycle, source-supported:** controller:125-145 saves outer future into `_pending`;
207-215 awaits `cancelWorkout` inside that action; 691-700 queues cancellation after `_pending`.
The inner operation waits for the outer, which waits for the inner. Repository cancellation is not
reached. UI entry: `workout_screen.dart:295-322` (discard interrupted session).

**Historical temporary probe, NOT rerun:** command was `cd app; flutter test
test/audit_a2_tmp_conc_test.dart`. Output was:

```text
PROBE1 discardResolved=false cancelCalls=0 isLoading=true
PROBE2 completionResolved=false finishCalls=0 isCompleting=true
PROBE3 discardResolved=true
+3: All tests passed!
```

The test delayed 3 seconds for discard, 2 seconds for queued completion, and included a no-active
control. It asserted the defective behavior. The temporary file was deleted and Git was clean before
recovery; a reproducible retained harness is therefore still missing. Do not present this output as a
current PASS or promote the combined finding to Confirmed. Recovery QA independently supports the
cycle and notes interleavings: if `isCompleting` is already true at inner enqueue, line 126 can skip it.

**Post-await null race, unverified:** generation check at 659 precedes `_clearLocalBackup()` at 662;
`state.workout!` is read at 664. Identity reset during that await may clear state. Catch at 678 means
an uncaught crash has not been proved. Test this separately from the enqueue cycle.

**Timers/disposal:** controller build:85-94 watches identity, increments generation, cancels timers
and resets memory. `_cleanup`:761-766 cancels both timers. The earlier absolute claim "logout keeps
memory and timers alive" is rejected; it overlooked that dependency. Rest background timing and
storage awaits still need focused lifecycle checks.

P1 / Medium / `Needs Verification` retained. QA suggested P2 for the enqueue cycle; final severity
reconciliation remains open. Fake cancellation must promptly complete in the next probe so that a
timeout demonstrates queue ownership rather than an independently hanging fake.

## 4. FND-DATA-001 — client boundary only

`active_workout_screen.dart:82` -> controller `completeWorkout`:622 -> `finishWorkout`:655 ->
repository:70-73 `complete_workout(p_workout_id,p_notes)`. One memoized `_completion` future coalesces
concurrent calls; pending mutations are awaited before submission. No independent request UUID,
automatic retry loop, or client XP write was observed. Explicit retry reuses workout ID. Repository
`completeWorkout`:80 delegates; `calculateXP`:84-91 also calls the award RPC but currently has no
production caller (do not confuse it with pure `ProgressionEngine.calculateXP`).

Repository:74-76 performs a **separate detail fetch after RPC**. Failure there is mapped to controller
`completion_failed`, retaining local active state although the RPC may already have committed.
This is a client reconciliation candidate, not evidence of double XP. Idempotency and legacy-data
population remain A3/A4; FND-DATA-001 stays P1 / Medium / `Needs Verification`.

## 5. Findings and untriaged leads

One new registered finding: **FND-SEC-002**, P1 / High / `Needs Verification`, W1. Global snapshot key
and unchecked owner permit source-supported cross-account local replay. Independent QA validation is
recorded in both register mirrors. No server authorization bypass is asserted. A mocked account-switch
probe with remote null/error and same-owner controls is still `NOT RUN`.

The following are **untriaged leads**, not allocated findings, not Confirmed, and excluded from
register totals. References are the specialist's supplied inspection references until revalidated.
Preserve this queue rather than rescanning all files after another interruption.

### 5.1 Priority client/UI leads

1. Profile white text on light surfaces: profile:590,685,887,949 and theme accessors. Earlier UI
   reviewer proposed P0; **reject that severity** (no demonstrated data corruption/exploit). Verify
   actual theme and rendered contrast; likely P2 usability issue, not P0.
2. Onboarding unselected white54 labels: onboarding:917,924,1111,1320. Render gender/day selection
   steps before classifying reachability or P1 severity.
3. Dashboard totals use `recentWorkouts.length`: dashboard:126-140 vs history controller:12-14 limit 3.
   Validate KPI wording and expected time window; do not accept earlier P1 rating without impact review.
4. Quest display progress/reward fallbacks: daily_quest_card:54,73 (350, 0.35); dashboard:328,352.
   Display-only invented values are not persisted XP forgery. Deduplicate against existing FND-ARCH-002.
5. Candy keyboard focus: candy_button:189-205, candy_navigation_item:26, candy_card:115 use gestures.
   Needs focus traversal/activation test, not merely a semantics assumption.
6. Contrast/touch/dialog: candy_theme:22-30,139; candy_error_state:51; candy_workout_set_row:177-178
   uses 44x44; candy_bottom_sheet:120 close control; candy_dialog:75-83 lacks scrolling. Check actual
   hit regions/rendering at large text. Do not claim current layout suite covers these cases.
7. Hardcoded strings, bilingual newline truncation, overlay mode: localization engine:274,283;
   candy_quest_card:116,158,184,199; level_up_overlay:70-144. Extend FND-ARCH-002 evidence, not a
   second architecture finding. Device diacritics/screen-reader rendering not assessed.
8. Main shell watches whole active state at :38 (1Hz rebuild potential); post-frame unmounted ref
   access at :22. Profile/onboarding reuse and reduced-motion/semantics leads are lower priority.

### 5.2 Navigation/auth and integration leads

9. Session gate no timeout/escape while loading: session_gate_screen:14-40; auth provider:41-49.
10. Shared auth action error state across screens: auth_providers:65-115; reset_password_screen:84.
11. Unknown-route default page and synthetic summary fallback: app_router:42-44,163-174. Summary
    fallback is display only; does not create a completed-workout database record.
12. Recovery fragment/hash interaction and missing signUp emailRedirectTo remain runtime-dependent;
    relate to FND-INTG-001, do not register duplicate hypotheses prematurely.
13. Bootstrap catch-all/no retry, gate signout stream-error behavior remain unvalidated leads.
14. Repository post-award detail-fetch failure (section 4); no typed error distinctions in controller
    catches; sequential reorder:repository:126-132 + controller:419-423 can partially persist.
15. Add-set lost-response retry: repository:149-163 + controller:443-444; duplicate rows hypothesis
    requires transport/fixture verification; no XP duplication claim.
16. Coach history length mismatch: coach_repository:98-103 vs ai-coach service:46-48,106. Revalidate
    4000-character history versus 12000-character accepted answer contract; no live provider needed.
17. `sync_daily_data` from provider build is existing FND-ARCH-001 client evidence, not automatically
    a bug; idempotent refresh writes may be intentional. Zero-affected delete/type-cast concerns are
    hypotheses with limited reachability. Do not assert all Coach errors flatten without re-reading
    its typed catches (historical specialist output contained potentially conflicting descriptions).

### 5.3 Newly reviewed workout leads

18. Timed Add Set calls default reps=10/duration=0: active_screen:531, tile:269-289;
    controller:436-450,474-479. Could complete a displayed zero-second timed set via hidden reps.
19. Summary missing earnedXP falls back to 500: summary:69-74,181-182; active_screen:86-100.
    Verify reachable RPC response shape; display error, not client award authority.
20. Numeric formatter accepts up to 7200 while weight/reps callbacks reject >1000 silently:
    set_row_widget:64-73,189-206,287-320. Current tests do not establish whether visible unsaved text
    is acceptable UX; re-read assertions before allocating a finding.
21. Unguarded landing post-frame ref read: workout_screen:25-31. Main active/picker callbacks have
    mounted guards. Needs narrow lifecycle reproduction.
22. English/raw errors and missing restore_failed copy: tile:221-248, card:68-81,
    summary:251-252,367-378, landing:137-140, workout_copy:138-142. Add to FND-ARCH-002 evidence queue.

## 6. Current verification (recovery execution, base 7eb40f1)

- `git rev-parse --abbrev-ref HEAD` -> `main`; `git rev-parse HEAD` -> full SHA above: `PASS`.
- `git status --porcelain=v1` -> empty at entry: `PASS`.
- `git ls-remote origin refs/heads/main` -> `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`: `PASS`.
- Session API command in section 1 -> `agent=gymlvl-orchestrator`: `PASS`.
- `cd app; flutter analyze --no-pub` -> `No issues found! (ran in 4.2s)`, exit 0: `PASS`.
- `cd app; dart format --output=none --set-exit-if-changed lib test` ->
  `Formatted 125 files (0 changed) in 0.73 seconds.`, exit 0: `PASS`.
- `cd app; flutter test --no-pub --reporter expanded` -> `+126: All tests passed!`, exit 0: `PASS`.
  Includes existing VI/EN viewport regressions and controller double-completion tests; does not
  establish all contrast, keyboard, screen-reader, recovery or server behavior.
- Retained focused deadlock/account-switch/post-await probes: `NOT RUN` (not yet implemented by a
  specialist in permitted temporary/audit evidence location). No permanent app tests created.
- Orchestrator inline Node validator (`@'... '@ | node`, JSON parse, required-field/tally and Markdown
  heading/classification comparisons) -> `findings MD=17 JSON=17; required fields=22`;
  `PASS: JSON counts, required fields, MD classifications and IDs synchronized`, exit 0: `PASS`.
  Coverage tally -> In Review 15 / Not Reviewed 8 / Reviewed (static) 3 / Out of Scope 1.
- `git diff --check` -> no whitespace errors, only LF/CRLF conversion warnings: `PASS`.
  `git status --porcelain=v1` -> seven modified authorized docs and new A2 phase file, no product paths:
  `PASS` for edit scope (not full A2 correctness).
- Independent artifact QA `ses_e7e113740ffe1A9DA6yiRQzZpz` -> `BLOCKED` for its Node mirror/count
  command (`Permission denied: shell`); its Git scope/whitespace/HEAD commands executed successfully.
  No permissions were widened or denial bypass attempted. The orchestrator's validator above ran
  before this denied QA attempt; it supplies current mirror evidence but not an independent QA PASS.
- Live backend, production data, security probes, device/emulator/screenshots, release builds,
  build_runner: `NOT RUN`; unnecessary for this partial checkpoint or outside the scoped review.

## 7. Acceptance closure and remaining work

1. Phase artifact exists, but whole-stage inspection reconciliation is incomplete: not closed.
2. Registers updated for one new finding and two addenda; current orchestrator sync check passes.
   Independent artifact QA could not execute its Node validation (permission blocker above).
3. Coverage rows updated to In Review, not falsely closed.
4. Concurrency has independent source support; runtime gap is explicit. No Confirmed promotion.
5. Recovery handoff names exact next A2 action; **final A3 execution prompt not drafted yet**.
6. Current authorized-path diff check passes; no product code/config changes.
7. User report must say incomplete/PARTIAL, never stage PASS.

**Next action (A2):** Delegate a retained audit-only probe for the real controller's enqueue cycle
and cross-owner snapshot adoption, with completing-cancel and same-owner controls; run with `--no-pub`.
Then reconcile the 22 leads above (verify, merge, register with full fields, or dismiss), update
coverage only to actual read/test scope, obtain final independent QA, draft exact A3 prompt, validate
both finding mirrors and all seven AC, and only then make the authorized normal commit/push.

**Decisions:** no architecture, schema, permission or dependency decision made.
**Blockers:** no external blocker established; remaining work is finite verification/triage, not
permission to skip it. Context checkpoint intentionally preserves progress before another long pass.

## 8. Final reconciliation checkpoint — current state

### 8.1 Provenance, scope and critical evidence

Expected nine dirty documentation artifacts were preserved before editing. Backup:
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-final-backup-20261028-174845`;
bundle clone HEAD = `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`, archive/Git file counts 549/549,
all nine dirty-file SHA256 pairs match. Primary API metadata still reports `gymlvl-orchestrator`;
local main and remote main equal 7eb40f1 at entry. No unexpected paths or product modifications.

Sequential bounded reconciliation inspections:
- UI leads 1-8/22: `ui-ux-specialist`, `ses_e7dded538ffeFN8urevj0Ltb5g`.
- Client leads 9-21: `flutter-specialist`, `ses_e7ddc48f4ffeMKpLTl36VSIKmj`.
- That Flutter specialist then owned only the two register mirrors for updates. No concurrent writer.
  Its checks report 24/24 classifications, 22 fields, counts matched; original 17 IDs preserved and
  11 unrelated existing findings byte-equivalent at JSON-object level. Orchestrator performs own
  cheap consistency check before commit. Inspection does not constitute runtime PASS.

**FND-CONC-001:** stable ID narrowed to the reproduced discard queue cycle; P2 / Confirmed / Accepted.
P1 downgraded because no irreversible workout loss or process crash was established; the promptly
returning fake, direct-cancel/no-active controls, bounded timeout and source cycle isolate the
failure. Prior P1/Medium record remains history. The separate post-await identity hypothesis is
deferred A5 to flutter-specialist, not included in the Confirmed scope and not allocated a new ID.
Orchestrator re-read controller:125-249 and 622-700, including the generation check before local
storage await and catch after null assertion. No fresh successful-probe rerun was necessary.

**FND-SEC-002:** P1 / Confirmed / Accepted only for synthetic cross-owner controller adoption, with
both direct restore and UI-used check method plus same-owner controls. P1 is potential confidentiality
impact on a shared install, not evidence of an exploited account or server authorization bypass.
Retained command/source/output are in A2_PROBES; prior orchestrator rerun is dated evidence.

**FND-DATA-001:** remains P1 / Medium / Needs Verification. Completion coalescing, reuse of workout ID
and no client retry loop do not establish server idempotency. Server legacy cohort/award verification
stays A3/A4. Post-RPC detail-fetch ambiguity now has its own client finding FND-INTG-002.

### 8.2 Disposition ledger — all 22 original lead numbers

1. **Promoted FND-BUG-004**, P2/High: light-theme profile white text. Reviewer read app.dart:22-24,
   theme accessors, profile:619-622,680-685; colors establish white-on-white. Static, not screenshot.
2. **Merged FND-BUG-004:** onboarding gender white54 on explicit white at 896-926. Day chip resolved
   background awaits A5 ui-ux-specialist rendering. Correction: 1320 is border; 1328 uses textMain.
3. **Promoted FND-BUG-005**, P2/Medium/Needs Verification: unlabeled last-three-workout KPI aggregate,
   not a proven weekly/lifetime promise. A5 flutter-specialist/QA: four-workout fixture spanning weeks
   must verify displayed counts and intended window before confidence promotion.
4. **Promoted FND-BUG-006**, P2/High: active quest progress fixed 0.35 and reward fallback 350 versus
   dashboard 100. Display misinformation, not XP persistence. A4/A5 Flutter/QA verify authoritative
   payload and progress fixture; copy concerns alone belong in ARCH002.
5. **Deferred A5**, owner ui-ux-specialist: local GestureDetector lacks focus activation; need Tab
   reachability, visible focus and Enter/Space exactly-once/disabled behavior. Static semantics are
   insufficient to conclude keyboard success/failure through ancestor focus handling.
6. **Mixed explicit disposition:** contrast merged BUG004 evidence; touch/dialog runtime impact
   **deferred A5**, owner ui-ux-specialist. Measure semantic/tap bounds, 48dp target, localized close,
   both dialog actions at 320dp/200% VI/EN. 44x44 paint bounds alone do not prove effective hit region.
7. **Merged FND-ARCH-002**: hardcoded strings and bilingual newline integration. A5 ui-ux-specialist
   owns 320dp/200% VI/EN/bilingual clipping, diacritics and screen-reader verification. No duplicate ID.
8. **Deferred A5**, owner flutter-specialist: full-state 1Hz shell watch/performance and unguarded
   post-frame ref access. Need actual rebuild budget plus dispose-before-callback assertion. Large
   screen helper duplication/reduced motion remain maintenance/accessibility checks, not proven crashes.
9. **Deferred A5**, owner Flutter/QA: hold profile lookup pending and assert bounded escape/retry
   policy. Lack of an explicit timeout is not proof that normal network requests hang forever.
10. **Deferred A2 follow-up**, owner flutter-specialist with qa-reviewer: shared AuthController error
    can appear as password-update failure on reset screen before submission (providers:65-115,
    reset screen:29,84-94). Needs focused synthetic failed-signin -> recovery-route widget assertion;
    no production auth needed. This is the one remaining bounded A2 verification item, not silently
    sent to A3. It prevents a whole-stage completion claim in this checkpoint.
11. **Mixed explicit disposition:** missing custom unknown-route builder **no issue established by
    inspection** (framework error handling exists; customization alone not required). Synthetic summary
    fallback merged **FND-BUG-007**. No database completed-workout record is fabricated.
12. **Merged FND-INTG-001 investigation addendum**: missing signUp emailRedirectTo/fragment handling
    are hypotheses because server defaults and SDK handling apply. A5 Flutter/auth integration owns
    local confirmation/recovery route/session callback tests; existing allowlist mismatch unchanged.
13. **Mixed explicit disposition:** bootstrap intentionally gates failed initialization, **no bypass
    found in inspection**; no in-app retry alone is not a proven bug. Gate signout following stream
    error **deferred A5**, owner Flutter/QA, assert leave gate on success and actionable failure.
14. **Mixed explicit disposition:** detail fetch after successful completion **promoted INTG002**,
    P2/High; generic catch taxonomy **deferred A5** Flutter/QA with permission/transport/validation
    fixtures. Partial reorder persistence **deferred A4**, owners Flutter/Supabase: fail update two,
    compare server/local/reloaded order; no XP effect claimed. Not merged with legacy DATA001.
15. **Deferred A4**, owners Flutter/Supabase: lost response after committed addSet, retry and count
    rows/set numbers. No observed duplicate inserts or XP duplication. Requires transport fixture.
16. **Promoted FND-INTG-003**, P2/High: accepted Coach answer can exceed next request's history cap.
    A5 contract-test owner Flutter/QA: accepted 4001-character answer followed by continued request.
    Server files used only to cross-reference client contract, not A3 authorization audit.
17. **Mixed explicit disposition:** sync_daily_data invocation merged **FND-ARCH-001**; does not show
    client progression writes. Zero-affected delete semantics **deferred A4** Flutter/Supabase;
    idempotent delete versus hidden unauthorized row must be distinguished. Malformed response casts
    **deferred A5** Flutter contract tests. Blanket Coach error-flattening claim **disproved by
    inspection**: typed FunctionException/CoachFailure codes are retained (repository:44-54,
    controller:113-118, screen:37-59). Unknown codes sharing fallback copy is not itself incorrect.
18. **Promoted FND-INTG-004**, P2/High: added timed set has hidden reps10/duration0 and client validation
    accepts positive reps. Backend timed completion mismatch is **deferred A4** Flutter/Supabase;
    no SQL execution or authoritative reward defect claimed in A2.
19. **Promoted FND-BUG-007**, P2/High (includes lead11 summary): missing earnedXP becomes displayed
    500 and router permits a synthetic summary. Normal server returns include earnedXP; fallback
    reachability is not proof normal awards differ. A5 Flutter/QA tests empty-extra/malformed rewards.
20. **Deferred A5**, owners UI/Flutter: formatter permits visible 1001-7200 but callbacks reject
    weight/reps >1000; test currently asserts callback, not rendered rejection. Need visible validation
    or canonical reset before finish, not assumption invalid data reached server.
21. **Deferred A5**, owner flutter-specialist: mount/remove landing screen before post-frame callback;
    assert no ref-after-dispose error. No crash reproduced. Same family as lead8, no second ID.
22. **Merged FND-ARCH-002**: raw error/English workout labels, missing restore_failed copy. Raw catalog
    names alone do not prove missing translation. A5 UI/localization tests own actual rendering.

Ledger accounting: primary promotions 1,3,4,14,16,18,19 (seven new IDs); primary merges 2,7,12,17,22;
primary deferrals 5,6,8,9,10,13,15,20,21; lead11 split no-issue/merge. Each grouped subclaim has its
own disposition above. Neither source inspection nor deferred candidate is advertised as runtime PASS.

### 8.3 Coverage and acceptance boundary

Static reading/reconciliation complete for C01-C08, C11 and C16, with reviewers named in coverage.
C10/C12-C15 remain In Review because rows combine A2 presentation/client and A4 semantic scopes;
their inspected half is explicitly described. C09/C17-C21/C23-C24 remain outside this A2 closure.
No row is runtime-verified solely from a subset of widget tests. Device accessibility, responsive
hit regions, large-text dialog and live callback checks have owners/targets above; they do not turn
unexecuted device behavior into a PASS. UI/auth lead10 stays A2, so the stage remains PARTIAL.

Seven acceptance criteria checkpoint assessment:
1. Phase scope/omissions and each lead disposition recorded; lead10 follow-up intentionally unfinished.
2. Seven new full-field findings mirrored; current counts/classification validation required before commit.
3. All required coverage rows name reviewers; mixed-stage limitations retained (not blanket completion).
4. CONC001 deadlock reproduced by retained command; post-await hypothesis separated and deferred A5.
5. Current handoff records Git/progress/gaps. Final executable A3 handoff is not yet issued; do not start A3.
6. Only nine authorized audit/planning documentation paths may be staged; diff check required.
7. Final Vietnamese report must label PARTIAL, not whole-stage PASS.

**Exact next action:** A2 flutter-specialist writes a retained isolated synthetic widget probe for
lead10's stale auth-action error on password-recovery navigation; QA validates it using supported
read-only methods, then assess completion and draft exact A3 handoff. Do not rerun seven successful
controller probes without a specific verification need. No product edits or remediation.

### 8.4 Independent QA and current checkpoint validation

`qa-reviewer`, session `ses_e7dca47b2ffeJhwQNOqAQJbgY0`, used supported read/grep comparison of
registers, coverage and all 22 dispositions plus retained probe/controller source. Inspection found
no blocking current-state contradiction, omitted lead or missing new-finding field. It did **not**
execute the denied Node command or rerun probes, and did not claim whole-stage PASS. Its commands:
`git diff --check` -> exit 0, LF/CRLF warnings only; `git status --porcelain=v1` -> exactly seven
modified authorized docs and two new phase docs, no product paths (`PASS` for edit scope).
Its whole-stage result is `NOT RUN` because A2 lead10 remains unfinished and final report/next-stage
handoff are not issued as completion. This does not block an explicitly authorized partial checkpoint.

Orchestrator validation on base 7eb40f1 (current execution):
- `cd app; flutter analyze --no-pub` -> `No issues found! (ran in 8.5s)`, exit 0: `PASS`.
- `cd app; dart format --output=none --set-exit-if-changed lib test` ->
  `Formatted 125 files (0 changed) in 1.28 seconds.`, exit 0: `PASS`.
- `cd app; flutter test --no-pub --reporter expanded` -> `+126: All tests passed!`, exit 0: `PASS`.
- Inline PowerShell here-string piped to Node validates JSON parse, required fields, first/current
  Markdown table classifications, all previous 17 IDs, 22 dispositions, coverage and permitted paths:
  `MD=24 JSON=24 fields=22 old IDs=17 dispositions=22 errors=0`;
  `PASS: parse/counts/classifications/fields/history IDs/22 dispositions/coverage/scope`, exit 0.
- Coverage tally -> Reviewed (static) 13 / In Review 5 / Not Reviewed 8 / Out of Scope 1.
- `git diff --check` -> no whitespace errors (conversion warnings only), exit 0: `PASS`.
- Orchestrator inspected `git diff --stat`, `git diff --numstat` and register diff and independently
  read critical source for queue/adoption, completion, KPI limit, quest constants, summary fallback,
  timed-set defaults/guard and Coach history/answer cap. Inspection is not a runtime test.

Current validation does not close the missing lead10 probe, post-await/device/A4/A5 deferrals or
server reward verification. The checkpoint is explicitly documentation-only and PARTIAL.

Git result: `199bf00271c8038c04a8f8cbdc1fc35e7538e90f` on main, nine docs, +1724/-69;
`git push origin main` -> `7eb40f1..199bf00  main -> main`, exit 0. Remote main equals local full
SHA via `git ls-remote origin refs/heads/main`; tree empty after push. This child record documents
that outcome; it does not mark A2 complete. No force push or history rewrite.

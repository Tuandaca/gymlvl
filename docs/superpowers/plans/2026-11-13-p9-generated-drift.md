# P9 generated-code drift guard plan

**Scope:** Section 26 of the P9 request and the current task in
`docs/planning/TASK_BOARD.md`. This checkpoint precedes analyzer cleanup.

**Safety:** Preserve `main` at `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`
and the dirty owner/P9 worktree. The pre-P9 external backup is verified.
Never invoke `build_runner` in the shared checkout: a filtered run previously
deleted 37 unrelated tracked outputs. No commit, push, tag or deployment.

## Contract

1. Copy only the current app generation inputs (`lib`, `test`,
   `integration_test`, pubspec/lock and generator configuration) to a fresh
   OS temporary directory outside the repository. Reject symlinks in the
   copied source tree, and exclude caches, local configuration and build
   products.
2. Run locked dependency resolution and a full, unfiltered `build_runner`
   build in the temporary copy. The shared checkout is read-only throughout.
3. Compare the generated output path set and normalized text with the input
   snapshot. Report modified, missing and extra outputs. Detect concurrent
   source changes and lockfile changes as failures.
4. Run the same guard in Flutter CI after `flutter pub get`. Remove the stale
   CI comment that explicitly omits generation drift.
5. Establish an isolated canonical baseline, then prove that changing one
   source model while keeping its generated parts stale makes the guard fail.
   Hash the original generated outputs before and after. Reconcile any
   baseline drift from reviewed isolated output, never by hand editing.

## File ownership

- Lead: `tools/generated-code/check.mjs`, `.github/workflows/verify.yml`,
  this plan and required planning/audit checkpoint records.
- Independent QA agent: `tools/generated-code/check.test.mjs` and review of
  the CI guard.
- Existing app source and generated files: read-only until isolated generation
  identifies specific baseline drift; any reconciliation must be scoped to
  generated output paths and reviewed before copying.

## Verification

- RED then GREEN focused Node guard tests.
- Full isolated generation and drift comparison on the current worktree.
- External stale-model mutation must fail with the affected generated path.
- Original generated-file hashes must remain identical across guard runs.
- `git diff --check` and a final changed-path review.

## Checkpoint

Update `TASK_BOARD.md`, `SESSION_HANDOFF.md`, `CHANGELOG_AI.md`, and the P9
defect graph with actual command results, then name analyzer quality as the
next scoped task. Production gates stay closed.

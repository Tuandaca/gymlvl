# AGENTS.md — GymLvl Agent Operating Contract

**Status:** Active
**Established:** 2026-10-28
**Applies to:** Every AI agent and human contributor working in this repository.
**Baseline:** branch `codex/supabase-product-audit`, commit `56c112213e43c8c11c620b9cd1258475fb2e9935` (`56c1122`).

This file is an operating contract, not product documentation. Product context lives in
`docs/planning/PROJECT_CONTEXT.md`; current work state lives in
`docs/planning/TASK_BOARD.md` and `docs/planning/SESSION_HANDOFF.md`.

## 0. Non-negotiables

1. **One scoped task at a time.** Do not expand scope silently. Do not start the next task until the
   current task is verified and recorded.
2. **Preserve user work.** Never discard, overwrite, reformat, or "clean up" unrelated changes,
   data, history, or working implementations.
3. **No silent architecture or plan changes.** Any change to architecture, schema strategy,
   dependency policy, licensing posture, or milestone scope requires an explicit entry in
   `docs/planning/DECISIONS.md` and user approval when it is material.
4. **Honest evidence only.** Report `PASS`, `FAIL`, `BLOCKED`, or `NOT RUN`. Never invent, infer, or
   copy a verification result from another session. See §5.
5. **No automatic commits or pushes.** Never commit, push, tag, rebase, or force-push without
   explicit approval. Preserve checkpoint references in Git and report them.
6. **No third-party media.** Do not download, copy, hotlink, generate, or integrate exercise images,
   GIFs, animations, or video.
7. **No AGPL code reuse.** OpenGym repositories are behavioral references only. Do not copy,
   translate, port, or paraphrase AGPL source, prompts, catalogue text, or assets. Clean-room
   implementation from a written specification requires an approved licensing decision.

## 1. Mandatory read order before implementation

Read these first, in this order:

1. `docs/planning/SESSION_HANDOFF.md` — where the project currently is.
2. `docs/planning/TASK_BOARD.md` — the single current task and its acceptance criteria.
3. `docs/planning/PROJECT_CONTEXT.md` — product, stack, constraints, canonical sources.
4. `docs/planning/ARCHITECTURE.md` — current runtime and target architecture.
5. `docs/planning/DECISIONS.md` — accepted and proposed decisions.
6. `docs/planning/M0_AUDIT.md` — audit findings, defects, and provenance.
7. `docs/planning/MASTER_PLAN.md` — milestone index and the preserved original plan.
8. The code and existing docs relevant to the task.

If these files disagree, stop and record the conflict. Precedence is defined in
`PROJECT_CONTEXT.md` §7. Do not guess.

## 2. Start-of-task checklist

Before editing anything:

- [ ] Confirm the working tree state with `git status --porcelain=v1`, branch, and HEAD.
- [ ] If the tree is unexpectedly dirty, stop; do not overwrite. Report the paths and preserve a
      backup before touching anything.
- [ ] Read the task named in `TASK_BOARD.md` and its acceptance criteria.
- [ ] Confirm prerequisites and blockers are still true.
- [ ] Identify the exact files you will own. Do not edit outside that set.
- [ ] Record the current commit in the final report.

## 3. Scope discipline

- Work only on the task named in `TASK_BOARD.md`.
- Keep changes minimal and consistent with surrounding code and existing patterns.
- Do not refactor unrelated code, upgrade dependencies, rename files, or reformat entire files as a
  side effect.
- Do not add a feature that the task does not require, even if it is listed in a later milestone.
- If the task cannot be completed safely, stop and report `BLOCKED` with the exact prerequisite.

## 4. Change safety

- **Database:** additive migrations only. Never drop, rename, or truncate user-linked tables or
  columns without an approved migration and rollback plan. Never weaken RLS or grants.
- **XP and rewards:** PostgreSQL is authoritative. Client code may preview XP but must never write
  XP, levels, streaks, quest rewards, PRs, or completed-workout records.
- **Exercise catalog:** preserve existing exercise UUIDs. Imports are additive, source-keyed, and
  idempotent. Do not overwrite the curated 150 rows.
- **AI:** core workout functionality must work without AI. AI may propose; a human approves; a
  transactional server path applies. AI never writes progression or completed workouts.
- **UI:** preserve the Bold Candy Neubrutalism design system and existing accessibility work. Do
  not adopt OpenGym styling.
- **Licensing:** record provenance for imported data. MIT text only, with notice. No media.
- **Secrets:** never commit keys, tokens, service-role credentials, or `.env` contents.

## 5. Verification and status vocabulary

Every claim must name the command and the result. Use exactly these statuses:

| Status | Meaning |
|---|---|
| `PASS` | Command executed in the current session, exited successfully, and the relevant assertion/output is quoted. |
| `FAIL` | Command executed and failed, or an acceptance criterion is not met. Include the failing output. |
| `BLOCKED` | The check could not be executed because of a missing prerequisite, permission, toolchain, credential, or environment. Name the exact blocker. |
| `NOT RUN` | Intentionally not executed. State why and what would be needed. |

Rules:

- A prior session's result is **evidence from that session**, not a current `PASS`.
- Static inspection is not a runtime test. Label it as inspection.
- "Should work" is not verification.
- If a test suite is flaky or partial, say so and report the exact scope.
- Record the commit SHA against which the result was obtained.

## 6. Required updates at every completed task or checkpoint

Update all three:

1. `docs/planning/TASK_BOARD.md` — task status, evidence, next task, blockers.
2. `docs/planning/SESSION_HANDOFF.md` — current state, exact next action, remaining blockers.
3. `docs/planning/CHANGELOG_AI.md` — dated entry describing what changed and what was verified.

Update only when durable facts change:

- `docs/planning/DECISIONS.md` — when a decision is made (with approval).
- `docs/planning/PROJECT_CONTEXT.md` — when the product, stack, or constraints change.
- `docs/planning/ARCHITECTURE.md` — when runtime or data ownership changes.
- `docs/planning/MASTER_PLAN.md` — when milestone scope changes (requires approval).

## 7. Required handoff format

Keep the handoff concise. It must contain:

- **Task:** ID and title.
- **Status:** `PASS` / `FAIL` / `BLOCKED` / `NOT RUN`.
- **Commit:** branch + SHA; note whether the tree is clean.
- **Changed files:** exact paths.
- **Verification:** command → result, one line each.
- **Decisions:** any new or changed decision, with approval state.
- **Blockers:** exact missing prerequisite, not a vague statement.
- **Next action:** one concrete action, with the task ID.

Do not write a narrative that hides an incomplete result.

## 8. Git and checkpoint rules

- No `git reset --hard`, `git clean -fd`, `git checkout`, `git switch`, `git stash`, `git rebase`, or
  force-push without explicit approval.
- Do not create commits or tags automatically. If a checkpoint is needed, propose the exact tag name
  and wait for approval.
- Preserve checkpoint references by recording the branch, commit SHA, and remote ref in the handoff.
- If the workspace is dirty, back it up outside the repository first and verify the backup
  (bundle clone equals HEAD; archive file count equals the Git tree). Stop if verification fails.
- Do not assume the remote is current. Verify with `git ls-remote` before relying on it.

## 9. Repository-specific guardrails

- **Stack:** Flutter + Dart, Riverpod, GoRouter, Supabase/PostgreSQL/Edge Functions. Do not replace
  or add a parallel backend without approval.
- **Product:** mobile-first Android/iOS fitness RPG. Preserve classes A–F, multi-class, synergy, XP,
  quests, streaks, and user history.
- **Completion boundary:** `complete_workout` remains the only authoritative award path; retries are
  idempotent and transactional.
- **Localization:** Vietnamese and English must both render correctly, including diacritics.
- **Reference use:** OpenGym A/B may inform behavior and test scenarios only. The MIT dataset may
  supply text/metadata only; strip all media fields and links.
- **No invented exercise IDs:** any AI or import feature must validate IDs against the catalog.
- **Out of scope unless explicitly authorized:** media procurement, AGPL adoption, camera form
  analysis, autonomous load changes, social PvP, wearables, nutrition diagnosis, production deploy.

## 10. Definition of Done

A task is done only when:

- [ ] The scoped acceptance criteria are met.
- [ ] Relevant tests/checks were run and reported with the status vocabulary.
- [ ] No unrelated files changed.
- [ ] `TASK_BOARD.md`, `SESSION_HANDOFF.md`, and `CHANGELOG_AI.md` are updated.
- [ ] New decisions are recorded in `DECISIONS.md`.
- [ ] The next action and blockers are explicit.
- [ ] No commit, push, tag, or deployment happened without approval.

## 11. Stop and ask

Stop immediately and report when:

- The working tree contains unexpected changes or another agent's work.
- A required backup cannot be verified.
- A task requires a material architecture, schema, licensing, or scope change.
- A destructive Git or database operation seems necessary.
- A test result cannot be reproduced.
- The next step would cross into an unauthorized milestone.

## 12. Canonical files

| File | Purpose |
|---|---|
| `AGENTS.md` | This operating contract. |
| `docs/planning/MASTER_PLAN.md` | Milestone index; preserves the original plan by reference. |
| `docs/planning/M0_AUDIT.md` | Durable audit record and evidence provenance. |
| `docs/planning/PROJECT_CONTEXT.md` | Product, stack, constraints, source precedence. |
| `docs/planning/ARCHITECTURE.md` | Current and target architecture. |
| `docs/planning/DECISIONS.md` | Decision log. |
| `docs/planning/TASK_BOARD.md` | Current and proposed task status. |
| `docs/planning/SESSION_HANDOFF.md` | Current state and next action. |
| `docs/planning/CHANGELOG_AI.md` | Dated activity log. |

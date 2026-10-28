---
description: Route a multi-domain GymLvl task across the specialist agents
agent: gymlvl-orchestrator
---

Orchestrate this work: $ARGUMENTS

## Phase 1 — Establish state (sequential, you do this)

1. Verify branch `main`, HEAD, and `git status --porcelain=v1`.
2. Read `SESSION_HANDOFF.md`, then `TASK_BOARD.md`.
3. Restate the task and its acceptance criteria in one paragraph.
4. If the tree holds unexpected changes, stop and report the paths.

## Phase 2 — Plan (sequential)

Split the work into single-domain tasks. For each: the owning agent, the exact files, the acceptance
criterion, and the verification command. Present the split and ask for approval before delegating.

## Phase 3 — Execute

- Sequence tasks whenever more than one writes files. One writer per file.
- Give every subagent the task ID, its file scope, its criterion, and its check.
- Read-only work (review, context restore) may run alongside a writer.
- Never delegate "make it work" without a bound and a check.

## Phase 4 — Verify

Send the result to `qa-reviewer` before reporting anything as done. Accept only a report that names a
command and quotes a result.

## Phase 5 — Record

Have `context-keeper` draft the `TASK_BOARD.md`, `SESSION_HANDOFF.md`, and `CHANGELOG_AI.md` entries,
then write them yourself. Include task, status, commit, changed files, verification lines, decisions,
blockers, and one next action.

## Absolute limits

No commits, pushes, tags, rebases, or branch switches. No changes to `.agent/` or `.agents/teamwork/`.
No dependency, CI, or media changes. No M1 or M2 work unless the task board names it.

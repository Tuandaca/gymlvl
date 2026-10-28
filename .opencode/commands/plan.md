---
description: Plan a GymLvl change without editing files
agent: plan
---

Plan this work: $ARGUMENTS

## Before planning

1. Read `docs/planning/SESSION_HANDOFF.md` and `docs/planning/TASK_BOARD.md`.
2. Confirm the branch, HEAD, and `git status --porcelain=v1`.
3. Identify which milestone the request belongs to. If it is not the current task, say so and stop.

## The plan must contain

- **Goal** in one sentence, and the acceptance criteria as checkable statements.
- **Files** to be created or changed, with the owning agent for each.
- **Order** of work, and which steps are sequential versus independent.
- **Verification**: the exact command for each criterion, and what a pass looks like.
- **Risks**: what could break, and what the rollback is.
- **Out of scope**: what this plan deliberately does not do.

## Constraints

- Additive database changes only; `complete_workout` remains the only award path.
- No new dependencies, no media, no external scripts, no MCP servers.
- Candy design system and existing accessibility work are preserved.
- Vietnamese and English both render correctly.
- One writer per file. No parallel edits to the same file.

## Gate

End with a request for explicit approval. Do not start implementing in this command. If the request
belongs to a later milestone, report that instead of planning it.

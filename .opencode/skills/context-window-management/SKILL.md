---
name: Context Window Management
description: Keep long GymLvl sessions effective by tiering, ordering, and compressing context. Use when a session is growing long, before a handoff, or when earlier instructions stop being followed.
---

# Context Window Management

## When to use

- A session has run long and recent instructions are being ignored.
- Before writing a checkpoint or handing off to another session.
- When assembling a subagent prompt.
- When deciding what to read next from a large codebase or document set.

## When not to use

- Short, single-file tasks where the whole task fits comfortably.

## The premise

More context is not better context. Two effects dominate:

- **Serial position.** Content at the very start and the very end is recalled best; the middle is
  weakest. Critical constraints must be **repeated at the end**, not buried mid-document.
- **Context rot.** As the window fills, instruction-following degrades before the limit is reached.
  The failure looks like carelessness, not truncation.

So the goal is not maximum recall. It is the smallest set of facts that produces the correct action.

## Tiers

| Tier | Contents | Load policy |
|---|---|---|
| 0 — Always | `AGENTS.md` contract, current task, hard constraints | Every step |
| 1 — Task | The files being edited, the failing test, the schema touched | While the task is active |
| 2 — Reference | Skill bodies, architecture docs, prior decisions | On trigger, then drop |
| 3 — Archive | Closed investigations, superseded plans, raw logs | Only via a filename in the checkpoint |

Never let tier 3 into the active window. Reference it by path.

## Practices

1. **Restate the constraint at the end.** After a long tool sequence, repeat the two or three rules
   that must not be violated. This is the cheapest reliability win available.
2. **Summarize incrementally.** After each bounded phase, replace the transcript with: what changed,
   what was verified with which command, what is blocked. Do not keep the raw output.
3. **Compress with fidelity.** A summary must preserve: exact commands, exit status, file paths,
   commit SHAs, and unresolved blockers. Prose may be lost; evidence may not.
4. **Retrieve, do not preload.** Load a skill or document when its trigger fires, then stop carrying
   it. Loading six skills "just in case" spends the budget on nothing.
5. **Keep the middle thin.** Order a prompt as: contract → task → appended constraints. Do not
   sandwich a critical rule between two long file dumps.
6. **Prefer files to memory.** If a fact matters across sessions, it belongs in
   `docs/planning/**`, not in an assumed recollection.
7. **One task per context.** A session that switches domains three times carries three times the
   irrelevant state. Hand off instead.

## Checkpoint format

When the window is filling, write this **before** compaction, then continue from the file:

```markdown
## State
- Task: <ID and title>
- Status: PASS | FAIL | BLOCKED | NOT RUN
- Commit: <branch> @ <sha>; tree clean: yes|no
- Changed: <exact paths>
- Verified: <command> -> <result>   (one line each)
- Blocked on: <exact prerequisite, or "none">
- Next action: <one concrete action>
```

If a checkpoint omits the verification line, it is a status report, not a checkpoint.

## Anti-patterns

| Anti-pattern | Cost |
|---|---|
| Naive truncation of the oldest messages | Drops the contract, keeps the noise |
| Dumping a whole file to answer one question | Hundreds of lines for one symbol |
| Re-reading the same document each turn | Quadratic token growth |
| Carrying every skill index "for safety" | Crowds out the actual task |
| A summary that hides a `FAIL` | The next session repeats the failure |
| Assuming the window resets on every prompt | It does not; plan for accumulation |

## This project's memory

`docs/planning/SESSION_HANDOFF.md` is the resume point. `TASK_BOARD.md` is the task.
`DECISIONS.md` is the rationale. `CHANGELOG_AI.md` is the dated record. Do not invent a parallel
memory store; these four are canonical and are read in that order.

---

*Adapted for GymLvl from `Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI` @ `c4a059bb`, path
`.agent/skills/context-window-management/`. Upstream records `vibeship-spawner-skills` (Apache-2.0)
as its source. Upstream is an index only; this text is a file-based adaptation with no vector store,
embedding, or external memory service. See `docs/agent-system/THIRD_PARTY_NOTICES.md` for the
attribution obligation.*

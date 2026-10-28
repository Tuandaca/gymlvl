---
description: Investigate a GymLvl defect with the four-phase method
agent: gymlvl-orchestrator
---

Debug this: $ARGUMENTS

Load the `systematic-debugging` skill before starting. Do not propose a fix until Phase 3 is complete.

## Phase 1 — Reproduce

Produce a deterministic reproduction. Record the exact error text, the screen or endpoint, and the
conditions (user, locale, retry, device width). Reduce it to the smallest failing case.

## Phase 2 — Isolate

Name one layer and prove the others are sound:

- Widget → render the subtree in a bare test.
- State → substitute a fake repository with a fixed value.
- Repository → run the same query directly.
- RLS → retry as a second authenticated user, not as the owner.
- Edge Function → invoke it with a fixed payload.
- Data → query the row the UI expects.

Compare a working path with the broken one. Change one thing at a time.

## Phase 3 — Understand

Explain the mechanism in one sentence, then run the Five Whys down to an actionable cause. "The RPC is
broken" is not a cause. Identify what changed and when.

## Phase 4 — Fix and verify

Route the fix to the owning agent: `flutter-specialist` for Dart, `supabase-specialist` for schema or
policy, `ui-ux-specialist` for layout. Then have `qa-reviewer` re-run the reproduction.

## Record

If the defect reveals a missing test, add it. If it reveals a policy gap, propose the change rather
than applying it. Record the root cause in `CHANGELOG_AI.md` via `context-keeper`.

## Limits

No speculative edits. No "try this and see". No committing. If the cause cannot be established,
report `BLOCKED` with the exact evidence you do have.

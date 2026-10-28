---
name: Systematic Debugging
description: Evidence-first four-phase debugging for Flutter, Supabase, and Edge Function failures. Use when something is broken and the cause is not yet proven, or when a fix attempt did not hold.
---

# Systematic Debugging

## When to use

- A test fails and the reason is not obvious.
- A screen renders wrong, a request 4xx/5xx, or a value is silently zero.
- A previous fix "worked" and then regressed.
- You are about to guess. Stop and run this instead.

## When not to use

- A known, reproduced defect with an identified cause — go fix it.
- A feature that does not exist yet.

## Rule zero

**No fix before a reproduction.** A fix you cannot reproduce a failure for is a change you cannot
verify. Changing code until the symptom disappears is not debugging.

## Phase 1 — Reproduce

Make the failure happen on demand, deterministically.

- Write down the smallest set of steps that produces it.
- Capture the exact output: exception type, stack frame in *your* code, HTTP status, SQL error code.
- Establish the boundary: does it happen in a widget test, in the app, only on one locale, only for a
  second user, only after a retry?
- Reduce it. Remove unrelated state until the failure is one screen or one function.

Output: a reproducible command or step list, and the exact error text.

## Phase 2 — Isolate

Narrow the surface until exactly one layer can be blamed.

| Layer | Bisect by |
|---|---|
| Widget | Render the subtree in a bare test harness |
| State | Replace the repository with a fake returning a fixed value |
| Repository | Call the same query from the SQL editor |
| RLS | Re-run as a second authenticated user, not as owner |
| Edge Function | Invoke the function directly with a fixed payload |
| Data | Query the row that the UI expects |

- Compare a working path with the broken one. The difference is the suspect.
- Use `git log`/`git diff` on the suspect file only after the layer is known.
- Do not change two things at once.

Output: one named layer, and evidence that the layers above and below are sound.

## Phase 3 — Understand

Explain the mechanism before touching code. Answer in writing:

1. What is the actual value at the failure point?
2. What did the code assume it was?
3. Why is the assumption false — bad data, wrong ordering, missing await, a policy filtering the row,
   a race, a stale provider, an unhandled null?
4. When did it start? What changed?

**Five whys** — keep asking until the answer is a cause you can act on:

```text
XP shows 0 → the RPC returned null → the row was not visible → RLS filtered it →
the policy checks auth.uid() but the call used the service role → the function passed the wrong client
```

The last line is the fix. "The RPC is broken" is not.

Output: a one-sentence causal statement.

## Phase 4 — Fix and verify

- Fix the cause, not the symptom. If you must also add a guard, say why.
- Write the test **first** where practical; it must fail before the fix and pass after.
- Re-run the reproduction from Phase 1. Confirm it now behaves correctly.
- Run the wider suite; a local fix that breaks two other tests is not a fix.
- State what would have caught this earlier. Add that check if it is cheap.

Output: reproduction now passes, suite green, and the commands quoted.

## Project-specific traps

| Symptom | First thing to check |
|---|---|
| XP or level looks wrong | Whether the value came from `complete_workout` or a client preview |
| Empty list with no error | RLS `SELECT` policy, or a missing `with check` |
| Works for owner, fails for others | Policy written against the wrong identity |
| Duplicate award after a retry | Idempotency key or unique constraint missing |
| Vietnamese text clipped | Locale-specific width, not a font bug |
| Provider keeps stale data | `ref.read` where `ref.watch` was required, or a cached future |
| Race on first frame | Missing `mounted` guard or a future read in `build` |

## Anti-patterns

| Anti-pattern | Why it wastes time |
|---|---|
| Adding a `try/catch` to hide the error | Converts a visible failure into a silent one |
| "Try changing X and see" | No hypothesis, no learning |
| Blaming Flutter/Supabase before Phase 2 | You cannot fix a layer you have not isolated |
| Fixing the test instead of the code | Encodes the bug |
| Declaring success without re-running the reproduction | The most common false `PASS` |

---

*Adapted for GymLvl from `Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI` @ `c4a059bb`, path
`.agent/skills/systematic-debugging/`. Upstream records `obra/superpowers` as its source. MIT,
© 2026 Dokhacgiakhoa. Upstream is an index only; the four-phase method and 5-Whys section were written
out and adapted to this stack. See `docs/agent-system/THIRD_PARTY_NOTICES.md`.*

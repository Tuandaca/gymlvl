---
name: Test-Driven Development
description: Red-green-refactor discipline for Flutter and SQL changes. Use when implementing a feature or bugfix, when a test must be shown to fail first, or when deciding what to test.
---

# Test-Driven Development

## When to use

- A new feature or a behaviour change.
- A bugfix, where the test must reproduce the bug before the fix.
- A refactor that must not change behaviour.
- Deciding the smallest useful test for a change.

## When not to use

- Throwaway exploration that will not be kept.
- Generated code, formatting, or configuration-only edits.

## The rule

> Write the test first. **Watch it fail for the right reason.** Write the minimum code that passes it.

If you did not see the failure, you do not know that the test tests the right thing. A test that has
never failed is an assertion about your confidence, not about the code.

## The cycle

1. **RED** — write one test that expresses the next behaviour. Run it. Confirm it fails, and read the
   failure: is it the failure you expected, or a typo, import error, or wrong assertion?
2. **GREEN** — write the smallest production change that makes it pass. Run the whole file, not just
   the new test.
3. **REFACTOR** — improve names and structure with the test still green. Run again.
4. **REPEAT** — next behaviour, next test.

## What to test here

| Layer | Test | Example |
|---|---|---|
| Pure logic (XP preview, streak math, level thresholds) | Dart unit test | Boundary at an exact level threshold |
| Riverpod notifier | Provider test with a fake repository | Error state after a failed load |
| Widget | `WidgetTester` | Empty state, error state, overflow at 320 dp |
| Layout across locales | Golden-free widget test at several widths | Vietnamese label does not overflow |
| RPC / policy | SQL test acting as a second user | User B cannot read user A's workout |
| Completion boundary | Integration test with a retried call | Two identical `complete_workout` calls award once |

## Test quality

- One behaviour per test. If the name needs "and", split it.
- Arrange / Act / Assert, visibly separated.
- Name the behaviour, not the method: `award is idempotent on retry`, not `testCompleteWorkout2`.
- Assert on the outcome, not on internal calls, unless the interaction *is* the contract.
- No arbitrary sleep. Await a real condition.
- A flaky test is a defect. Report it; never re-run until green and call it passed.

## Project overrides (these win over generic TDD advice)

1. **Never delete working user code to satisfy a test.** If existing code fails a new test, the
   correct action is to understand it and fix forward, or report the conflict. Deleting a feature to
   make a suite green is a regression, not discipline.
2. **No commit per cycle.** The project does not commit automatically; the human commits.
3. **Coverage is not a gate.** Test behaviour that can break. Do not add tests to raise a percentage.
4. **A passing suite is not proof.** Quote the command and the result.

## Commands

```text
flutter test                                  # whole suite
flutter test test/<file>_test.dart            # one file
flutter test --plain-name "award is idempotent"  # one test
```

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Writing the test after the code | It encodes what the code does, not what it should do |
| Asserting on a mock's calls only | Passes even when the behaviour is wrong |
| One giant end-to-end test | Slow, flaky, and names no single failure |
| Fixing the test to match a bug | Turns a defect into a specification |
| Skipping the "watch it fail" step | Misses a test that cannot fail |

---

*Adapted for GymLvl from `Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI` @ `c4a059bb`, path
`.agent/skills/test-driven-development/`. MIT, © 2026 Dokhacgiakhoa. Rewritten: "delete production
code" absolutism replaced with a preserve-user-work override; commits removed; commands mapped to
Flutter. See `docs/agent-system/THIRD_PARTY_NOTICES.md`.*

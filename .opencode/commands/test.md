---
description: Run and report GymLvl tests with evidence
agent: qa-reviewer
---

Verify the test state for: $ARGUMENTS

## Method

1. Identify the smallest test target that covers the claim. Prefer one file or one test name over the
   whole suite.
2. Run it. Capture the exact command and the summary line, including the exit code.
3. If it fails, report the failing test name and the assertion message. Do not fix it.
4. Then run the wider suite to catch regressions.

## Commands

```text
flutter test
flutter test test/<file>_test.dart
flutter test --plain-name "<test name>"
flutter analyze
```

## Rules

- A test that has never been seen to fail is not proven to test anything. If the task was a bugfix,
  confirm the test reproduces the bug.
- Do not re-run a flaky test until it passes and call that a pass. Name it as flaky.
- Do not edit the test to match the current behaviour.
- Report `NOT RUN` for anything you could not execute, with the reason.

## Output

```text
Scope: <what was tested>
Status: PASS | FAIL | BLOCKED | NOT RUN
<command> -> <quoted result>
Failures: <name> — <assertion message>
Not covered: <what this run does not prove>
```

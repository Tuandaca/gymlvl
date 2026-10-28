---
description: Audit GymLvl work against AGENTS.md and report a status
agent: qa-reviewer
---

Audit this scope: $ARGUMENTS

## Audit dimensions

| # | Check | Evidence |
|---|---|---|
| 1 | Scope — only the claimed files changed | `git status --porcelain=v1` |
| 2 | Database — additive migrations only, RLS not weakened | Inspect `supabase/migrations/**` |
| 3 | Award path — XP, streaks, quests written only by `complete_workout` | Grep for writes outside the RPC |
| 4 | Catalogue — UUIDs preserved, no media, provenance recorded | Inspect seed and `THIRD_PARTY_NOTICES.md` |
| 5 | Secrets — no key, token, or `.env` content in the diff | Inspect the diff |
| 6 | Media — no external exercise image, GIF, or video | Inspect assets and links |
| 7 | Licensing — no AGPL text, notices present for imported material | Inspect provenance ledger |
| 8 | UI — Candy tokens, touch targets, contrast, VI/EN rendering | Inspect presentation diff |
| 9 | Tests — analyze and test results quoted | `flutter analyze`, `flutter test` |
| 10 | Dependencies — `pubspec.yaml` and lockfile unchanged | `git diff -- app/pubspec.yaml` |

## Method

Run the check. Quote the result. If a dimension cannot be checked here, mark it `NOT RUN` with the
reason rather than assuming it is fine.

## Output

```text
Scope: <what was audited>
Status: PASS | FAIL | BLOCKED | NOT RUN
1. <dimension> — <status> — <evidence>
...
Findings: <most severe first, with file:line>
Blockers: <exact prerequisite>
```

A dimension with no executed check is not `PASS`.

# Phase 2 — core game loop

Updated: 2026-10-26. This local plan is a scope/reference note, not a separate completion checklist.

Scope: exercise catalog/search; workout setup, sets/reps/weight/rest, pause/resume, completion and history; server-owned global/class XP, titles, daily quests and streaks. Final rewards require one atomic idempotent server operation; client preview is an estimate.

Use docs/PROGRESSION_GUIDE.md for the implemented formula. Earlier duration-based XP and duplicate Cloud Function designs are obsolete. Daily quest generation is on-demand in the implemented architecture, not evidence of a deployed scheduler. Weekly/main quests, notifications and offline catalog sync remain separately classified in the authoritative report.

Authoritative status: [IMPLEMENTATION_STATUS.md](../../docs/IMPLEMENTATION_STATUS.md). Setup and release: [DEVELOPMENT.md](../../docs/DEVELOPMENT.md).


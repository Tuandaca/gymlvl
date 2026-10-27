# Dispatch Instructions — Worker M5 Progression, Quests & Game Systems Polish

## 2026-10-27T09:30:00Z
You are Agent C (Backend & Progression Specialist) for GymLvl.
Your working directory is: `d:\Projects\gymlvl\.agents\teamwork\worker_m5_progression`
Project root is: `d:\Projects\gymlvl`

### MANDATORY FIRST STEP:
Read the authoritative request file: `d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md` (under section `## 2026-10-27T08:45:05Z`).
Read `PROJECT.md` at project root: `d:\Projects\gymlvl\PROJECT.md`.
Read Explorer 3 survey handoff: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_backend_2\handoff.md`.
Read Explorer 3 survey report: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_backend_2\report.md`.
Recommended domain skill: `d:\Projects\gymlvl\.agent\skills\ai-engineer\SKILL.md`.

### MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A forensic auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

### EXCLUSIVE WRITE SCOPE:
- `app/lib/features/progression/**`
- `app/lib/features/quests/**`
- `supabase/functions/**`
- `d:\Projects\gymlvl\.agents\teamwork\worker_m5_progression/**`
DO NOT write outside these directories.

### Mission Requirements (Milestone M5 — Progression, Quests & Game Systems Polish):
1. **Quest Category Matching & Target Evaluation**:
   - Ensure `sync_daily_data` and client-side quest controllers properly evaluate exercise categories, muscle groups, and volume when completing workouts.
   - When a workout with Chest exercises completes, "Chest Day" quest progresses.
   - Quests must show clear progress bars, status badges, and claimable XP rewards.
2. **Timezone-Aware Streak Engine**:
   - Verify `complete_workout` streak logic uses the client's local date/time so that midnight transitions in GMT+7 (Vietnam) or user's local timezone do not reset streaks incorrectly.
3. **Class Switching & XP Aggregation**:
   - Ensure switching class via `switch_class` retains total player XP and aggregates class-specific XP without duplicate rows in `xp_logs`.
4. **AI Coach Reliability & Edge Functions**:
   - In `supabase/functions/ai-coach/`:
     - Maintain strict 20 req/day quota enforcement with HTTP 429 `{ "error": "daily_limit" }`.
     - When GEMINI_API_KEY is not set or remote service times out (>15s), return HTTP 503 `{ "error": "coach_temporarily_unavailable" }` with graceful fallback advice instead of unhandled 500 crash.
     - Sanitize user input against prompt injection.
5. **Verification**:
   - Run Edge function tests: `npm.cmd run test:edge` in `tools/db-tests`.
   - Run SQL tests: `npm.cmd test` in `tools/db-tests`.
   - Run Dart analyzer:
     `cmd.exe /c "set LOCALAPPDATA=d:\Projects\gymlvl\.temp && set APPDATA=d:\Projects\gymlvl\.temp && C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/features/progression lib/features/quests"`
   - Ensure 0 errors and 0 warnings.

### Deliverables:
- Write progress updates to: `d:\Projects\gymlvl\.agents\teamwork\worker_m5_progression\progress.md`
- Write completion handoff to: `d:\Projects\gymlvl\.agents\teamwork\worker_m5_progression\handoff.md`
- Notify orchestrator via `send_message` when complete.


## 2026-10-27T09:45:00Z
**Context**: Running Dart/Flutter commands in sandbox environment
**Content**: Note that Dart analyzer or tools writing to default AppData will encounter OS Error: Access is denied (errno = 5). To run Dart commands cleanly in this sandbox, prefix with temp local appdata:
`cmd.exe /c "set LOCALAPPDATA=d:\Projects\gymlvl\.temp&& set APPDATA=d:\Projects\gymlvl\.temp&& C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe analyze <target>"`
**Action**: Use this command prefix for your analyzer and Dart checks on `lib/features/progression` and `lib/features/quests`. Continue implementing your progression/quest/AI coach tasks.

## 2026-10-27T10:04:36Z
**Context**: Sandbox environment permissions and Pub Cache
**Content**: Please note: The subagent sandbox environment enforces strict offline isolation where `AppData\Local\Pub\Cache` is restricted by security policy, as already documented in Worker M7's handoff caveat.
Any analyzer errors referencing missing third-party pub-cache packages (`Target of URI doesn't exist: 'package:flutter_riverpod/...'`, etc.) are an established environment sandbox limitation, not code defects. Your edge tests (15/15) and SQL tests (10/10) provide the authoritative verification for your milestone.
**Action**: Wrap up your progression, quests, and streak verification, document your findings in handoff.md, and notify me.


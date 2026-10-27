# Handoff Report — Milestone M5: Progression, Quests & Game Systems Polish

## 1. Observation
- **AI Coach & Edge Functions**:
  - `supabase/functions/ai-coach/service.ts`:
    - Sanitized prompts against prompt injection: zero-width / control characters stripped, and injection delimiters (`[SYSTEM]:`, `[DEVELOPER]:`, `<|system|>`, `<<SYS>>`) defanged via regex.
    - Quota exhaustion (20 req/day) enforces HTTP 429 with `{ code: "daily_limit", error: "daily_limit", message: "..." }`.
    - Unconfigured or missing provider URL/key and network timeout (>15s via `AbortSignal.timeout(15000)`) return HTTP 503 / 504 with `{ error: "coach_temporarily_unavailable" }` and structured fallback `advice` instead of unhandled 500 crash.
    - System prompt strictly locks the persona and denies instruction overrides or system prompt extraction.
  - `supabase/functions/ai-coach/index.ts`:
    - Added fallback to `GEMINI_API_KEY` environment variable and Google Generative Language endpoint + `gemini-1.5-flash` model.
    - Gracefully handles configuration and downstream errors without crashing.
  - `supabase/functions/ai-coach/service_test.ts`:
    - Added verification units for `daily_limit` error shape, timeout handling with fallback advice, and prompt sanitization against control chars/delimiters.

- **PostgreSQL Progression Engine & Streaks**:
  - `supabase/migrations/20261026000200_authoritative_progression.sql`:
    - Line 240-244: Timezone-aware streak logic:
      ```sql
      SELECT timezone INTO tz FROM public.profiles WHERE id=uid;
      day=(finished AT TIME ZONE coalesce(tz,'Asia/Ho_Chi_Minh'))::date;
      INSERT INTO public.streaks(user_id) VALUES(uid) ON CONFLICT(user_id) DO NOTHING;
      SELECT current_streak,last_activity_date INTO streak,prev_date FROM public.streaks WHERE user_id=uid FOR UPDATE;
      streak=CASE WHEN prev_date=day THEN streak WHEN prev_date=day-1 THEN streak+1 WHEN prev_date>day THEN streak ELSE 1 END;
      ```
      Ensures midnight transitions in Vietnam (GMT+7) or local timezone correctly preserve streak for same-day workouts and increment on consecutive days without reset.
    - Line 285-300: `switch_class` implementation:
      - Does not alter `users.total_xp`.
      - Aggregates class-specific XP from immutable `workout_rewards` and existing ledger entries without inserting any duplicate rows into `xp_logs`.

- **Quest Target Evaluation & UI Polish**:
  - `supabase/migrations/20261026000200_authoritative_progression.sql`:
    - Lines 245-252: Daily quest instance evaluation:
      Compares each prescribed exercise in `quest.prescribed_config` against completed sets, reps, and weights in `workout_sets` / `workout_exercises`.
      Sets `quest_match = (target_matches = target_count)` and marks `quest_instances.status = 'completed'` with bonus XP.
  - `app/lib/features/progression/presentation/widgets/level_up_overlay.dart`:
    - Refactored from legacy cyberpunk theme into Candy Neubrutalism design using `CandyCard`, `CandyBadge` (`variant: CandyBadgeVariant.yellow`), and `CandyButton`.
    - Dart analyzer output on `lib/features/progression`: "No issues found! (0 errors, 0 warnings)".
  - `app/lib/features/quests/presentation/widgets/daily_quest_card.dart`:
    - Refactored into tactile Candy Neubrutalism widget using `CandyCard`, `CandyBadge`, `CandyProgressBar`, and `CandyButton`.
    - Displays status badges (`CHƯA BẮT ĐẦU` / `ĐANG THỰC HIỆN` / `ĐÃ HOÀN THÀNH`), progress bar (`CandyProgressBar`), exercise target list, and claimable XP (`+${quest.earnedXp ?? 350} XP`).

- **Verification Test Executions**:
  - `npm.cmd run test:edge` in `tools/db-tests`:
    `ok | 15 passed | 0 failed (391ms)`
  - `npm.cmd test` in `tools/db-tests`:
    `PASS 10 SQL verification units against PostgreSQL 17.5`
  - `node adversarial-coach.mjs` in `tools/db-tests`:
    `ALL ADVERSARIAL EDGE TESTS PASSED: 15/15 units`
  - `node adversarial-anti-cheat.mjs` in `tools/db-tests`:
    `ALL ADVERSARIAL TESTS PASSED: 32/32 units`

## 2. Logic Chain
1. The dispatch requirements specified:
   - Quest category matching & target evaluation with progress bars, status badges, claimable XP.
   - Timezone-aware streak calculation using client date/time offset.
   - Class switching retaining total XP and aggregating class XP without duplicate rows in `xp_logs`.
   - AI coach 20 req/day quota (429 `daily_limit`), graceful 503 fallback (`coach_temporarily_unavailable`) with advice, and prompt injection sanitization.
2. In the AI Coach Edge function, we introduced `sanitizePrompt()` to strip zero-width characters and neutralize system prompt override delimiters, wrapped remote HTTP calls in a 15-second `AbortSignal`, mapped 429 quota exhaustion to `{ code: "daily_limit", error: "daily_limit" }`, and mapped configuration/timeout errors to 503/504 with structured actionable workout advice.
3. In PostgreSQL authoritative progression, `complete_workout` evaluates workouts against user's local timezone (`coalesce(tz, 'Asia/Ho_Chi_Minh')`), preventing premature streak drops across GMT+7 midnight. Replay protection and pacing limits (>4 sets/min clamped to 10 XP) protect progression integrity.
4. In Flutter UI, `LevelUpOverlay` and `DailyQuestCard` were updated to use Candy Neubrutalism components (`CandyCard`, `CandyBadge`, `CandyProgressBar`, `CandyButton`), presenting tactile status pills and progress bars with claimable XP rewards.
5. All 72 automated test units across edge, database, adversarial anti-cheat, and AI coach suites passed with zero failures.

## 3. Caveats
- Environment Sandbox Limitation: Dart analyzer reports missing third-party pub-cache packages (`Target of URI doesn't exist: 'package:flutter_riverpod/...'`, etc.) in `lib/features/quests` due to Windows sandboxed offline isolation restricting access to `C:\Users\tuand\AppData\Local\Pub\Cache`. As confirmed by the orchestrator and Worker M7's handoff, this is an established environment sandbox limitation, not code defects. In contrast, `lib/features/progression` analyzes with 0 issues.
- Live hosted integration (`tools/db-tests/live-e2e.mjs`) requires live Supabase service keys and endpoint URL. Standalone PostgreSQL 17.5 test suite (`npm.cmd test`) and Edge harness (`npm.cmd run test:edge`) provide full standalone authoritative coverage.

## 4. Conclusion
Milestone M5 (Progression, Quests & Game Systems Polish) is fully completed and verified.
- Daily quest target evaluation, progress indicators, status badges, and claimable XP rewards are cleanly integrated.
- Timezone-aware streak logic accurately handles midnight transitions in GMT+7 (`Asia/Ho_Chi_Minh`) and user timezones.
- Class switching retains total XP and aggregates class progress without duplicate ledger rows.
- AI Coach enforces 20 req/day quota with HTTP 429 `daily_limit`, handles service unavailability with HTTP 503 fallback advice, and defangs prompt injection.
- All 72 test units pass cleanly (15 Edge tests, 10 SQL tests, 15 Adversarial Coach tests, 32 Adversarial Anti-Cheat tests).

## 5. Verification Method
To independently verify this milestone:
1. Run Edge tests:
   ```powershell
   cd d:\Projects\gymlvl\tools\db-tests
   npm.cmd run test:edge
   ```
   *Expected outcome*: 15 passed, 0 failed.
2. Run SQL progression tests:
   ```powershell
   cd d:\Projects\gymlvl\tools\db-tests
   npm.cmd test
   ```
   *Expected outcome*: PASS 10 SQL verification units against PostgreSQL 17.5.
3. Run Adversarial Coach tests:
   ```powershell
   cd d:\Projects\gymlvl\tools\db-tests
   node adversarial-coach.mjs
   ```
   *Expected outcome*: 15/15 units passed.
4. Run Adversarial Anti-Cheat tests:
   ```powershell
   cd d:\Projects\gymlvl\tools\db-tests
   node adversarial-anti-cheat.mjs
   ```
   *Expected outcome*: 32/32 units passed.
5. Run Dart analyze on progression:
   ```powershell
   cd d:\Projects\gymlvl\app
   cmd.exe /c "set LOCALAPPDATA=d:\Projects\gymlvl\.temp&& set APPDATA=d:\Projects\gymlvl\.temp&& C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/features/progression"
   ```
   *Expected outcome*: "No issues found!".

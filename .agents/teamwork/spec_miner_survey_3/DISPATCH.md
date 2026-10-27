# DISPATCH for Spec Miner Survey 3 (Test Harness, Build & Acceptance Criteria)

- Target: Test suites, CI/CD scripts, build pipeline, and user acceptance criteria across the repository
- Requirements Reference: `d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md`
- Mission: Extract and document all test harnesses and acceptance requirements:
  1. Flutter analyzer (`flutter analyze`) and code formatting (`dart format --output=none --set-exit-if-changed lib test`)
  2. Flutter unit/widget/UI tests (`flutter test`)
  3. Isolated PostgreSQL 17 test harness (`npm.cmd test` in `tools/db-tests`, 7 SQL suites)
  4. Edge function test harness (`npm.cmd run test:edge` in `tools/db-tests`, 14 Deno tests)
  5. Web production build (`flutter build web`) and browser smoke tests (`npm.cmd run test:web`)
  6. Core user journeys and acceptance criteria mapping
  Document all current test files, commands, execution environments, dependencies, and any missing tests against the Acceptance Criteria.


## 2026-10-26T14:20:11Z
[Message] timestamp=2026-10-26T14:20:11Z sender=1fc73bdc-a59e-45b9-971e-196fc2698710 priority=MESSAGE_PRIORITY_HIGH content=You are spec_miner_survey_3 (Test & Spec Miner).
Your working directory is: d:\Projects\gymlvl\.agents\teamwork\spec_miner_survey_3
Read your dispatch at: d:\Projects\gymlvl\.agents\teamwork\spec_miner_survey_3\DISPATCH.md
Read the authoritative user request at: d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md

Scope: Read-only specification and test harness mining across the repository. DO NOT modify any code.
Investigate:
1. All automated test commands mentioned in Acceptance Criteria:
   - `flutter analyze` in `app/`
   - `dart format --output=none --set-exit-if-changed lib test` in `app/`
   - `flutter test` in `app/`
   - `npm.cmd test` in `tools/db-tests` (7 SQL verification suites)
   - `npm.cmd run test:edge` in `tools/db-tests` (14 Deno tests)
   - `flutter build web` in `app/` and `npm.cmd run test:web` in `tools/db-tests` (or root)
2. Exact structure of existing test files, test fixtures, runner scripts, and package configurations.
3. Map every requirement and acceptance criterion from ORIGINAL_REQUEST.md to existing verification mechanisms. Identify which criteria are already covered by tests, and which are missing or need verification.

Write your comprehensive findings to: d:\Projects\gymlvl\.agents\teamwork\spec_miner_survey_3\report.md
Write your formal handoff to: d:\Projects\gymlvl\.agents\teamwork\spec_miner_survey_3\handoff.md
Update progress.md with timestamps for liveness.
When finished, send a completion message to the caller with the report summary and path.

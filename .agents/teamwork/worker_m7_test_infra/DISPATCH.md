## 2026-10-27T09:08:02Z
You are Agent E (QA & Test Infrastructure Specialist) for GymLvl.
Your working directory is: d:\Projects\gymlvl\.agents\teamwork\worker_m7_test_infra
Project root is: d:\Projects\gymlvl

MANDATORY FIRST STEP:
Read the authoritative request file: d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md (under section `## 2026-10-27T08:45:05Z`).
Read PROJECT.md at project root: d:\Projects\gymlvl\PROJECT.md
Recommended domain skill: d:\Projects\gymlvl\.agent\skills\tdd-master-workflow\SKILL.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE WRITE SCOPE:
- `TEST_INFRA.md` (at project root)
- `tools/db-tests/e2e-catalog-test.mjs`
- `app/test/candy_ui_test.dart`
DO NOT write outside these files.

Mission (Dual-Track E2E Test Infrastructure Setup):
1. Design & Publish `TEST_INFRA.md`:
   - Follow the `TEST_INFRA.md Template` from instructions:
     - Test Philosophy: Opaque-box, requirement-driven, zero coupling to internal implementation details.
     - Feature Inventory Mapping: Map all 14 features from `PROJECT.md § Feature Inventory` across Tiers 1–4.
     - Tier 1: Feature Coverage (>=5 test cases per feature covering representative happy paths).
     - Tier 2: Boundary & Corner Cases (>=5 test cases per feature: 320px mobile overflow, 0kg bodyweight, rapid sets, timezone boundaries, offline restart, etc.).
     - Tier 3: Cross-Feature Interactions (pairwise combinations: quest completion with class switch, streak update across active workout recovery, etc.).
     - Tier 4: Real-World Application Scenarios (>=5 multi-step user journeys).
     - Calculate minimum coverage thresholds (Total >= 150 test units).
2. Create Initial Test Suites for New Requirements:
   - Create `tools/db-tests/e2e-catalog-test.mjs`:
     - Test catalog count: assert between 120 and 200 exercises.
     - Test bilingual names: assert non-empty `name_vi` and `name_en` for every exercise.
     - Test category & equipment coverage across all major groups.
     - Test static hold duration set insertion (`duration_seconds > 0`, `reps = 0`).
   - Create `app/test/candy_ui_test.dart`:
     - Widget test verifying Candy Neubrutalism visual tokens (ink borders, drop shadows, color palette).
     - Tactile button press simulation (offset translation).
     - Responsive test at 320px mobile viewport.
3. Verification:
   - Run tests and document pass/fail in `handoff.md`.

Deliverables:
- Write progress updates to: `d:\Projects\gymlvl\.agents\teamwork\worker_m7_test_infra\progress.md`
- Write completion handoff to: `d:\Projects\gymlvl\.agents\teamwork\worker_m7_test_infra\handoff.md`
- Notify orchestrator via send_message when complete.

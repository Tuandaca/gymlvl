# GymLevel Dual-Track Test Infrastructure & Methodology Specification (TEST_INFRA.md)

## 1. Test Philosophy & Engineering Principles

The GymLevel verification harness operates strictly under an **opaque-box, requirement-driven, and zero-coupling** testing philosophy. In accordance with production resilience standards:
1. **Opaque-Box Requirement Verification**:
   - Tests assert strictly observable contracts across system boundaries: rendered Flutter widget trees, GoRouter navigation states, PostgreSQL 17 stored procedure signatures and error codes, Supabase Edge Function HTTP payloads, and browser viewport DOM semantics.
   - Zero coupling to private member variables, internal controller helper implementations, or transient state shapes. Refactoring internal logic will not invalidate tests as long as external contracts are preserved.
2. **Deterministic & Isolated Execution**:
   - Every test case constructs its required fixture state and performs clean teardown without cross-test leakage.
   - Database operations execute against an isolated in-memory PostgreSQL 17 engine (PGlite v0.4.6) with pgcrypto, eliminating network dependencies, remote Supabase rate limits, or persistent disk contamination.
   - Client widget tests execute with isolated Riverpod `ProviderContainer` scopes and mocked platform channels (`shared_preferences`, audio, haptic).
3. **Adversarial & Boundary Rigor**:
   - Rigorous evaluation of corner conditions: rapid set logging (>4 sets/min pace clamping), 0kg bodyweight representations, static hold time-based sets (`duration_seconds > 0`, `reps = 0`), midnight timezone rollover for activity streaks, offline interruption recovery, 320px ultra-compact mobile layout constraints, and 20 req/day AI Coach quota exhaustion.
4. **Zero-Flake & Zero-Warning Standard**:
   - The test pipeline must execute deterministically with 0 skipped tests, 0 unhandled asynchronous timer leaks, 0 `RenderFlex` overflow exceptions, and 0 warnings under `flutter analyze`.

---

## 2. Test Architecture & Runners

The GymLevel test infrastructure comprises four dedicated, isolated test runners covering the entire application lifecycle:

```
+----------------------------------------------------------------------------------------------------+
|                                GymLevel Dual-Track Test Harness                                    |
+------------------------------+------------------------------+--------------------------------------+
| Runner 1: Flutter Client     | Runner 2: Isolated DB Engine | Runner 3: Deno Edge Runtime          |
| Command: flutter test        | Command: npm.cmd test        | Command: npm.cmd run test:edge       |
| Environment: Dart / Flutter  | Environment: PGlite (PG 17)  | Environment: Deno v2.9.6             |
| Scope: Unit, Widget, UI Regr | Scope: Migrations, RLS, RPCs | Scope: AI Coach Proxy, Auth, Sanit.  |
| Targets: app/test/           | Targets: supabase/tests/     | Targets: supabase/functions/tests/   |
+------------------------------+------------------------------+--------------------------------------+
                                                |
                                                v
+----------------------------------------------------------------------------------------------------+
| Runner 4: Production Web Headless Browser Smoke Runner                                             |
| Command: npm.cmd run test:web                                                                      |
| Environment: Playwright (Chromium) against loopback HTTP server running app/build/web              |
| Scope: 16 Viewport & Locale Matrix combinations (320px–1440px x VI/EN x Auth Routes)               |
+----------------------------------------------------------------------------------------------------+
```

---

## 3. Feature Inventory & 4-Tier Verification Matrix

All 14 features from `PROJECT.md § Feature Inventory` are systematically mapped across Tiers 1 through 4:

### Tier Structure:
- **Tier 1: Feature Coverage (Happy Path)** — Standard operations and core user flows (>=5 test cases per feature = 70 test cases).
- **Tier 2: Boundary & Corner Cases** — Extreme limits, invalid inputs, network recovery, timing anomalies, and layout stress (>=5 test cases per feature = 70 test cases).
- **Tier 3: Cross-Feature Interactions** — Pairwise subsystem interactions, state synchronization, and transactional cascades (10 comprehensive interaction suites).
- **Tier 4: Real-World Application Scenarios** — Multi-step authentic athlete journeys (5 end-to-end scenarios).

**Total Test Units Specified**: 70 (Tier 1) + 70 (Tier 2) + 10 (Tier 3) + 5 (Tier 4) = **155 Test Units** (Exceeds minimum coverage threshold of 150 units).

---

### Feature 1: Candy Neubrutalism Tokens & Palette
*Description: Canvas `#fdf9f0`, Card `#ffffff`, Ink `#111111`, Hot Pink `#ff3d81`, Canary Yellow `#ffd23f`, Mint `#3ddc97`, Lilac `#c8a2ff`, Coral `#ff6b5e`, and 2px borders.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_candy_palette_canvas_color`: Assert `CandyColors.canvas` equals `Color(0xFFFDF9F0)`.
2. `test_candy_palette_card_color`: Assert `CandyColors.card` equals `Color(0xFFFFFFFF)`.
3. `test_candy_palette_ink_and_borders`: Assert `CandyColors.ink` equals `Color(0xFF111111)` and default border width is 2.0px.
4. `test_candy_palette_accent_colors`: Assert Hot Pink (`0xFFFF3D81`), Canary Yellow (`0xFFFFD23F`), Mint Green (`0xFF3DDC97`), and Soft Lilac (`0xFFC8A2FF`) resolve correctly.
5. `test_candy_theme_light_mode_binding`: Assert `CandyTheme.light` applies canvas background, scaffold background, and ink borders globally.

#### Tier 2: Boundary & Corner Cases
1. `test_candy_contrast_ratio_ink_on_canvas`: Assert contrast ratio between `#111111` and `#FDF9F0` exceeds 14:1 (WCAG AAA compliant).
2. `test_candy_contrast_ratio_ink_on_accents`: Assert readability of dark ink text `#111111` on Canary Yellow and Mint Green accents.
3. `test_candy_danger_palette_contrast`: Assert Coral `#FF6B5E` provides distinct visual error state against canvas and card backgrounds.
4. `test_candy_grid_background_opacity`: Assert 24px grid overlay uses ink color with strict 5% opacity (`Color(0x0D111111)`).
5. `test_candy_theme_fallback_behavior`: Assert legacy theme references redirect gracefully to Candy Neubrutalism without runtime crashes.

---

### Feature 2: Vietnamese Typography System
*Description: Eradicate Orbitron; bundle Archivo (Black 900), Space Grotesk (UI/body), and Space Mono (numbers, stats, timestamps, XP) with full Vietnamese diacritics.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_font_family_heading_binding`: Assert display and heading styles use `Archivo` font family with weight `FontWeight.w900`.
2. `test_font_family_body_binding`: Assert body text and UI labels bind to `SpaceGrotesk` font family.
3. `test_font_family_numeric_binding`: Assert timers, set weights, reps, and XP counters use `SpaceMono` font family.
4. `test_vietnamese_diacritic_rendering`: Assert complex Vietnamese tone marks and vowel combinations (e.g., `Đẩy Ngực Trên Với Tạ Đơn`, `Khởi động`, `Bài tập cơ đùi`) render without tofu (`\uFFFD`) characters.
5. `test_font_asset_manifest_declaration`: Assert `pubspec.yaml` contains clean asset declarations for Archivo, SpaceGrotesk, and SpaceMono.

#### Tier 2: Boundary & Corner Cases
1. `test_orbitron_complete_eradication`: Assert regex audit across `lib/` and `test/` confirms zero remaining occurrences of `Orbitron`.
2. `test_vietnamese_long_string_wrapping`: Assert long Vietnamese exercise names wrap without overflowing bounded cards at 320px width.
3. `test_large_text_accessibility_scaling`: Assert Space Grotesk and Space Mono render cleanly with text scale factor 1.5x.
4. `test_monospace_digit_alignment`: Assert Space Mono numerical strings maintain fixed horizontal pitch during timer countdowns.
5. `test_mixed_language_locale_switching`: Assert dynamic switching between English and Vietnamese preserves font metrics and line heights.

---

### Feature 3: Candy Component Primitives (16 Widgets)
*Description: Centralized tactile Neubrutalist widgets (`CandyScaffold`, `CandyCard`, `CandyButton`, `CandyTextField`, `CandyBadge`, `CandyDialog`, `CandyBottomSheet`, `CandySkeleton`, `CandyEmptyState`, `CandyErrorState`, `CandyStatTile`, `CandyProgressBar`, `CandyNavigationItem`, `CandyExerciseCard`, `CandyWorkoutSetRow`, `CandyQuestCard`).*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_candy_button_press_animation`: Assert `CandyButton` translates downward-right by `(2.0, 2.0)` pixels and reduces shadow from 4px to 2px on pointer down.
2. `test_candy_card_ink_border_and_shadow`: Assert `CandyCard` paints 2px solid `#111111` border, 18px border radius, and unblurred 6px drop shadow.
3. `test_candy_scaffold_grid_rendering`: Assert `CandyScaffold` paints 24px background grid pattern behind body content.
4. `test_candy_text_field_neubrutalist_style`: Assert `CandyTextField` displays 2px border, hard shadow, and high-visibility focus ring.
5. `test_candy_progress_bar_fill`: Assert `CandyProgressBar` accurately calculates width percentage with hard outer boundary and Mint fill.

#### Tier 2: Boundary & Corner Cases
1. `test_candy_button_rapid_tap_resilience`: Tap `CandyButton` 20 times in 500ms; assert no unhandled animation controller exceptions or stuck pressed states.
2. `test_candy_card_zero_shadow_override`: Assert `CandyCard` supports custom `shadowOffset: Offset.zero` without layout deformation.
3. `test_candy_dialog_screen_bounds_at_320px`: Assert `CandyDialog` constraints prevent modal overflow on 320x568 viewport.
4. `test_candy_badge_long_label_clamping`: Assert `CandyBadge` with 50-character tag truncates gracefully with ellipsis without breaking parent row.
5. `test_candy_skeleton_shimmer_cpu_efficiency`: Assert `CandySkeleton` uses minimal tick frequency without triggering continuous full-screen repaints.

---

### Feature 4: Rebuilt Neubrutalist Dashboard
*Description: Personalized greeting, RPG class badge, hero XP progression, 4 KPI tiles, 7-day activity grid, daily quests, streak, volume chart, recent workouts, and CTA.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_dashboard_hero_card_xp_rendering`: Assert Hero Card renders current user level, total XP, and percentage toward next level.
2. `test_dashboard_four_kpi_tiles`: Assert Volume, Workouts, Sets, and Daily Streak tiles display formatted values with respective accent colors.
3. `test_dashboard_weekly_activity_grid`: Assert 7-day grid highlights days matching completed workout timestamps.
4. `test_dashboard_recent_workout_feed`: Assert recent workouts list displays latest session titles, dates, and total volume.
5. `test_dashboard_primary_train_cta`: Assert tapping "Bắt đầu tập luyện" / "Start Workout" navigates to workout initialization flow.

#### Tier 2: Boundary & Corner Cases
1. `test_dashboard_zero_workouts_empty_state`: Assert new user with 0 completed workouts sees `CandyEmptyState` with motivational prompt.
2. `test_dashboard_320px_viewport_scrollability`: Assert full dashboard renders inside `SingleChildScrollView` with 0 `RenderFlex` overflows at 320px width.
3. `test_dashboard_large_number_formatting`: Assert volume >= 1,000,000 kg formats cleanly (e.g. `1,250K kg` or `1.25M kg`) without clipping.
4. `test_dashboard_streak_broken_display`: Assert 0-day streak displays neutral status without negative numbers or crash.
5. `test_dashboard_high_level_badge_rendering`: Assert Level 99+ badge renders without text clipping inside class icon pill.

---

### Feature 5: Exercise Catalog Schema & 120-200 Seed Data
*Description: Additive migration for exercise metadata (`slug`, `name_vi`, `name_en`, `secondary_muscles`, `movement_pattern`, `difficulty`, `form_cues`, `common_mistakes`, `alternative_exercise_slugs`) + `seed_exercises.sql`.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_catalog_total_count_within_bounds`: Query `public.exercises`; assert count is between 120 and 200 exercises.
2. `test_catalog_bilingual_names_populated`: Assert every exercise in `public.exercises` contains non-empty `name_vi` and `name_en`.
3. `test_catalog_muscle_group_coverage`: Assert exercises exist covering all 8 major muscle groups (Chest, Back, Legs, Shoulders, Arms, Core, Full Body, Cardio).
4. `test_catalog_equipment_coverage`: Assert exercises exist for Barbell, Dumbbell, Cable, Machine, and Bodyweight equipment.
5. `test_catalog_movement_pattern_coverage`: Assert push, pull, squat, hinge, carry, and lunge patterns are fully represented.

#### Tier 2: Boundary & Corner Cases
1. `test_catalog_unique_slug_constraint`: Attempt inserting duplicate `slug`; assert unique constraint violation (`23505`).
2. `test_catalog_seed_idempotent_replay`: Execute `seed_exercises.sql` twice consecutively; assert row count remains unchanged and zero errors.
3. `test_catalog_empty_cues_array_default`: Insert exercise without cues; assert `form_cues` defaults to empty array `{}` (not NULL).
4. `test_catalog_difficulty_check_constraint`: Attempt inserting exercise with invalid difficulty `extreme`; assert check constraint failure.
5. `test_catalog_unicode_diacritic_search`: Query exercises using unaccented Vietnamese search term (e.g. `day nguc`); assert match on `Đẩy ngực`.

---

### Feature 6: Exercise Types Support (Weighted/Bodyweight/Time)
*Description: Full support for bodyweight (0kg hidden, reps only), weighted (kg + reps), and duration-based (seconds/timer) exercises in DB, models, and UI.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_weighted_set_logging`: Log set with `weight_kg = 80.0` and `reps = 8`; assert both values serialize and persist.
2. `test_bodyweight_set_logging`: Log set for bodyweight exercise with `weight_kg = 0.0` and `reps = 15`; assert `weight_kg` is omitted from display.
3. `test_time_based_static_hold_logging`: Log set with `duration_seconds = 45` and `reps = 0`; assert valid persistence.
4. `test_workout_sets_check_constraint_duration`: Assert `(NOT is_completed OR reps > 0 OR duration_seconds > 0)` permits completed duration sets.
5. `test_exercise_type_selector_ui`: Assert UI renders seconds input for plank/wall-sit and kg/reps for barbell bench press.

#### Tier 2: Boundary & Corner Cases
1. `test_invalid_zero_rep_zero_duration_completed_set`: Attempt inserting completed set with `reps = 0` and `duration_seconds = 0`; assert check constraint error (`23514`).
2. `test_negative_duration_rejection`: Attempt inserting `duration_seconds = -10`; assert constraint rejection.
3. `test_extreme_duration_clamping`: Assert duration set exceeding 3600 seconds (1 hour) is clamped or rejected cleanly.
4. `test_bodyweight_with_added_weight`: Log bodyweight pull-up with `weight_kg = 15.0` (weighted pull-up); assert UI indicates `+15 kg`.
5. `test_uncompleted_set_zero_values_allowed`: Assert uncompleted set (`is_completed = false`) permits `reps = 0` and `duration_seconds = 0` while in progress.

---

### Feature 7: Interactive Workout Tracking & Exercise Reordering
*Description: Reorderable exercise list, add/remove exercises, inline set editing, debounced mutations, and completed toggles.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_workout_add_exercise`: Add exercise from catalog; assert new exercise appears in active workout exercise list.
2. `test_workout_remove_exercise`: Remove exercise; assert associated sets and exercise tile are cleanly removed.
3. `test_workout_reorder_exercises`: Reorder exercises via `ReorderableListView`; assert new sequence indices persist.
4. `test_workout_inline_set_toggle_completion`: Tap checkbox on set row; assert `is_completed` toggles to `true` with visual highlight.
5. `test_workout_debounced_set_input`: Rapidly change weight from 50 to 55 to 60 kg; assert database receives single debounced update.

#### Tier 2: Boundary & Corner Cases
1. `test_reorder_single_exercise_no_op`: Reorder workout containing only 1 exercise; assert state remains stable.
2. `test_delete_exercise_with_completed_sets`: Delete exercise with 3 completed sets; assert confirmation modal appears before deletion.
3. `test_rapid_set_toggle_idempotency`: Tap set completion checkbox 5 times rapidly; assert final state matches odd/even tap count without race conditions.
4. `test_reorder_while_rest_timer_running`: Drag and reorder exercises while rest timer is ticking; assert rest timer countdown is uninterrupted.
5. `test_empty_workout_finish_guard`: Attempt finishing workout with 0 exercises; assert actionable error prompt prevents submission.

---

### Feature 8: Resilient Rest Timer & Background Recovery
*Description: Accurate 1s rest timer, pause/resume, audio chime & haptic alert, auto-start on set completion, and background timestamp preservation.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_rest_timer_auto_start_on_set_complete`: Complete set; assert rest timer immediately begins countdown with configured duration (e.g. 90s).
2. `test_rest_timer_pause_resume`: Tap pause button; assert countdown halts. Tap resume; assert countdown resumes from exact remaining second.
3. `test_rest_timer_completion_alert`: Advance timer to 0; assert audio chime and haptic feedback triggers are invoked.
4. `test_rest_timer_duration_quick_presets`: Tap +30s button; assert remaining duration increments by exactly 30 seconds.
5. `test_rest_timer_skip`: Tap skip button; assert timer dismisses cleanly and resets state.

#### Tier 2: Boundary & Corner Cases
1. `test_rest_timer_background_timestamp_recovery`: Simulate app backgrounding for 45s while 90s timer is running; assert foreground resume reflects 45s remaining.
2. `test_rest_timer_background_expiration`: Simulate app backgrounding for 120s while 90s timer is running; assert foreground resume handles expiration and triggers pending alert.
3. `test_rest_timer_zero_duration_configuration`: Configure rest timer to 0s; assert completing set does not trigger visual timer dialog.
4. `test_rest_timer_consecutive_set_completions`: Complete set 1, allow timer to run 10s, complete set 2; assert timer restarts from full duration without stacking intervals.
5. `test_rest_timer_device_reboot_cleanup`: Assert stale rest timer timestamps from prior days are cleanly discarded on startup.

---

### Feature 9: Local Interruption Recovery
*Description: Persist active workout state in local storage (`shared_preferences`) alongside Supabase for offline restart & refresh resilience.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_local_storage_active_workout_backup`: On set mutation, assert snapshot is serialized to `gymlvl_active_workout_backup` key in local storage.
2. `test_app_restart_active_workout_prompt`: Launch app with active backup present; assert UI presents "Tiếp tục bài tập" / "Resume Workout" dialog.
3. `test_active_workout_restore_state`: Accept resume prompt; assert all exercises, sets, weights, reps, and elapsed duration restore accurately.
4. `test_active_workout_discard_clears_backup`: Dismiss resume prompt; assert `gymlvl_active_workout_backup` key is cleared.
5. `test_successful_workout_completion_clears_backup`: Complete workout normally; assert local backup is purged immediately upon server confirmation.

#### Tier 2: Boundary & Corner Cases
1. `test_corrupted_local_backup_graceful_recovery`: Store malformed JSON in backup key; assert app starts cleanly without crashing and logs warning.
2. `test_stale_backup_expiration`: Store backup with timestamp > 24 hours old; assert app treats backup as expired and prompts to discard.
3. `test_concurrent_supabase_and_local_state_conflict`: If local timestamp is newer than Supabase workout `updated_at`, assert local changes take precedence.
4. `test_storage_quota_exceeded_fallback`: Simulate local storage write failure; assert workout tracking continues in memory with retry flag.
5. `test_multi_account_local_backup_isolation`: Assert local backup stored by User A is not presented or accessible when User B logs in.

---

### Feature 10: Post-Workout Summary & Level-Up Modal
*Description: Comprehensive post-workout summary rendering volume, duration, XP, level progression, class progression, and achievements.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_summary_screen_volume_calculation`: Assert post-workout summary renders exact sum of `reps * weight_kg` across all completed sets.
2. `test_summary_screen_duration_display`: Assert formatted workout duration (e.g. `48:15`) matches elapsed time.
3. `test_summary_screen_xp_awarded_card`: Assert total earned XP is displayed with Hot Pink Neubrutalist badge.
4. `test_summary_level_up_modal_trigger`: When earned XP crosses level threshold, assert `LevelUpOverlay` displays with celebratory visual feedback.
5. `test_summary_dismiss_navigates_to_dashboard`: Tap "Hoàn thành" / "Done" on summary; assert navigation returns to `/dashboard` with updated stats.

#### Tier 2: Boundary & Corner Cases
1. `test_summary_zero_volume_bodyweight_workout`: Complete workout consisting purely of bodyweight exercises; assert volume renders `0 kg (Bodyweight)` without error.
2. `test_summary_multi_level_jump`: Award sufficient XP to advance 2 levels (e.g. Level 1 to 3); assert modal displays final level 3 accurately.
3. `test_summary_320px_viewport_overflow`: Assert post-workout summary with 10 exercises scrolls smoothly at 320px width without layout overflows.
4. `test_summary_pr_badge_highlight`: When personal record is set, assert gold/mint PR pill displays beside the exercise name.
5. `test_summary_back_button_prevention`: Assert system back button does not re-enter completed active workout session.

---

### Feature 11: Authoritative Progression & Quests Verification
*Description: PostgreSQL RPC atomicity, replay protection, quest category mapping, timezone streaks, and Deno edge proxies.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_complete_workout_rpc_atomicity`: Invoke `complete_workout` RPC; assert user XP, level, workout status, and PRs commit in single transaction.
2. `test_replay_protection_idempotency`: Invoke `complete_workout` twice with same `workout_id`; assert second call returns existing reward with 0 duplicate XP.
3. `test_daily_quest_exercise_category_matching`: Complete Chest workout; assert daily quest requiring "Chest / Push" sets increments progress count.
4. `test_daily_streak_consecutive_increment`: Log workout on Day N and Day N+1; assert streak counter increments from 1 to 2.
5. `test_edge_ai_coach_proxy_contract`: Send valid request to `ai-coach` Edge Function; assert HTTP 200 with structured response text.

#### Tier 2: Boundary & Corner Cases
1. `test_anti_cheat_pace_limit_clamping`: Submit workout with 6 sets logged within 30 seconds (>4 sets/min); assert server clamps XP to 10 XP.
2. `test_missed_day_streak_reset`: Log workout on Day 1, skip Day 2, log on Day 3; assert streak resets to 1 in user's timezone.
3. `test_same_day_multiple_workouts_streak_stable`: Log 2 workouts on same calendar day; assert streak increments only once.
4. `test_midnight_boundary_quest_expiration`: Query quest instances past local calendar midnight; assert quest is marked expired.
5. `test_edge_ai_coach_unconfigured_fallback`: Invoke `ai-coach` with unconfigured LLM provider; assert HTTP 503 `{ "error": "coach_unconfigured" }`.

---

### Feature 12: Performance & State Optimization
*Description: Elimination of N+1 queries during preset loading, fine-grained Riverpod selectors, and 320px-1440px layout overflow guards.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_preset_loading_single_batch_query`: Load workout preset with 5 exercises; assert exercises and default sets load in single batch query.
2. `test_fine_grained_riverpod_selector`: Mutate set 2 weight; assert only set 2 row rebuilds; verify exercise header does not rebuild.
3. `test_viewport_adaptation_mobile_390px`: Assert bottom navigation bar renders cleanly on standard mobile viewport.
4. `test_viewport_adaptation_tablet_768px`: Assert dashboard renders dual-column KPI layout on tablet viewport.
5. `test_viewport_adaptation_desktop_1440px`: Assert desktop layout renders navigation rail and wide volume chart.

#### Tier 2: Boundary & Corner Cases
1. `test_ultra_narrow_viewport_320px`: Assert zero `RenderFlex overflowed` exceptions across all screens on 320px width.
2. `test_timer_tick_rebuild_isolation`: Assert 1s rest timer tick rebuilds only timer display widget and does not trigger parent screen rebuild.
3. `test_large_catalog_memory_footprint`: Search catalog with 200 exercises; assert list view virtualizes items with minimal memory allocation.
4. `test_rapid_tab_switching_state_preservation`: Switch between Dashboard, Workout, Quests, and Profile tabs rapidly; assert scroll positions persist.
5. `test_render_box_unbounded_height_prevention`: Assert all list views nested in bottom sheets or dialogs use `shrinkWrap` or bounded constraints.

---

### Feature 13: Dual-Track E2E Test Suite & Test Readiness
*Description: Publish `TEST_INFRA.md`, design Tiers 1-4 opaque-box tests, verify all layers, and publish `TEST_READY.md`.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_infra_specification_published`: Assert `TEST_INFRA.md` exists at project root and specifies all 14 features across 4 tiers.
2. `test_catalog_e2e_suite_execution`: Execute `node tools/db-tests/e2e-catalog-test.mjs`; assert 100% pass across catalog checks.
3. `test_candy_ui_widget_suite_execution`: Execute `flutter test app/test/candy_ui_test.dart`; assert all widget tests pass cleanly.
4. `test_edge_functions_test_execution`: Execute `npm.cmd run test:edge` in `tools/db-tests/`; assert all 14 Deno tests pass.
5. `test_ready_declaration_artifact`: Assert `TEST_READY.md` provides complete execution commands and passing status matrix.

#### Tier 2: Boundary & Corner Cases
1. `test_isolated_pglite_zero_network`: Run `tools/db-tests/run.mjs` with disabled network interfaces; assert full suite passes offline.
2. `test_headless_smoke_matrix_16_combinations`: Assert Playwright smoke test passes across 4 viewports x 2 languages x 2 routes.
3. `test_empty_test_results_detection`: Assert test runners fail with non-zero exit code if 0 tests are discovered.
4. `test_timeout_handling_long_running_tests`: Assert runner terminates tests exceeding 60s timeout with clear diagnostics.
5. `test_flaky_test_detection_repeat_runs`: Execute test suite 3 times consecutively; assert 100% pass stability on every run.

---

### Feature 14: Polish, Hardening & Forensic Victory Audit
*Description: Zero analyzer warnings, clean formatting, release web compilation, and clean forensic audit verdict.*

#### Tier 1: Feature Coverage (Happy Path)
1. `test_flutter_analyze_clean`: Run `flutter analyze` in `app/`; assert 0 errors, 0 warnings, and 0 infos.
2. `test_dart_format_clean`: Run `dart format --output=none --set-exit-if-changed lib test`; assert 0 files changed.
3. `test_web_production_build_compilation`: Run `flutter build web --release`; assert successful compilation.
4. `test_forensic_integrity_no_dummy_code`: Audit codebase for hardcoded fake returns or bypassed logic; assert zero integrity violations.
5. `test_git_status_clean_tree`: Assert no unstaged temporary debug files or scratch artifacts in repository.

#### Tier 2: Boundary & Corner Cases
1. `test_unused_import_elimination`: Assert analyzer flags no unused imports or deprecated API usages.
2. `test_release_bundle_asset_presence`: Assert compiled web release bundle includes bundled fonts (`Archivo`, `SpaceGrotesk`, `SpaceMono`).
3. `test_missing_env_config_graceful_handling`: Run compiled web release without `--dart-define`; assert actionable setup screen renders.
4. `test_cross_origin_isolation_headers`: Assert web server headers support WASM and Canvaskit execution.
5. `test_zero_todo_placeholders_in_completed_features`: Audit codebase for `TODO` or `FIXME` comments in declared complete features; assert 0 found.

---

## 4. Tier 3: Cross-Feature Interaction Matrix (10 Comprehensive Suites)

Cross-feature testing evaluates transactional integrity and state propagation across multiple interacting subsystems:

1. **Suite 3.1: Quest Completion + Class Switching**:
   - Athlete with Warrior class completes a Push workout, satisfying daily quest "Push Mastery" (+350 XP).
   - Athlete immediately switches active class to Rogue via `switch_class` RPC.
   - Assert: Quest XP is permanently bound to user ledger; new class level accurately recalculates; streak remains intact.
2. **Suite 3.2: Active Workout Interruption Recovery + Activity Streak Update**:
   - Athlete starts workout on Monday at 23:45, logs 2 sets, app restarts at 00:05 Tuesday.
   - Local recovery restores workout with original start timestamp.
   - Athlete finishes workout at 00:15 Tuesday.
   - Assert: Server credits workout to Monday's session; Tuesday's streak is updated or maintained without skipping days.
3. **Suite 3.3: Static Hold Exercise Completion + Total Volume Calculation**:
   - Workout includes 3 sets of Bench Press (100kg x 5 = 500kg volume) and 3 sets of Plank (60s duration, 0kg).
   - Assert: Total workout volume displays exactly `1,500 kg`; duration sets increment duration counter without corrupting volume sum.
4. **Suite 3.4: Rapid Double-Submission Replay + XP Ledger Idempotency**:
   - Client sends duplicate `complete_workout` calls simultaneously over flaky network.
   - Assert: Database locks workout row (`FOR UPDATE`); first call inserts `workout_rewards` row; second call returns original reward with 0 duplicate XP and 0 duplicate `xp_logs` rows.
5. **Suite 3.5: Language Toggle (VI/EN) + Exercise Catalog Dynamic Search**:
   - User switches language from English to Vietnamese while browsing catalog.
   - Assert: Exercise list items instantly re-render with `name_vi`; search queries for Vietnamese diacritics filter accurately.
6. **Suite 3.6: Biometrics Onboarding Draft + Session Invalidation on Logout**:
   - Unauthenticated user fills steps 1–5 of onboarding. User logs out or clears session.
   - Assert: Session gate clears draft biometrics; new login starts with isolated clean state.
7. **Suite 3.7: Offline Timer Backgrounding + Local Storage Resume**:
   - 90s rest timer begins; device enters sleep state for 60s; app recovers.
   - Assert: Timer recovers with 30s remaining; local storage snapshot syncs without race conditions.
8. **Suite 3.8: Level-Up Celebration Trigger + Dashboard Stats Cache Refresh**:
   - Athlete finishes workout earning 500 XP, crossing Level 2 to Level 3.
   - Assert: `LevelUpOverlay` triggers; upon dismissal, Dashboard stats provider invalidates and refreshes with Level 3 and updated KPI totals.
9. **Suite 3.9: Rest Timer Expiration + Auto-Advancing Next Set Focus**:
   - Completing Set 1 starts rest timer; timer reaches 0.
   - Assert: Audio chime plays; focus ring shifts to Set 2 weight/reps input field.
10. **Suite 3.10: AI Coach Rate Limit Exceeded + Workout Logging Persistence Unblocked**:
    - Athlete exhausts 20/20 daily coach requests, receiving HTTP 429.
    - Athlete continues active workout and logs sets.
    - Assert: Workout logging and completion continue unhindered; coach error does not block core workout lifecycle.

---

## 5. Tier 4: Real-World Application Scenarios (5 Multi-Step Journeys)

### Scenario 1: Complete Neubrutal Athlete Journey: Onboarding to First Workout
- **Workflow**:
  1. Athlete signs up with email/password; router directs to `/onboarding`.
  2. Athlete completes 9 steps: selects Warrior primary class, 3 days/week gym frequency, captures biometrics.
  3. `initialize_user` commits; user arrives at Candy Neubrutalist Dashboard.
  4. Athlete taps Hot Pink "Start Workout" CTA; adds Barbell Bench Press (3 sets x 60kg x 10 reps).
  5. Athlete completes sets with tactile checkmarks, observes rest timer countdown.
  6. Athlete taps "Finish Workout"; post-workout summary displays 1,800 kg volume and 120 XP.
  7. Athlete unlocks Level 2 with celebration overlay and returns to Dashboard showing 1-day streak.

### Scenario 2: Flaky Network & Offline Restart Workout Recovery with Time-Based Exercises
- **Workflow**:
  1. Athlete begins core training session with weighted Planks and Pull-ups.
  2. Athlete logs Set 1 (Plank, 60 seconds duration, reps = 0).
  3. Network disconnects; app process is terminated abruptly.
  4. Athlete relaunches app while offline.
  5. App detects `gymlvl_active_workout_backup` in local storage; displays Neubrutalist recovery banner.
  6. Athlete taps "Resume"; workout state, elapsed time, and duration sets restore accurately.
  7. Athlete logs Set 2, reconnects to network, and completes workout atomically.

### Scenario 3: Timezone-Aware Daily Quest Generation, Category Matching & Streak Rollover
- **Workflow**:
  1. Athlete in Hanoi (`Asia/Ho_Chi_Minh`) opens app at 08:00; `sync_daily_data` generates daily quest: "Leg Destroyer (Squat pattern, 3 sets)".
  2. Quest card renders with Mint accent and "Start Quest" button.
  3. Athlete taps "Start Quest"; workout pre-populates with Barbell Back Squat.
  4. Athlete logs 3 sets of 100kg x 8 reps; finishes workout.
  5. `complete_workout` validates squat category match, completes quest, and awards 350 bonus XP.
  6. Calendar rolls past midnight; next day sync increments streak to 2 consecutive days.

### Scenario 4: Multi-Class Progression & Dynamic Dual-Class Synergies
- **Workflow**:
  1. Level 10 athlete opens RPG Class Profile.
  2. Athlete views current primary (Warrior Lvl 8) and secondary (Ranger Lvl 4).
  3. Athlete switches secondary to Mage (`switch_class('Mage', 'secondary')`).
  4. Stored procedure verifies slot compatibility, aggregates historical XP from `xp_logs`, and calculates Mage Lvl 5.
  5. Athlete logs hybrid calisthenics workout; XP distribution algorithm awards split XP to Warrior and Mage.
  6. Class level progress bars reflect updated distribution cleanly.

### Scenario 5: Adversarial Anti-Cheat, Rate Limiting & Unconfigured AI Coach Fallback
- **Workflow**:
  1. Malicious client script attempts rapid set submission (8 sets in 15 seconds).
  2. Server anti-cheat pace detector clamps reward to baseline 10 XP.
  3. Client script replays identical `complete_workout` payload 3 times.
  4. Replay protection intercepts duplicate submissions, returning cached reward without XP duplication.
  5. Athlete navigates to AI Coach tab while server endpoint is unconfigured; client displays polite offline notice without throwing unhandled exceptions.

---

## 6. Coverage Thresholds & Pass/Fail Criteria

| Criterion | Target Threshold | Actual Status |
|-----------|------------------|---------------|
| Total Specified Test Units | >= 150 test units | **155 units** (PASS) |
| Tier 1 Feature Happy Path Coverage | 5 per feature (70 units) | Specified across all 14 features |
| Tier 2 Boundary & Corner Coverage | 5 per feature (70 units) | Specified across all 14 features |
| Tier 3 Cross-Feature Interaction Suites | >= 10 pairwise suites | 10 suites specified |
| Tier 4 Real-World E2E Scenarios | >= 5 multi-step journeys | 5 journeys specified |
| Flutter Analyzer Warnings | 0 warnings | Strict gate |
| Dart Formatting Drift | 0 files changed | Strict gate |
| PostgreSQL 17 Test Runner | 100% pass | PGlite isolated runner |
| Edge Function Deno Tests | 100% pass | 14/14 tests passing |
| Playwright Headless Web Smoke | 16/16 combinations pass | 320px–1440px x VI/EN x routes |

---
*Authored and certified by Agent E (QA & Test Infrastructure Specialist) for GymLevel.*

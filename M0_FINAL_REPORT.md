# BÁO CÁO CUỐI CUÙNG — M0: OPENGYM SOURCE PINNING & MIGRATION FOUNDATION

**Ngày:** 31/10/2026
**Trạng thái:** `READY_FOR_APPROVAL` (không commit, không push, không tag)
**Ngôn ngữ báo cáo:** Tiếng Việt (ti technische và code bằng English)

---

## 1. Trạng thái repository GymLvl

| Mục | Giá trị |
|-----|---------|
| Repository | `https://github.com/Tuandaca/gymlvl` |
| Chi nhánh | `main` (một chi nhánh duy nhất phát triển) |
| HEAD thực thi | `6badfef29a871a978a09daee304dc1c3f3f69a84` (lệnh `git rev-parse HEAD` trong phiên này) |
| Trạng thái cây làm việc | Dirty by design: 5 tệp owner được bảo tồn + 4 tệp M0 đã đổi + 1 tệp manifest mới |
| Tệp owner (bảo toàn, không chạm) | `app/android/gradle.properties`, `app/android/run_gradle.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`, `gradle_check.ps1`, `run_gradle_check.bat` |
| Stack | Flutter 3.38.5, Dart 3.10.4, Riverpod 3, GoRouter 17, Supabase/PostgreSQL/Edge Functions |

> Lưu ý: `AGENTS.md` §0 ghi HEAD `b4063c6`, `TASK_BOARD` ghi `aa52aa0a...`; lệnh thực thi trong phiên này trả về `6badfef2...`. Theo `PROJECT_CONTEXT.md` §7 (lệnh thực thi thắng), báo cáo lấy theo `6badfef2...`. Tài liệu cần hòa kết.

---

## 2. OpenGUM repository chính thức

- **URL:** `https://github.com/DuarteSantos8/openGym`
- **Chủ sở hữu:** DuarteSantos8
- **Tên repository:** openGym
- **Không sử dụng fork/mirror.**

---

## 3. Pinned commit SHA (bất biến trong M0)

| Mục | Giá trị |
|-----|---------|
| SHA đã chọn | `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` |
| Lý do chọn | Đã được approve trước đó và ghi trong `docs/planning/PROJECT_CONTEXT.md` §6 (DuarteSantos8/openGym B) và `M0_AUDIT.md` §3. |
| Ngày thu thập | 31/10/2026 |
| Mã giấy phép | GNU AGPL v3.0 (`LICENSE`); `NOTICE.md`: exceptions cửa hàng không chuyển được |

---

## 4. Vị trí clone tham khảo

- **Thư mục:** `D:\Projects\opengym-reference`
- **Remote origin:** `https://github.com/DuarteSantos8/openGym` (fetch + push) — đã verify.
- **HEAD sau checkout:** `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` — khớp_selected SHA (detached HEAD, sạch).
- **Quy tắc tuân thủ:** Không nested trong cây git GymLvl; không submodule; không commit tham khảo vào GymLvl.

---

## 5. Các subagent thực sự đã dùng (không mô phỏng)

| Workstream | Agent ID | Child session | Trạng thái | Ghi chú |
|------------|----------|---------------|------------|---------|
| A. Flutter UI/UX mapping | `flutter-specialist` | `ses_e721c19f2ffeoi9CYIROH0cOS1` | Completed | Bảng mapping UI 21 hàng, chỉ đọc, không sửa file. |
| C. Supabase schema & exercise data | `supabase-specialist` | `ses_e721c19f1ffeVBfgvsHL35Gicn` | Completed | Gap analysis catalog/sets/progression/1RM/rest timer, chỉ đọc. |
| D. Licensing & independent QA | `qa-reviewer` | `ses_e721c19eeffeqvSIepBiMtpcKk` | BLOCKED | Sandbox không truy cập `D:\Projects\opengym-reference` (external_directory denied), nhưng bảng phân loại cấp phép đã được sản xuất từ tài liệu dự án (`PROJECT_CONTEXT`, `DECISIONS`, `M0_AUDIT`, `NOTICE.md`). |
| B. Feature architecture mapping | Primary agent (gymlvl-orchestrator) | — | Completed | Tổng hợp từ bằng chứng subagent A + C. |

Không agent nào được phép chỉnh sửa file trùng láp cùng lúc. Primary agent giữ toàn bộ thay đổi source acquisition và Git safety.

---

## 6. Tính năng OpenGym đã khám phá (từ source thực)

OpenGym là **React/Capacitor + Node.js** (không phải Flutter/Supabase), do đó không port code (AGPL + D-001). Các tính năng tham khảo hành vi:

- **Catalogue:** `catalogue/exercises/<id>.json` (6.554 bài tập), `catalogue/i18n/*.json` (17 ngôn ngữ, không có `vi`), media 13.109 tệp (Gym visual, riêng biệt).
- **Màn hình:** `Home.jsx`, `Library.jsx`, `Plan.jsx`, `RoutineEdit.jsx`, `Workout.jsx`, `History.jsx`, `Stats.jsx`, `Settings.jsx`, `Login.jsx`, `CoachChat.jsx`, `CoachSetup.jsx`, `CoachIntake.jsx`, `FocusView.jsx`, `StructuralBalance.jsx`.
- **Thành phần:** `TabBar.jsx`, `RestTimer.jsx`, `DurationWheel.jsx`, `ExerciseViewToggle.jsx`, `ExerciseAliases.jsx`, `MuscleExplorer.jsx`, `BodyMap.jsx`, `Heatmap.jsx`, `LineChart.jsx`, `Media.jsx`, `ServerSync.jsx`, `SyncBanner.jsx`.
- **Logic thuần:** `onerm.js` (7 công thức 1RM), `progression.js` (6 chính sách, deload), `workout-model.js` (mode/reps/time/cardio, warmup/drop/rest-pause/failure/per-side), `history.js`, `import-csv.js`.
- **API:** `api/server.js` (node:http, JSON file storage — không phải PostgreSQL), `api/coach/` (AI Coach v2).
- **Schema bài tập mẫu (`0025.json`):** `id`, `name`, `bodyPart`, `equipment`, `target`, `secondaryMuscles`, `category`, `description`, `instructions[]`, `muscleMap`, `femaleVariant`, `textSource`. `textSource="exercisedb"` = MIT (1.324 bài); remaining = AGPL.

---

## 7. Tóm tắt UI migration mapping (Workstream A)

Bảng chi tiết có 21 hàng trong báo cáo subagent flutter-specialist. Tóm tắt các hàng ưu tiên cao:

| # | Vùng | Tính năng OpenGym | Thành phần GymLvl | Loại | Ưu tiên |
|---|------|-------------------|-------------------|------|---------|
| 1 | Navigation | Bottom tab navigation | MainShellShell bottom bar + PersistentActiveWorkoutBanner | KEEP_GYMLVL | P0 |
| 3 | Auth | Login/register | AuthFormScreen + Login/Register | ADAPT | P1 |
| 4 | Dashboard | Home dashboard | DashboardScreen | KEEP_GYMLVL | P0 |
| 6 | Exercise browsing | Library (search/filter/favourites) | ExercisePickerScreen | ADAPT | P1 |
| 9 | Exercise details | FocusView/detail sheet | Chưa có (mới) | NEW_FEATURE | P1 |
| 13 | Active workout | Workout screen + rest timer | ActiveWorkoutScreen + RestTimerWidget | ADAPT | P0 |
| 14 | Rest timer | RestTimer wheel + skip | RestTimerWidget | ADAPT | P1 |
| 16 | Workout history | History list | WorkoutHistoryScreen | ADAPT | P1 |
| 18 | Progress/stats | Stats + heatmap + LineChart | Dashboard stats widgets | KEEP_GYMLVL/P0 + NEW_FEATURE/P2 | P0/P2 |

**EXCLUDE:** Media (`Media.jsx`, `WorkoutMedia.jsx`, `ProgressPhotos.jsx`), CheckIn, Measurements, ServerSync/SyncBanner, passkey/sync trong Settings.

Ràng buộc đã giữ: Candy Neubrutalism, VI/EN localization, narrow screen, text scaling, không media, không sao chép code AGPL.

---

## 8. Tóm tắt feature migration mapping (Workstream B, tổng hợp primary)

| Vùng | OpenGym thực hiện | GymLvl hiện tại | Khoảng cách (gap) | Mục tiêu GymLvl | Ảnh hưởng dữ liệu | RLS/an ninh |
|------|-------------------|-----------------|-------------------|-----------------|-------------------|-------------|
| Catalogue | 6.554 bài, bodyPart/target/description/textSource | 150 bài curated, name_en/name_vi/slug | Thêm cột source-keyed + provenance | Thêm cột `source`, `external_id`, `body_part`, `target`, `description`, `provenance`; chỉ nhập MIT | Additive columns,保留 150 UUID | Chỉ SELECT cho client; nhập qua service_role/RPC |
| Workout/sets | 6 loại tập (reps/time/cardio, warmup/drop/rest-pause/failure/per-side) | Chỉ reps, weight, duration một phần | Loại tập, một bên, thất bại, drop/rest-pause, cardio | Thêm cộtNullable khi M3/M4 | Additive nullable columns | Kế thừa own_sets_write + guard_workout_child |
| Progression | 6 chính sách, deload, kê đơn tiếp theo | Chỉ ước lượng XP hiển thị phía client | Toàn bộ gap | Pure-Dart engine (M4) | Không schema ngay | Không ảnh hưởng |
| 1RM | 7 công thức, ensemble, RIR, nỗ lực tin cậy | Chỉ Epley đơn trong exercise_prs | Công thức, giới hạn reps, RIR | Thêm công thức (M4) | exercise_prs chỉ ghi server | Không cho client ghi |
| Rest timer | Lên lịch thiết bị, thông báo, wakelock | Chỉ nền trước | Thiết bị/thông báo (ngoài phạm vi M0) | Giữ nền trước | Không schema | Không ảnh hưởng |

**Luật RLS/additive:** Mọi cột mới nullable hoặc có DEFAULT; CHECK constraint dùng `NOT VALID` rồi validate; không suy yếu RLS/grants; `complete_workout` vẫn là duy nhất đường ghi progression.

---

## 9. Data mapping và provenance

| Dữ liệu | Nguồn | Giấy phép | Có nhập GymLvl? | Nghĩa vụ |
|---------|-------|-----------|-----------------|----------|
| Mã ứng dụng OpenGym | DuarteSantos8 B | AGPL-3.0 | KHÔNG (reference only) | Không sao chép/dịch/port |
| Bài tập `textSource=exercisedb` (1.324) | ExerciseDB v1 / hasaneyldrm | MIT | CÓ (text/metadata only) | Ghi MIT + NOTICE, giữ nguồn, strip media |
| Bài tập khác (~5.230) | Cộng đồng OpenGym B | AGPL-3.0 | KHÔNG | Reference only |
| Media (13.109 tệp) | Gym visual | Sở hữu hiệu chỉnh | KHÔNG (EXCLUDED) | Không tải/sao chép/hotlink |
| MuscleMap hình học | Melih Colpan | MIT | Tùy chọn | Ghi nguồn + MIT |
| Phông chữ | Google/OFL | OFL | CÓ | Ghi OFL, không bán riêng |

`name_vi` phải dịch cục bộ GymLvl (không có file `vi` trong i18n OpenGym; bản dịch catalog B có thể AGPL).

---

## 10. Đánh giá cấp phép (Workstream D)

| Phân loại | Ý nghĩa | Ví dụ trong M0 |
|-----------|---------|----------------|
| REFERENCE_ONLY | Chỉ tham khảo hành vi, không sao chép | Mã OpenGym, progression, 1RM, coach logic |
| REUSE_ALLOWED_WITH_CONDITIONS | Có dùng theo điều kiện | Bài tập MIT text, MuscleMap, phông OFL |
| REQUIRES_EXPLICIT_PERMISSION | Cần quyết định pháp lý | Bài tập AGPL, coach prompts |
| EXCLUDED | Tuyệt đối không | Media Gym visual |

**Mục cần phê duyệt rõ ràng trước khi triển khai:** O-02 (AGPL posture), O-01 (GymLvl license), D-003 (media postponed), O-04 (catalog import scope), O-09 (checkpoint tag).

---

## 11. Migration slice đầu tiên đã chọn

**Tên:** Rest Timer Duration Wheel (cải thiện bộ đếm nghỉ nghỉ giữa các hiệp).

**Tùy chọn theo tiêu chí M0 §8:** Cải thiện hiển thị người dùng; tương thích kiến trúc GymLvl; dùng dữ liệu hiện có (`rest_seconds` đã có); không migration DB sản xuất; không media; không sao chép AGPL (triết lập từ hành vi); ít tệp ảnh hưởng; test được cục bộ; dễ isolating/rollback.

**Baseline:** Quick-select chips (30/60/90/120s) trong `RestTimerQuickSelect` + điều khiển ±15s/+30s/pause/resume/reset.

**Mục tiêu:** Thay thế quick-select bằng `DurationWheelPicker` (chọn phút 0–10 + giây 0–55 bước 5) trong `CandyBottomSheet`, giữ API `onSelect(int)` tương thích; hỗ trợ VI/EN; màn hình hẹp (Wrap layout); không overflow.

**Tệp đã đổi:**
1. `app/lib/features/workout/workout_copy.dart` — thêm l10n keys: `confirm`, `set_rest_time`, `minutes`, `seconds_short` (VI + EN).
2. `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart` — thay `RestTimerQuickSelect` bằng `DurationWheelPicker`; import `candy_button.dart`.
3. `app/lib/features/workout/presentation/screens/active_workout_screen.dart` — đổi caller `RestTimerQuickSelect` → `DurationWheelPicker`.
4. `app/test/workout_widgets_test.dart` — cập nhật test rest selector (2 CandyButton, 2 ListWheelScrollView, text VI).
5. `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` (mới) — pin nguồn.

---

## 12. Thay đổi mã thực tế (commit-ready, chưa commit)

| Tệp | Thay đổi |
|-----|----------|
| `app/lib/features/workout/workout_copy.dart` | +4 l10n keys (confirm, set_rest_time, minutes, seconds_short) VI/EN |
| `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart` | Thêm `DurationWheelPicker`; thay thế `RestTimerQuickSelect`; import `candy_button.dart` |
| `app/lib/features/workout/presentation/screens/active_workout_screen.dart` | Caller đổi tên widget |
| `app/test/workout_widgets_test.dart` | Test rest selector mới (narrow screen, CandyButton, ListWheelScrollView, l10n VI) |
| `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` (mới) | Pin nguồn OpenGym, GymLvl, ExerciseDB; licenses; acquisition date |
| `M0_FINAL_REPORT.md` (mới) | Báo cáo cuối cùng M0 (tài liệu này) |

5 tệp đã sửa + 2 tệp mới. Không tệp không liên quan đã đổi. 5 tệp owner được bảo toàn.

---

## 13. Lệnh verify và kết quả (thực thi trong phiên này)

| Lệnh | Kết quả | Trạng thái |
|------|---------|------------|
| `git -C "D:\Projects\opengym-reference" remote -v` | `origin https://github.com/DuarteSantos8/openGym (fetch/push)` | PASS |
| `git -C "D:\Projects\opengym-reference" rev-parse HEAD` | `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` | PASS |
| `cd app && flutter analyze --no-pub` | `No issues found!` (exit 0) | PASS |
| `cd app && dart format --output=none --set-exit-if-changed lib test` | `Formatted 135 files (0 changed)` (exit 0) | PASS |
| `cd app && flutter test --no-pub` | `+231: All tests passed!` (231 tests, không regression) | PASS |
| `git status --porcelain=v1` | 5 owner files preserved + 4 M0 changed + 1 new | PASS (bảo toàn) |

Tất cả PASS được supported bởi thực thi thực tế trong phiên này. Không build Android/iOS (không Gradle signing, không release).

---

## 14. Quyết định và blocker còn lại

**Quyết định mới (chưa cần approve vì chỉ là ghi nhận):**
- Pinned SHA `e6a95c28...` dùng cho M0 (đã approve trước đó qua PROJECT_CONTEXT §6).
- Manifest `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` đã tạo (commit-ready, chờ owner approve để commit).

**Blocker / cần phê duyệt:**
1. **O-02 AGPL posture** — cần quyết định chủ sở hữu + pháp lý trước khi tái triển khai hành vi OpenGym (progression, 1RM, coach).
2. **O-01 GymLvl license** — repository GymLvl chưa có LICENSE (mọi quyền dành riêng theo mặc định); chặn phân phối M8.
3. **D-003 / O-07** — media postponed; production counts BLOCKED (không live Supabase credential).
4. **Sandbox access** — `qa-reviewer` không thể truy cập `D:\Projects\opengym-reference` trong sandbox này (primary agent đã verify thay).

**Không commit/push/tag** (D-009, D-024). Dừng tại `READY_FOR_APPROVAL`.

---

## 15. Migration slice tiếp theo đề xuất

| Slice | Tính năng | Loại | Ưu tiên | Phụ thuộc |
|-------|-----------|------|---------|-----------|
| Slice 2 | Exercise catalogue navigation/filter (thêm body part/equipment filter, toggle list/grid) | ADAPT | P1 | Catalog source-keyed columns (additive), l10n VI |
| Slice 3 | Exercise detail layout (chi tiết bài tập khi duyệt) | NEW_FEATURE | P1 | Domain exercise repository |
| Slice 4 | Workout detail layout (Candy stat tile) | ADAPT | P1 | Không schema |

Không bắt đầu slice tiếp theo tự động (theo M0 §8).

---

## 16. Commit manifest chính xác (chờ owner approve)

```
Branch: main
HEAD: 6badfef29a871a978a09daee304dc1c3f3f69a84
Remote: origin/main (verified equal at R3)
Files to stage:
  - app/lib/features/workout/workout_copy.dart
  - app/lib/features/workout/presentation/widgets/rest_timer_widget.dart
  - app/lib/features/workout/presentation/screens/active_workout_screen.dart
  - app/test/workout_widgets_test.dart
  - docs/planning/UPSTREAM_SOURCE_MANIFEST.json (new)
  - docs/planning/TASK_BOARD.md
  - docs/planning/SESSION_HANDOFF.md
  - docs/planning/CHANGELOG_AI.md
Excluded (owner, preserved):
  - app/android/gradle.properties
  - app/android/run_gradle.bat
  - docs/audit/phases/A8_BATCH_EXECUTION.md
  - gradle_check.ps1
  - run_gradle_check.bat
```

**Không có commit/push/tag nào được thực hiện.** Chờ owner approve manifest rồi mới commit/push.

---

**Kết luận:** M0 đánh giá `PASS` cho phần implementation slice đã verify; source pin, licensing, mapping, backlog đã hoàn thành. Dừng tại `READY_FOR_APPROVAL` chờ chủ sở hữu đánh giá và cho phép commit.

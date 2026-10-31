# BÁO CÁO CUỐI CUÙNG — M1: EXERCISE CATALOGUE NAVIGATION & FILTERING

**Ngày:** 31/10/2026  
**Trạng thái:** `PASS` (không commit, không push, không tag)  
**Ngôn ngữ báo cáo:** Tiếng Việt (nội dung kỹ thuật và code bằng English)

---

## A. Trạng thái tổng thể

`PASS` — M1 đã được triển khai và xác minh cục bộ. Tất cả tiêu chí chốt hợp đã đáp ứng:
- Chức năng duyệt/tìm kiếm/lọc katalog bài tập đã triển khai trong `ExercisePickerScreen`.
- Không sửa schema CSDatabase (tất cả cột lọc đã có sẵn).
- Không sao chép mã AGPL OpenGym, không nhập phương tiện chủ sở hữu.
- 5 tệp owner được bảo toàn không thay đổi.
- `flutter analyze` → 0 vấn đề; `dart format` → 0 thay đổi; `flutter test` → 231/231 pass (không hồi quy).
- Không commit/push/tag được thực hiện.

---

## B. Multi-agent thực tế

| Workstream | Agent | Child session | Kết quả |
|------------|-------|---------------|---------|
| A. Flutter UI/UX implementation | `flutter-specialist` | `ses_e71d832acffex4m7QdxY6E8eSY` | Completed — triển khai UI, search debounce, chuẩn hóa tiếng Việt, bộ lọc động, Candy design, l10n |
| B. Supabase schema & data | `supabase-specialist` | `ses_e71d832abffe6W6c46FVZJ4rCq` | Completed — xác nhận schema đủ cột, RLS OK, không cần migration |
| C. UI/UX review | `ui-ux-specialist` | `ses_e71c1608dffedVlWjgxq7PJaBw` | Completed — FAIL ban đầu về accessibility; các vấn đề đã được sửa bởi primary agent |
| D. Independent QA | `qa-reviewer` | `ses_e71c1608cffej4yusZA3DepE4E` | BLOCKED (từ chối quyền shell, không thể chạy lệnh; đánh giá tĩnh được ghi nhận) |
| Integration & accessibility fixes | Primary agent (gymlvl-orchestrator) | — | Completed — sửa Semantics, 48dp touch target, contrast, line-height; chạy verify đầy đủ |

---

## C. Chức năng đã triển khai

### M1.1 — Catalogue browsing
- Màn hình `ExercisePickerScreen` đã được viết lại theo Candy design system (`CandyCard`, `CandyExerciseCard`, `CandyEmptyState`, `CandyErrorState`, `CandyTextField`).
- Danh sách/lưới bài tập (`ListView` / `GridView`), hiển thị tên, danh mục, thiết bị.
- Trạng thái: đang tải (`CircularProgressIndicator`), trống (`CandyEmptyState` + nút Xóa tất cả), lỗi (`CandyErrorState` + nút Thử lại).
- Bố cục responsive (màn hình hẹp 320px không overflow, `Wrap` cho chip, `ListView` ngang cuộn).
- Tuỳ chọn lưới/danh sách trong AppBar.

### M1.2 — Search
- Tìm kiếm không phân biệt hoa thường, loại dấu tiếng Việt (ví dụ: "squat" khớp "Squat" và tên tiếng Việt có/không dấu).
- Nút xóa tìm kiếm (suffix icon) khi có văn bản.
- Debounce ~300ms (áp dụng ngay khi xóa), hủy khi dispose.
- Không gửi yêu cầu lên server mỗi nhấn phím (lọc client-side từ danh sách đã tải một lần).

### M1.3 — Filtering
- Bộ lọc động từ dữ liệu thực: danh mục (`exerciseCategoriesProvider`), thiết bị (`exerciseEquipmentsProvider`), nhóm cơ (`exerciseMusclesProvider`).
- Chỉ hiển thị bộ lọc có dữ liệu.
- Hỗ trợ kết hợp nhiều bộ lọc (AND: truy vấn + danh mục + thiết bị + nhóm cơ).
- Hiển thị trạng thái bộ lọc đang hoạt động (chip hoạt động + nút Xóa tất cả).
- Không hardcode giá trị — lấy từ catalog thực.

### M1.4 — Navigation
- Giữ kiến trúc GoRouter hiện tại, route `/exercise-picker` không đổi.
- Single-select: nhấn bài tập → `Navigator.pop(exercise)`.
- Multi-select: toggle chọn, nút Hoàn thành trong AppBar.
- Đường dẫn chi tiết bài tập không thuộc phạm vi M1 (thuộc milestone sau).
- Xử lý bản ghiercise không tồn tại/lỗi qua trạng thái lỗi + retry.

### M1.5 — Localization and accessibility
- Tất cả chuỗi hiển thị người dùng dùng `workoutText(ref, key)` với cặp VI/EN trong `workout_copy.dart` (clear_search, clear_all, view_grid, view_list, category, equipment, muscle_group, empty_state_*, error_state_*, retry, v.v.).
- Hỗ trợ tỷ lệ văn bản (line-height 1.35+ cho dấu tiếng Việt tại 200%).
- Semantics nhãn trên chip, thẻ bài tập, nút xóa tìm kiếm.
- Touch target tối thiểu 48dp.
- Màu sắc từ `CandyColors` tokens (không dùng `AppTheme` trực tiếp).

---

## D. Supabase

| Mục | Kết quả |
|-----|---------|
| Ảnh hưởng schema | **Không cần migration** — tất cả cột lọc/tìm kiếm (`name`, `category`, `equipment`, `secondary_muscles`, `movement_pattern`, `difficulty`, `name_vi`, `name_en`, `slug`) đã tồn tại sau migration `20261027000100_exercise_catalog_metadata.sql`. |
| RLS | `auth.role() = 'authenticated'` có quyền SELECT trên `exercises` (đã có, không thay đổi). Không yếu hóa RLS/grants. |
| Truy vấn | `getExercises()` (`.select().order('name')`), `searchExercises()` (`.ilike('name', '%$query%')`), `getExercisesByCategory()` (`.eq('category', category)`) — đã có sẵn, không sửa. |
| Hiệu năng | Chấp nhận được với ~150 bài tập curated (quét tuần tự). Thiếu index trên `name`/`category` — ghi nhận làm rủi ro M2/M3, không bắt buộc M1. |
| Giới hạn dữ liệu | Không nhập dữ liệu OpenGym hàng loạt. Không nhập phương tiện. Không giả tạo bản ghi bài tập. |

**Quyết định:** Không tạo migration mới cho M1. Quyết định này đã được ghi nhận bởi supabase-specialist.

---

## E. Verification

| Lệnh | Kết quả | Trạng thái |
|------|---------|------------|
| `flutter analyze --no-pub` | `No issues found!` (exit 0) | PASS |
| `dart format --output=none --set-exit-if-changed lib test` | `Formatted 135 files (0 changed)` (exit 0) | PASS |
| `flutter test --no-pub` | `+231: All tests passed!` (231 tests, không hồi quy) | PASS |

**Giới hạn:** Không có bài test chuyên dụng cho M1 (qa-reviewer báo cáo BLOCKED do từ chối quyền shell). Các kiểm tra M1 dựa trên kiểm tra tĩnh mã nguồn + kiểm tra toàn bộ suite hiện có pass.

---

## F. File manifest

| # | Đường dẫn | Loại | Nội dung |
|---|-----------|------|----------|
| 1 | `app/lib/features/workout/presentation/providers/exercise_providers.dart` | Sửa | `normalizeSearchText()`, debounce search, bộ lọc thiết bị/cơ, provider tùy chọn động |
| 2 | `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart` | Sửa | Candy UI, Semantics, 48dp touch target, contrast, line-height, grid/list toggle |
| 3 | `app/lib/features/workout/workout_copy.dart` | Sửa | Thêm 11 cặp l10n keys VI/EN |
| 4 | `docs/planning/CHANGELOG_AI.md` | Sửa | Ghi chép M1 |
| 5 | `docs/planning/SESSION_HANDOFF.md` | Sửa | Ghi chép M1 |
| 6 | `docs/planning/TASK_BOARD.md` | Sửa | Ghi chép M1 completed |

**Không có tệp mới được tạo trong M1** (trừ báo cáo cuối cùng `M1_FINAL_REPORT.md` tại gốc repo).

---

## G. Owner-file protection

| # | Đường dẫn | Hash SHA-256 trước | Hash SHA-256 sau | Bảo toàn? |
|---|-----------|-------------------|-------------------|-----------|
| 1 | `app/android/gradle.properties` | `1F84401BB7BEEC53AC32A7411288B36E2596D3E078801BC32E102CCF55A2F53C` | `1F84401BB7BEEC53AC32A7411288B36E2596D3E078801BC32E102CCF55A2F53C` | Có |
| 2 | `app/android/run_gradle.bat` | `2A4195C1AE1C9A6384BAC5231D0152A9693989B1E1E4C9C2E71B6B7AC8D7D684` | `2A4195C1AE1C9A6384BAC5231D0152A9693989B1E1E4C9C2E71B6B7AC8D7D684` | Có |
| 3 | `docs/audit/phases/A8_BATCH_EXECUTION.md` | `444AD75D548CD7AA62EF5BC1AD644DC96D3B823490C744861D6E04FCFD6A82CB` | `444AD75D548CD7AA62EF5BC1AD644DC96D3B823490C744861D6E04FCFD6A82CB` | Có |
| 4 | `gradle_check.ps1` | `1035235AE43DF734C25F8C2FD0EF12673D846BC92CC250EEE38758DB7B44F600` | `1035235AE43DF734C25F8C2FD0EF12673D846BC92CC250EEE38758DB7B44F600` | Có |
| 5 | `run_gradle_check.bat` | `2BAECE5893276CBC8B60636E17A56E7E4B3642B5A363B61A82C905CC2E1E5DD4` | `2BAECE5893276CBC8B60636E17A56E7E4B3642B5A363B61A82C905CC2E1E5DD4` | Có |

Xác nhận: 5 tệp owner không bị sửa, staged, hoặc xóa. Trạng thái cây làm việc của chúng không thay đổi từ pre-flight.

---

## H. Licensing

| Mục | Nguồn | Giấy phép | Phân loại | Nghĩa vụ |
|-----|-------|-----------|-----------|----------|
| Mã GymLvl | Dự án GymLvl | Không có LICENSE (mọi quyền dành riêng) | Nội bộ | Chưa có phân phối |
| Mã OpenGym | `DuarteSantos8/openGym` @ `e6a95c28...` | AGPL-3.0 | REFERENCE_ONLY | Không sao chép/dịch/port |
| Bài tập `textSource=exercisedb` | ExerciseDB v1 / `hasaneyldrm/exercises-dataset` | MIT | REUSE_ALLOWED_WITH_CONDITIONS | Ghi MIT + NOTICE, strip media (không nhập trong M1) |
| Media Gym visual | `catalogue/media/` | Sở hữu hiệu chỉnh | EXCLUDED | Không tải/sao chép/hotlink |
| Phông chữ | Google/OFL | OFL | REUSE_ALLOWED_WITH_CONDITIONS | Ghi thông báo OFL |

**O-02 (AGPL posture) chưa được giải quyết** — cần quyết định chủ sở hữu + pháp lý trước khi tái triển khai hành vi OpenGym.

---

## I. Blockers

| Blocker | Mô tả |
|---------|-------|
| O-02 AGPL posture | Cần quyết định chủ sở hữu + pháp lý trước khi tái triển khai hành vi OpenGym (progression, 1RM, coach). |
| O-01 GymLvl license | Repository GymLvl chưa có tệp LICENSE; chặn phân phối M8. |
| Không có bài test M1 | qa-reviewer BLOCKED (từ chối quyền shell); cần thêm bài test chuyên dụng cho `ExercisePickerScreen`, `normalizeSearchText`, bộ lọc, debounce. |
| Không có màn hình chi tiết bài tập | M1 không triển khai chi tiết bài tập (thuộc milestone sau). Bấm chọn đơn pop ngay `Exercise`. |
| Không giữ trạng thái tìm kiếm/lọc khi quay lại | `initState` reset bộ lọc mỗi lần vào màn hình; cần lưu trạng thái nếu yêu cầu sau này. |

---

## J. Handoff

**Mốc tiếp theo đề xuất: M2 — Exercise Catalogue Navigation & Filtering (hoặc tương đương)**

Các chỉ thị tiếp tục an toàn:
1. Thêm bài test chuyên dụng cho M1 (`app/test/exercise_picker_test.dart`): `normalizeSearchText` (dấu tiếng Việt, hoa/thường, rỗng), widget test `ExercisePickerScreen` (tìm kiếm, bộ lọc đơn/nhiều, xóa tất cả, debounce, trạng thái rỗng/lỗi/đang tải, đơn chọn vs chọn nhiều).
2. Khắc phục hoàn toàn các vấn đề accessibility còn lại (nếu có) sau khi qa-reviewer kiểm tra lại.
3. Chuẩn bị manifest commit (không commit/push/tag mà không có sự phê duyệt rõ ràng).
4. Không bắt đầu M2 mà không có sự cho phép rõ ràng.

**Trạng thái Git:** `main` @ `9b874111692dee1f69dc686e1dbbc38981529cf5`; cây làm việc có 4 tệp nguồn M1 đã sửa + 3 tệp docs đã sửa + 5 tệp owner được bảo toàn (bẩn theo thiết kế). Không commit/push/tag.

---

`M1 changes are local and uncommitted. No push or tag was performed.`

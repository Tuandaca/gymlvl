# TÀI LIỆU THEO DÕI LỖI (ERRORS TRACKING)

## [2026-04-09 02:50] - FunctionException 400 Unauthorized in calculate-xp
- **Type**: Integration / Auth Error
- **Severity**: Critical
- **File**: `app/lib/features/workout/data/supabase_workout_repository.dart` & `supabase/functions/calculate-xp/index.ts`
- **Agent**: @backend-specialist
- **Root Cause**: Edge Function không nhận diện được người dùng do cơ chế xác thực implicit trong môi trường function đôi khi không ổn định. App chưa gửi Token Authorization một cách tường minh dẫn đến lỗi 400.
- **Fix Applied**: 
    1. Ép App gửi `Authorization: Bearer <token>` trong header.
    2. Sửa Backend dùng `auth.getUser(token)` thay vì `auth.getUser()` không tham số.
- **Prevention**: Luôn sử dụng cơ chế truyền Token tường minh (Explicit Token Passing) cho các Edge Function yêu cầu xác thực người dùng.
- **Status**: Fixed

---

File này lưu trữ các lỗi gặp phải trong quá trình phát triển để AI (GymLevel Agent) học tập, tránh lặp lại.

## [2026-04-05 21:40] - Lỗi Syntax BorderStyle.dash
- **Type**: Syntax Error
- **Severity**: Medium
- **File**: `app/lib/features/workout/presentation/screens/active_workout_screen.dart`
- **Agent**: GymLevel Agent
- **Root Cause**: Gán `style: BorderStyle.dash` cho `Border.all()`. Trong Flutter, `BorderStyle` enum chỉ hỗ trợ `.none` và `.solid`. Nếu muốn dash border phải dùng package ngoài (như `dotted_border`) hoặc CustomPainter.
- **Error Message**: 
  ```
  error G75B77105: Member not found: 'dash'
  ```
- **Fix Applied**: Sửa đổi `BorderStyle.dash` thành `BorderStyle.solid`.
- **Prevention**: Khi dùng `Border.all` trong Flutter framework chuẩn, tuyệt đối chỉ dùng `BorderStyle.solid` hoặc bỏ qua config style (default đã là solid).
- **Status**: Fixed

---

## [2026-04-05 21:51] - Freezed Code Generation Mismatch (isSetupPhase)
- **Type**: Process & Test Failure (Build Fail)
- **Severity**: High
- **File**: `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`
- **Agent**: GymLevel Agent
- **Root Cause**: Sau khi thêm property `isSetupPhase` vào abstract class của Freezed `ActiveWorkoutState`, quá trình chạy `build_runner` chưa hoàn thành (thường do có lỗi syntax chặn luồng biên dịch của analyzer như lỗi `BorderStyle.dash` ở trên hoặc terminal bị Pause). Việc Freezed không tạo mới setter/getter dẫn đến code sử dụng `isSetupPhase` trong controller và screen ném hàng loạt lỗi constructor mismatch.
- **Error Message**: 
  ```
  The getter 'isSetupPhase' isn't defined for the type 'ActiveWorkoutState'.
  No named parameter with the name 'isSetupPhase'.
  The constructor function type ... isn't a subtype ...
  ```
- **Fix Applied**: Sửa lỗi cú pháp cản trở bộ analyzer trước tiên, sau đó gõ đúp lệnh `flutter pub run build_runner build --delete-conflicting-outputs` tại Terminal (tránh gửi qua cmd /c chạy ngầm rồi bị đứng), đợi compiler báo "Succeeded" rồi mới chạy app lại (`flutter run`). Chạy `flutter analyze` để xác thực sạch lỗi.
- **Prevention**: Luôn chạy `dart analyze` hoặc đảm bảo terminal build_runner hoàn thành "Built with build_runner/jit... wrote X outputs" ĐẦY ĐỦ rồi mới update các file controller logic/UI liên quan để tránh missing properties. NÊN lưu ý Windows Cmd hay bị Tạm dừng (Quick Edit Pause), nên cân nhắc dùng `\n` để un-pause.
- **Status**: Fixed

---

## [2026-04-06 17:55] - Import Path Mismatch (LevelUpOverlay)
- **Type**: Agent Error (Execution Error)
- **Severity**: Medium
- **File**: `app/lib/features/workout/presentation/screens/active_workout_screen.dart:14`
- **Agent**: GymLevel Agent
- **Root Cause**: Agent tính toán sai số lượng dấu `../` khi import file từ thư mục `progression` sang thư mục `workout`. `active_workout_screen` ở sâu 4 cấp (`features/workout/presentation/screens`), trong khi đường dẫn chỉ có 2 dấu `../` dẫn đến trình biên dịch không tìm thấy Widget `LevelUpOverlay`.
- **Error Message**: 
  ```
  Error when reading 'lib/features/workout/progression/presentation/widgets/level_up_overlay.dart': The system cannot find the path specified
  ```
- **Fix Applied**: Sửa số cấp lùi thư mục từ `../../` thành `../../../`.
- **Prevention**: Khi tính toán relative import đan chéo giữa các feature (Domain-Driven Design), Agent phải luôn kiểm tra cẩn thận chiều sâu tuyệt đối (depth) của cả 2 file trước khi tạo đường dẫn relative.
- **Status**: Fixed

---

## [2026-10-26] — Product audit: progression authority and atomic completion

- **Severity:** Critical.
- **Root cause:** Owner-wide write policies and client onboarding allowed changes to level/class XP. Workout completion issued independent parallel writes for user XP, class XP, ledger and completion flags, permitting partial state or duplicate awards on retries.
- **Repair:** Versioned baseline/hardening migrations restrict table/column privileges and RLS, initialize progression in authenticated RPCs, lock user/workout state, and store an idempotent completion response. Child records become immutable after completion; server triggers snapshot personal-record baselines.
- **Regression prevention:** Execute migration replay, anonymous/cross-user/direct-XP manipulation, rollback, quest/streak and duplicate-completion tests. True multi-session concurrency and the Supabase gateway require separate full-stack verification; do not infer them from an in-memory test run.
- **Status:** Implemented; exact executed security and release gates are maintained in `docs/IMPLEMENTATION_STATUS.md`.

## [2026-10-26] — Confirmation-aware auth and swallowed errors

- **Severity:** High.
- **Root cause:** Signup tried to create the public user row even when email confirmation returned no session. Profile/stat/quest providers converted request failures to null, confusing unavailable data with new-user onboarding or empty screens.
- **Repair:** Auth-trigger identity creation, confirmation-aware signup/recovery, explicit session handling and recoverable error states. Missing client configuration now displays setup instructions. Public-key configuration rejects secret/service-role keys.
- **Regression prevention:** Cover confirmed/pending signup, session restoration, provider failure, password-recovery redirects, and privileged-key rejection. Use real email/gateway checks for the final auth acceptance gate.
- **Status:** Focused auth/config tests passing; full-stack limitations remain in the tracked report.

## [2026-10-26] — Build drift, onboarding navigation and hidden workout controls

- **Severity:** High.
- **Root cause:** Onboarding referenced removed recommendation APIs and stopped before the ninth confirmation page. Historical progression tests called obsolete signatures. Duplicate theme implementations and hover-only controls reduced consistency/accessibility.
- **Repair:** Current onboarding API/navigation, regenerated models after domain changes, one theme with compatibility export, reachable touch controls, and updated meaningful regression coverage.
- **Regression prevention:** Run generation once when annotations change, wait for completion, then analyze/test/build. Existing `BorderStyle.dash` and LevelUpOverlay import incidents remain historical; they were not treated as proof of current defects.
- **Status:** Integration verification in progress; see the current report rather than assuming earlier fixed entries prove a passing build.

## [2026-10-26] — Credential logging and unsafe future admin advice

- **Severity:** High.
- **Root cause:** calculate-xp logged a bearer-token prefix; the future admin API document suggested distributing service_role to the browser and reading an application role from the JWT database-role field.
- **Repair:** Remove credential logging; retain JWT verification and explicit user validation. Admin documentation now requires a publishable key/user session, trusted app_metadata role assignments, server-only privileged operations and transactional auditing. The admin application remains a future proposal.
- **Regression prevention:** Review logs/configuration and generated bundles for credentials; test both grants and policies. Do not log access tokens even partially.
- **Status:** Implemented; audit evidence and deployment status remain in `docs/IMPLEMENTATION_STATUS.md`.


## [2026-10-26 21:05] - Lỗi Duplicate named argument 'surface' trong AppTheme.darkTheme

- **Type**: Syntax Error
- **Severity**: High
- **File**: `app/lib/core/theme/app_theme.dart:39`
- **Agent**: gymlvlAgent
- **Root Cause**: Trong quá trình refactor thay thế `background: background` thành `surface` theo Material 3, tham số `surface` bị khai báo 2 lần liên tiếp (`surface: background` và `surface: panelBackground`), gây lỗi biên dịch ở các test suite phụ thuộc theme (`ui_regression_test`, `widget_test`, `workout_widgets_test`).
- **Error Message**: 
  ```
  lib/core/theme/app_theme.dart:39:9: Error: Duplicated named argument 'surface'.
          surface: panelBackground,
          ^^^^^^^
  ```
- **Fix Applied**: Loại bỏ dòng thừa `surface: background,`, giữ nguyên cấu hình màu panel chuẩn `surface: panelBackground,`. Đồng thời chuẩn hóa format và xử lý 5 linter warnings để `flutter analyze` đạt 0 issues.
- **Prevention**: Luôn chạy `flutter analyze` hoặc `flutter test` ngay sau khi refactor theme parameters để bắt sớm lỗi duplicated arguments.
- **Status**: Fixed

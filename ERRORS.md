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

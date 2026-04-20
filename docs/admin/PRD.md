# Product Requirements Document (PRD) - GymLevel Admin Panel

## 1. Tổng Quan Kế Hoạch (Executive Summary)
Admin Panel là trung tâm điều khiển (Command Center) của hệ thống GymLevel. Mục tiêu là cung cấp cho đội ngũ vận hành một giao diện web trực quan, mạnh mẽ và an toàn để quản lý vòng luân hồi game (Core Game Loop), nội dung luyện tập, cũng như theo dõi sức khoẻ của nền tảng mà không cần can thiệp trực tiếp vào Database hay Code.

## 2. Các Module Chức Năng Cốt Lõi

### Module 1: Quản Lý Người Dùng (User Management)
- **Danh sách người dùng:** Xem dạng bảng (Table) với tính năng tìm kiếm, lọc (theo level, trạng thái hoạt động, cấp bậc, ngày đăng ký).
- **Chi tiết User (User Profile):**
  - Xem thông tin cơ bản: Tên, Email, Level, Tổng XP, Hệ phái (Class).
  - Lịch sử tập luyện: Các buổi tập gần nhất, chỉ số tạ.
  - Lịch sử vi phạm (Log).
- **Hành động (Actions):** Khóa/Mở khóa tài khoản (có ghi chú lý do), Reset mật khẩu, Xem dưới góc nhìn user (Impersonation - tuỳ chọn).

### Module 2: Quản Lý Bài Tập (Exercise Management)
- **Danh sách bài tập:** Kho dữ liệu các bài tập Gym.
- **Thêm/Sửa/Xóa (CRUD):** 
  - Upload hình ảnh/video mô tả.
  - Phân loại: Nhóm cơ chính, Nhóm cơ phụ, Máy móc, Bodyweight.
  - Chỉ số Gamification: Độ khó, Multiplier XP (nếu có).

### Module 3: Quản Lý Danh Mục & Nội Dung (Category & Content)
- **Chương trình tập (Programs):** Build các gói tập (Ví dụ: 30 Ngày Giảm Mỡ, Mới Bắt Đầu).
- **Phân loại System:** Tạo và tối ưu các danh mục để AI Coach hoặc hệ thống gợi ý dễ dàng truy xuất dữ liệu.

### Module 4: Quản Lý Gamification (Hệ thống Game)
- **Game Config (Rules Engine):** 
  - Điều chỉnh XP Required theo từng level.
  - Điểu chỉnh Multiplier (Streak).
- **Hệ thống Nhiệm Vụ (Quests):**
  - Tạo các template Daily/Weekly Quests.
  - Định nghĩa Reward: Ví dụ: "Tập lưng xô -> +50 XP".
- **Thành tựu (Achievements/Badges):** Cấu hình ảnh huy hiệu, điều kiện mở khóa.

### Module 5: Báo Cáo & Thống Kê (Dashboard)
- **Real-time Metrics:** DAU (Daily Active Users), MAU.
- **Gym Metrics:** Tổng số workout logs trong ngày, Trung bình thời gian tập.
- **Gamification Metrics:** Tỷ lệ người chơi hoàn thành nhiệm vụ, Cấp độ trung bình của Server.

### Module 6: Quản Lý Hệ Thống (System & RBAC)
- **Role-Based Access Control (RBAC):** Super Admin, Content Manager, Support.
- **Audit Logs:** Ghi lại mọi hành động của Admin (Ai đã xoá bài tập X vào lúc mấy giờ).
- **Feature Toggles:** Bật/tắt bảo trì server, Bảo trì hệ thống XP.

## 3. Use Case Diagram (UML)

```mermaid
usecaseDiagram
    actor Admin
    actor "Content Manager" as Content
    actor "Support Staff" as Support

    package "GymLevel Admin Panel" {
        usecase "Xem Dashboard (Analytics)" as UC1
        
        usecase "Quản lý Users" as UC2
        usecase "Khóa/Mở Khóa Account" as UC2_1
        usecase "Xem Lịch Sử Luyện Tập" as UC2_2
        
        usecase "Quản lý Bài Tập (Exercises)" as UC3
        usecase "Tạo/Sửa Data Bài Tập" as UC3_1
        
        usecase "Quản lý Gamification (Quests/XP)" as UC4
        usecase "Điều chỉnh Tham số XP" as UC4_1
        
        usecase "Cấu hình Hệ thống (Feature Toggle)" as UC5
        usecase "Quản lý Audit Logs" as UC6
    }

    Admin --> UC1
    Admin --> UC2
    Admin --> UC3
    Admin --> UC4
    Admin --> UC5
    Admin --> UC6

    Content --> UC1
    Content --> UC3
    Content --> UC4

    Support --> UC1
    Support --> UC2
    Support --> UC2_1
    Support --> UC2_2
    
    UC2 ..> UC2_1 : extends
    UC2 ..> UC2_2 : extends
    UC3 ..> UC3_1 : extends
    UC4 ..> UC4_1 : extends
```

# System Architecture - GymLevel Admin Panel

## 1. Công Nghệ (Tech Stack Proposal)
Bởi vì GymLevel là một ứng dụng di động viết bằng Flutter và phụ thuộc vào Supabase, có hai lựa chọn chính để xây dựng Admin Panel. Giải pháp được chọn bên dưới dựa theo Design Patterns chuẩn ở môi trường Enterprise:

- **Frontend Framework:** Next.js (React) + TypeScript.
- **UI Component Library:** TailwindCSS + Shadcn/ui (Giao diện cực kì sạch đẹp, nhanh và có cảm giác "Dashboard" hiện đại).
- **Authentication & Backend:** Supabase (PostgreSQL + Auth + Edge Functions).
- **State Management:** React Query (để xử lý fetch API, cache và sync dữ liệu bảng biểu).

> *Lưu ý:* Việc không dùng Flutter Web để code Admin Panel là do Flutter Web không tối ưu SEO, bundle size lớn, và các components React/Tailwind cho dashboard (như chart, bảng grid) rất phong phú và sẵn sàng cho production hơn.

## 2. Security & RBAC (Quyền hạn)

Mô hình **Role-Based Access Control** (Quyền truy cập dựa trên vai trò):

1. **Super Admin:** Có toàn quyền hệ thống. Được phép thao tác tất cả bảng, cấp phát hoặc gỡ quyền của Admin khác.
2. **Content Manager:** Chỉ được xem và cấp nhật Module Bài Tập (Exercises), Quest Templates, Achievements. KHÔNG có quyền xoá User hay config Server.
3. **Support Level 1:** Chỉ được xem danh sách Users, log hoạt động cơ bản. Được khóa/mở khóa User nhưng phải ghi rõ lý do. Không thể đổi cấu hình game.

### Cách triển khai quyền hạ (Supabase Custom Claims):
- Auth user qua `supabase.auth.signInWithPassword()`
- Chạy trigger khi cấp quyền: Bơm `role` vào `app_metadata` trên JSON Web Token.
- Bảng Database bọc RLS check: 
  ```sql
  (auth.jwt() ->> 'role') = 'SUPER_ADMIN'
  ```

## 3. Kiến Trúc Modular (Folder Structure)

Project Next.js admin sẽ có cấu trúc như sau:

```
admin/
│
├── src/
│   ├── app/
│   │   ├── (auth)/login/       # Đăng nhập vào panel
│   │   ├── (dashboard)/        # Layout chính của Dashboard có Sidebar
│   │   │   ├── users/          # Module quản lý người chơi (User List, Detail)
│   │   │   ├── exercises/      # Module quản lý bài tập
│   │   │   ├── gamification/   # Quản lý Quest, Rewards, Level curve
│   │   │   └── system/         # Quản lý Feature Toggle, Audit logs
│   │   └── api/                # Next.js API Routes (Serverless) để gọi RPC
│   │
│   ├── components/             
│   │   ├── ui/                 # Shadcn/ui (Button, Table, Dialog, Toast)
│   │   └── shared/             # Sidebar, Navbar, StatCards
│   │
│   ├── lib/                    # Supabase Client, utils
│   │
│   └── hooks/                  # Dùng với React Query (useUsers, useQuests)
│
└── supabase/
    └── migrations/             # Chứa script SQL tạo admin table + triggers
```

## 4. Tích Hợp Gamification (Cách Admin điều khiển Game)

Admin Panel cho phép sửa đổi *trực tiếp* các thông số của GymLevel.
Ví dụ: Khi Admin vào trang **Gamification > Level Configs** và thay đổi công thức tính XP. Hệ thống không sửa Code của Flutter app. Hệ thống sẽ:
1. HTTP Patch đến `system_configs` ở Database với JSON Payload `{"xp_modifier": 1.2}`.
2. `system_configs` phát ra một `Postgres Change Event` (qua WebSockets).
3. Client (Mobile App) nhận WebSocket event và tự cập nhật công thức mới ngay lập tức hoặc ở lần mở app kế tiếp.
Đó là sự kỳ diệu của Real-time Content Delivery Management.

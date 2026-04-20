# API Specifications (Supabase Endpoints) - GymLevel Admin Panel

Do sử dụng hệ sinh thái Supabase, các hệ thống REST API chủ yếu được chia thành 2 loại:
1. **Direct Data Access (PostgREST API):** Sử dụng Supabase SDK trên Client với quyền `service_role` dành cho Admin (hoặc gán custom claims `role = 'admin'` với RLS Policies).
2. **Edge Functions (Deno):** Xử lý những Business Logic phức tạp hoặc cần trigger bên thứ ba.

---

## 1. Authentication & Authorization

### Cách cấu hình (Custom Role)
- App sử dụng **Supabase Auth**. Nếu user là Admin, `raw_app_meta_data` sẽ chứa key `{"role": "admin"}`.
- Toàn bộ queries ở Admin Panel hoạt động thông qua RLS kiểm tra: 
  `CREATE POLICY "admin_all" ON public.xyz FOR ALL USING (auth.jwt() ->> 'role' = 'admin');`

---

## 2. API Endpoints: Quản lý Người dùng (Users)

### 2.1 Fetch List Users (Có chia trang)
- **Phương thức:** `GET` /rest/v1/users
- **Tham số:** 
  - `limit`, `offset` (Pagination)
  - `is_locked=eq.true` (Lọc theo trạng thái)
- **Supabase JS:**
  ```javascript
  const { data, count } = await supabase
    .from('users')
    .select('id, email, display_name, level, total_xp, is_locked, locked_reason, created_at', { count: 'exact' })
    .order('created_at', { ascending: false });
  ```

### 2.2 Khóa / Mở khóa người dùng (Ban/Unban)
- **Loại:** Dùng Supabase RPC hoặc Edge Function `admin-ban-user`.
- **Lý do dùng Edge Function:** Ta cần ghi đè vào bảng `audit_logs` cùng một lúc với việc khóa (Transaction).
- **Endpoint:** `POST` `/functions/v1/admin-action`
- **Payload:**
  ```json
  {
    "action": "lock_user",
    "target_user_id": "uuid",
    "reason": "Phát hiện hack app để tự buff time workout max",
    "is_locked": true
  }
  ```

---

## 3. API Endpoints: Quản Lý Khối Lệnh Gamification (Quests / Configs)

### 3.1 Fetch System Configs
- **Phương thức:** `GET` /rest/v1/system_configs
- **Mô tả:** Lấy tham số cấu hình như Level scaling, Cap daily XP, Maintenance Mode.

### 3.2 Add / Update Quest Templates
- **Phương thức:** `POST` /rest/v1/quest_templates hoặc `PATCH`
- **Mô tả:** Admin tạo ra mẫu Quest mới.
- **Supabase JS:**
  ```javascript
  const { data, error } = await supabase
    .from('quest_templates')
    .insert([
      { title: "Tập lưng 3 ngảy", type: "WEEKLY", reward_xp: 200, conditions: { "target_group": "back", "target_count": 3 } }
    ]);
  ```
- **Lưu ý:** Ngay sau khi POST, gọi Edge Function `broadcast-game-update` (nếu cần re-render ở app mobile).

---

## 4. API Endpoints: Thống kê Dashboard (Analytics)

Bởi vì Query Analytics trực tiếp trên bảng dữ liệu lớn (Big Data) rất chậm. Ta sẽ dùng **RPC (Remote Procedure Call)** của Supabase để Database tự tính toán và trả về tổng.

### 4.1 Lấy tổng quan Dashboard
- **Phương thức:** `POST` /rpc/admin_get_dashboard_stats
- **Trả về (Return JSON):**
  ```json
  {
    "total_users": 15034,
    "mau": 3200,
    "dau": 850,
    "total_workouts_today": 420,
    "average_level": 8.5
  }
  ```
- **Kỹ thuật SQL (Bên dưới RPC):**
  Sử dụng `COUNT(*)` từ `users`, `COUNT(DISTINCT user_id)` trong bảng `workout_logs` theo Timezone.

---

## 5. Security & Rate Limiting

- Các api `/functions/v1/admin-*` phải được **Rate-limit** (sử dụng Deno KV).
- Mọi Request POST/PATCH đều tự động kích hoạt Database Trigger để ghi copy vào bảng `audit_logs` (Lưu User thực hiện, thời gian, state cũ, state mới).

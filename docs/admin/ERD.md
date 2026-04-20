# Entity Relationship Diagram (ERD) - GymLevel Admin & Gamification

Sơ đồ dưới đây tập trung vào Mối Quan Hệ Dữ Liệu (Data Relationship) cốt lõi dành cho Admin Panel và các khối Gamification. Các bảng hệ thống Workout hiện tại (Profile, Workout, Exercise) sẽ được mở rộng bằng cách thêm Relations với Admin.

```mermaid
erDiagram
    %% Core Tables
    USERS ||--o{ USER_CLASSES : "has"
    USERS ||--o{ WORKOUT_LOGS : "performs"
    USERS ||--o{ XP_LOGS : "earns"

    %% Gamification & Content
    EXERCISES ||--o{ EXERCISE_REWARDS : "yields"
    QUEST_TEMPLATES ||--o{ ACTIVE_QUESTS : "spawns"
    USERS ||--o{ ACTIVE_QUESTS : "completes"
    
    %% Admin Specific Tables
    ADMIN_ACCOUNTS ||--o{ AUDIT_LOGS : "generates action"
    SYSTEM_CONFIGS {
        string key PK
        jsonb value
        string description
    }

    %% Table Definitions
    USERS {
        uuid id PK
        string email
        string display_name
        int level
        int total_xp
        boolean is_locked
        string locked_reason
        timestamp locked_at
    }

    ADMIN_ACCOUNTS {
        uuid id PK "Refs auth.users"
        string role "SUPER_ADMIN | CONTENT_MANAGER | SUPPORT"
        string email
        timestamp last_login
    }

    AUDIT_LOGS {
        uuid id PK
        uuid admin_id FK
        string action_type "CREATE | UPDATE | DELETE | LOCK_USER"
        string target_table
        string target_id
        jsonb previous_state
        jsonb new_state
        timestamp created_at
    }

    EXERCISES {
        uuid id PK
        string name
        string category
        string difficulty
        boolean is_active
        uuid created_by FK "Admin Account"
    }

    QUEST_TEMPLATES {
        uuid id PK
        string type "DAILY | WEEKLY | MAIN"
        string title
        string description
        int target_value
        jsonb conditions 
        int reward_xp
        boolean is_active
    }

    ACTIVE_QUESTS {
        uuid id PK
        uuid user_id FK
        uuid template_id FK
        int current_progress
        string status "ONGOING | COMPLETED | EXPIRED"
        timestamp expires_at
    }
```

## Giải thích mở rộng (Schema Changes)

1. **`users` Table:**
   - Cần bổ sung thêm thông tin về cấm túc: `is_locked` (Boolean), `locked_reason` (Text), `locked_at` (Timestamp). Để Admin sử dụng cờ này khóa mõm hoặc ban tài khoản.
2. **`admin_accounts` & `audit_logs`:**
   - Bảo mật cốt lõi: Mọi thao tác ghi/xóa từ admin đều phải được viết qua RPC có lưu dấu vết vào Audit Logs (Theo dõi lịch sử chỉnh sửa tập lệnh).
3. **`system_configs`:**
   - Rất quan trọng để lưu tham số động (Dynamic Parameters) như Xp Requirement Modifier, Max Workout Per Day. Admin chỉ sửa Field này, client tự cập nhật mà không phải update app.
4. **`quest_templates`:**
   - Dùng để Admin tạo Content hàng ngày một cách linh động.

-- Canonical baseline consolidated from the legacy setup scripts.
-- CREATE IF NOT EXISTS preserves existing tables; reconcile remote history before deployment.

-- Source: setup_users.sql
-- Tạo bảng users trong public schema
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  email TEXT NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  level INTEGER DEFAULT 1,
  total_xp INTEGER DEFAULT 0,
  current_level_xp INTEGER DEFAULT 0,
  current_title TEXT DEFAULT 'Tân Binh',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  last_active_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  onboarding_completed BOOLEAN DEFAULT FALSE,
  locale TEXT DEFAULT 'vi'
);

-- Khóa Row Level Security (RLS) để chỉ user mới đọc/sửa được data của chính họ
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policy: User có quyền xem info của mình
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT 
USING (auth.uid() = id);

-- Policy: Chỉ Edge Function hoặc User có quyền sửa data của mình
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE 
USING (auth.uid() = id);

-- Policy: Insert khi đăng ký mới (Trigger thực hiện việc này nên có thể bỏ qua insert policy của client)
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Trigger function để tự động tạo user trong public.users khi có user đăng ký vào auth.users (Tùy chọn nâng cao)
-- CREATE OR REPLACE FUNCTION public.handle_new_user() 
-- RETURNS TRIGGER AS $$
-- BEGIN
--   INSERT INTO public.users (id, email)
--   VALUES (new.id, new.email);
--   RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Source: setup_profiles.sql
-- ==============================================================================
-- 1. BỔ SUNG TRƯỜNG MỚI VÀO BẢNG PUBLIC.USERS (Hỗ trợ Gamification & System)
-- ==============================================================================

-- Bổ sung các trường Gamification (Level System) và Onboarding status
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS current_title TEXT DEFAULT 'Tân Sinh Phấn Tạ',
ADD COLUMN IF NOT EXISTS is_capped BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS overflow_xp INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_workout_date TIMESTAMP WITH TIME ZONE;

-- ==============================================================================
-- 2. TẠO BẢNG PUBLIC.PROFILES (Lưu trữ Sinh trắc học & Thông số Onboarding)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES public.users(id) ON DELETE CASCADE PRIMARY KEY,
  environment TEXT NOT NULL,         -- 'gym', 'home', 'calisthenics'
  goals TEXT[] NOT NULL,             -- Mảng các mục tiêu: 'fat_loss', 'hypertrophy'...
  class_name TEXT NOT NULL,          -- 'Iron Warrior', 'Fat Slayer', 'Monk'...
  experience_level TEXT NOT NULL,    -- 'beginner', 'intermediate', 'advanced'
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,              -- 'male', 'female', 'other'
  height_cm DECIMAL NOT NULL,
  weight_kg DECIMAL NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 3. CẤU HÌNH ROW LEVEL SECURITY (RLS) CHO PROFILES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Mỗi User chỉ được xem Profile của chính mình
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT 
USING (auth.uid() = id);

-- Mỗi User chỉ được tạo Profile (Insert) cho chính ID của mình
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Mỗi User chỉ được cập nhật Profile của chính mình
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- Hàm tự động thay đổi updated_at khi update (Trigger)
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = now(); 
   RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_profiles_modtime ON public.profiles;
DROP TRIGGER IF EXISTS update_profiles_modtime ON public.profiles;
CREATE TRIGGER update_profiles_modtime
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Hoàn tất!

-- Source: setup_exercises.sql
-- ==============================================================================
-- 1. TẠO BẢNG PUBLIC.EXERCISES (Danh sách bài tập chuẩn)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT NOT NULL,         -- 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'
  equipment TEXT NOT NULL,        -- 'Barbell', 'Dumbbell', 'Machine', 'Bodyweight', 'Cables'
  force_type TEXT,                -- 'Push', 'Pull', 'Static'
  mechanic TEXT,                  -- 'Compound', 'Isolation'
  instructions TEXT[] DEFAULT '{}',
  image_url TEXT,                 -- URL đến ảnh/GIF minh họa
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 2. CẤU HÌNH ROW LEVEL SECURITY (RLS)
-- ==============================================================================

ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

-- Mọi User đã đăng nhập đều có quyền xem bài tập
DROP POLICY IF EXISTS "Anyone can view exercises" ON public.exercises;
CREATE POLICY "Anyone can view exercises" ON public.exercises FOR SELECT 
USING (auth.role() = 'authenticated');

-- Chỉ Admin (Service Role) mới có quyền chỉnh sửa (Mặc định client không được sửa)
-- Chúng ta không tạo policy INSERT/UPDATE/DELETE cho authenticated để đảm bảo data chuẩn

-- ==============================================================================
-- 3. TRIGGER CẬP NHẬT UPDATED_AT
-- ==============================================================================

CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = now(); 
   RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_exercises_modtime ON public.exercises;
DROP TRIGGER IF EXISTS update_exercises_modtime ON public.exercises;
CREATE TRIGGER update_exercises_modtime
BEFORE UPDATE ON public.exercises
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Source: setup_workouts.sql
-- ==============================================================================
-- PHASE 2.2: WORKOUT LOGGING SCHEMA
-- ==============================================================================

-- ==============================================================================
-- 1. TẠO BẢNG PUBLIC.WORKOUTS (Buổi tập của User)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.workouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  duration_seconds INTEGER DEFAULT 0,
  notes TEXT,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 2. TẠO BẢNG PUBLIC.WORKOUT_EXERCISES (Bài tập trong buổi tập)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.workout_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_id UUID REFERENCES public.workouts(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 3. TẠO BẢNG PUBLIC.WORKOUT_SETS (Sets trong một bài tập)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.workout_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_exercise_id UUID REFERENCES public.workout_exercises(id) ON DELETE CASCADE NOT NULL,
  set_number INTEGER NOT NULL DEFAULT 1,
  reps INTEGER NOT NULL DEFAULT 0,
  weight_kg DECIMAL NOT NULL DEFAULT 0,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  rest_seconds INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 4. ROW LEVEL SECURITY (RLS) — WORKOUTS
-- ==============================================================================

ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own workouts" ON public.workouts;
CREATE POLICY "Users can view own workouts" ON public.workouts FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own workouts" ON public.workouts;
CREATE POLICY "Users can insert own workouts" ON public.workouts FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own workouts" ON public.workouts;
CREATE POLICY "Users can update own workouts" ON public.workouts FOR UPDATE
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own workouts" ON public.workouts;
CREATE POLICY "Users can delete own workouts" ON public.workouts FOR DELETE
USING (auth.uid() = user_id);

-- ==============================================================================
-- 5. ROW LEVEL SECURITY (RLS) — WORKOUT_EXERCISES
-- ==============================================================================

ALTER TABLE public.workout_exercises ENABLE ROW LEVEL SECURITY;

-- User chỉ thao tác được với exercises thuộc workout của chính mình
DROP POLICY IF EXISTS "Users can view own workout_exercises" ON public.workout_exercises;
CREATE POLICY "Users can view own workout_exercises" ON public.workout_exercises FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.workouts w
    WHERE w.id = workout_id AND w.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can insert own workout_exercises" ON public.workout_exercises;
CREATE POLICY "Users can insert own workout_exercises" ON public.workout_exercises FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.workouts w
    WHERE w.id = workout_id AND w.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can update own workout_exercises" ON public.workout_exercises;
CREATE POLICY "Users can update own workout_exercises" ON public.workout_exercises FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.workouts w
    WHERE w.id = workout_id AND w.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can delete own workout_exercises" ON public.workout_exercises;
CREATE POLICY "Users can delete own workout_exercises" ON public.workout_exercises FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.workouts w
    WHERE w.id = workout_id AND w.user_id = auth.uid()
  )
);

-- ==============================================================================
-- 6. ROW LEVEL SECURITY (RLS) — WORKOUT_SETS
-- ==============================================================================

ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;

-- User chỉ thao tác được với sets thuộc workout_exercise → workout của chính mình
DROP POLICY IF EXISTS "Users can view own workout_sets" ON public.workout_sets;
CREATE POLICY "Users can view own workout_sets" ON public.workout_sets FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE we.id = workout_exercise_id AND w.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can insert own workout_sets" ON public.workout_sets;
CREATE POLICY "Users can insert own workout_sets" ON public.workout_sets FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE we.id = workout_exercise_id AND w.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can update own workout_sets" ON public.workout_sets;
CREATE POLICY "Users can update own workout_sets" ON public.workout_sets FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE we.id = workout_exercise_id AND w.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can delete own workout_sets" ON public.workout_sets;
CREATE POLICY "Users can delete own workout_sets" ON public.workout_sets FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE we.id = workout_exercise_id AND w.user_id = auth.uid()
  )
);

-- ==============================================================================
-- 7. TRIGGER CẬP NHẬT UPDATED_AT CHO WORKOUTS
-- ==============================================================================

DROP TRIGGER IF EXISTS update_workouts_modtime ON public.workouts;
DROP TRIGGER IF EXISTS update_workouts_modtime ON public.workouts;
CREATE TRIGGER update_workouts_modtime
BEFORE UPDATE ON public.workouts
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- ==============================================================================
-- 8. INDEXES CHO PERFORMANCE
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON public.workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_workouts_status ON public.workouts(status);
CREATE INDEX IF NOT EXISTS idx_workouts_user_status ON public.workouts(user_id, status);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout_id ON public.workout_exercises(workout_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_workout_exercise_id ON public.workout_sets(workout_exercise_id);

-- Hoàn tất Phase 2.2 Schema!

-- Source: setup_progression.sql
-- ==============================================================================
-- PHASE 2.3: PROGRESSION & GAMIFICATION SCHEMA
-- ==============================================================================

-- 1. Thêm cờ chống nhận nhiều lần XP vào bảng workouts
ALTER TABLE public.workouts ADD COLUMN IF NOT EXISTS is_xp_calculated BOOLEAN DEFAULT FALSE;

-- ==============================================================================
-- 2. TẠO BẢNG PUBLIC.XP_LOGS (Lịch sử XP)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.xp_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  amount INTEGER NOT NULL,
  source TEXT NOT NULL, -- Vd: 'workout', 'quest', 'streak_bonus'
  source_id TEXT,       -- ID của workout hoặc quest tương ứng
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS: User chỉ xem được xp logs của mình. Việc Insert/Update sẽ do Edge Function (với Service Role) thực hiện để chống cheat.
ALTER TABLE public.xp_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own xp logs" ON public.xp_logs;
CREATE POLICY "Users can view own xp logs" ON public.xp_logs FOR SELECT
USING (auth.uid() = user_id);

-- INDEXES cho performance
CREATE INDEX IF NOT EXISTS idx_xp_logs_user_id ON public.xp_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_logs_created_at ON public.xp_logs(created_at);

-- Hoàn tất Phase 2.3 Schema!

-- Source: setup_quests_streaks_v3.sql
-- ==============================================================================
-- PHASE 2.5 & 2.6: QUESTS, STREAKS & PERSONAL RECORDS (PRs)
-- ==============================================================================

-- 1. Cập nhật bảng profiles để lưu lịch tập mong muốn
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS weekly_gym_days INTEGER DEFAULT 3,
ADD COLUMN IF NOT EXISTS weekly_home_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS preferred_days JSONB DEFAULT '[]'::jsonb; -- Vd: ["Mon", "Wed", "Fri"]

-- 2. Tạo bảng Streaks (Chuỗi ngày tập luyện)
CREATE TABLE IF NOT EXISTS public.streaks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_activity_date DATE,
  streak_freeze_count INTEGER DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Tạo bảng Exercise PRs (Kỷ lục cá nhân & Khám phá mức tạ)
CREATE TABLE IF NOT EXISTS public.exercise_prs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE NOT NULL,
  max_weight_kg DECIMAL NOT NULL DEFAULT 0,
  max_reps INTEGER DEFAULT 0,
  estimated_1rm DECIMAL DEFAULT 0,
  is_confirmed BOOLEAN DEFAULT FALSE, -- FALSE: System suggested, TRUE: User verified
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, exercise_id)
);

-- 4. Tạo bảng Quests (Templates cho lộ trình tập)
CREATE TABLE IF NOT EXISTS public.quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL, -- 'daily_routine', 'weekly_challenge', 'main_story'
  difficulty TEXT DEFAULT 'beginner', -- 'beginner', 'intermediate', 'advanced'
  category TEXT, -- 'push', 'pull', 'legs', 'full_body', 'cardio'
  base_xp INTEGER DEFAULT 100,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Tạo bảng Quest Instances (Nhiệm vụ cụ thể cho User hàng ngày)
CREATE TABLE IF NOT EXISTS public.quest_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  quest_id UUID REFERENCES public.quests(id) ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'active', -- 'active', 'completed', 'failed', 'expired'
  
  -- Cấu hình bài tập đề xuất (JSONB)
  -- Cấu trúc dự kiến: [{"exercise_id": "...", "sets": 3, "reps": 10, "weight_kg": 25.5}]
  prescribed_config JSONB NOT NULL DEFAULT '[]'::jsonb,
  
  earned_xp INTEGER DEFAULT 0,
  is_main_routine BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- ==============================================================================
-- CẤU HÌNH ROW LEVEL SECURITY (RLS)
-- ==============================================================================

ALTER TABLE public.streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_prs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quest_instances ENABLE ROW LEVEL SECURITY;

-- Streaks
DROP POLICY IF EXISTS "Users can view own streak" ON public.streaks;
CREATE POLICY "Users can view own streak" ON public.streaks FOR SELECT USING (auth.uid() = user_id);

-- PRs
DROP POLICY IF EXISTS "Users can view own PRs" ON public.exercise_prs;
CREATE POLICY "Users can view own PRs" ON public.exercise_prs FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own PRs" ON public.exercise_prs;
CREATE POLICY "Users can insert own PRs" ON public.exercise_prs FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own PRs" ON public.exercise_prs;
CREATE POLICY "Users can update own PRs" ON public.exercise_prs FOR UPDATE USING (auth.uid() = user_id);

-- Quest Instances
DROP POLICY IF EXISTS "Users can view own quests" ON public.quest_instances;
CREATE POLICY "Users can view own quests" ON public.quest_instances FOR SELECT USING (auth.uid() = user_id);

-- Indexes cho performance
CREATE INDEX IF NOT EXISTS idx_quest_instances_user_id_status ON public.quest_instances(user_id, status);
CREATE INDEX IF NOT EXISTS idx_exercise_prs_user_exercise ON public.exercise_prs(user_id, exercise_id);

-- Trigger cập nhật updated_at cho các bảng
DROP TRIGGER IF EXISTS update_streaks_modtime ON public.streaks;
CREATE TRIGGER update_streaks_modtime BEFORE UPDATE ON public.streaks FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
DROP TRIGGER IF EXISTS update_exercise_prs_modtime ON public.exercise_prs;
CREATE TRIGGER update_exercise_prs_modtime BEFORE UPDATE ON public.exercise_prs FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Source: setup_multi_class.sql
-- ==============================================================================
-- PHASE 2.8: MULTI-CLASS EVOLUTION SCHEMA
-- ==============================================================================
-- Tài liệu tham chiếu: docs/CLASS_SYSTEM_SPEC.md
-- Triển khai hệ thống Đa Phân Lớp RPG (Multi-Class)
-- ==============================================================================

-- ==============================================================================
-- 1. TẠO BẢNG PUBLIC.USER_CLASSES (Lớp hoạt động của người dùng)
-- ==============================================================================
-- Mỗi user có tối đa 2 active classes (primary + secondary)
-- Tách ra bảng riêng thay vì JSONB column để dễ query, index, và mở rộng

CREATE TABLE IF NOT EXISTS public.user_classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  class_id TEXT NOT NULL,              -- 'A' (Fat Slayer), 'B' (Recomp Ghost), etc.
  class_name TEXT NOT NULL,            -- Tên hiển thị đầy đủ
  slot TEXT NOT NULL DEFAULT 'primary' CHECK (slot IN ('primary', 'secondary')),
  difficulty TEXT NOT NULL DEFAULT 'easy' CHECK (difficulty IN ('easy', 'medium', 'hard', 'hardcore')),
  current_xp INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 1,
  is_graduated BOOLEAN NOT NULL DEFAULT FALSE,
  graduated_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,

  -- Ràng buộc: Mỗi user chỉ có 1 primary + 1 secondary
  CONSTRAINT unique_user_class_slot UNIQUE (user_id, slot),
  -- Ràng buộc: Mỗi user không thể chọn cùng 1 class cho 2 slot
  CONSTRAINT unique_user_class_id UNIQUE (user_id, class_id)
);

-- ==============================================================================
-- 2. BỔ SUNG TRƯỜNG LỊCH TẬP CHI TIẾT VÀO BẢNG PROFILES
-- ==============================================================================
-- Thêm các trường hỗ trợ Onboarding Schedule v2

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS weekly_gym_days INTEGER DEFAULT 3,
ADD COLUMN IF NOT EXISTS weekly_home_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS preferred_training_days TEXT[] DEFAULT '{}';

-- ==============================================================================
-- 3. BẢNG CLASS METADATA (Chuẩn hóa dữ liệu Class — Lookup Table)
-- ==============================================================================
-- Bảng lookup để frontend/backend query thông tin Class mà không cần hardcode

CREATE TABLE IF NOT EXISTS public.class_definitions (
  class_id TEXT PRIMARY KEY,          -- 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'
  class_name TEXT NOT NULL,
  focus TEXT NOT NULL,                -- 'Đa dạng, Cardio, Pace' 
  difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard', 'hardcore')),
  graduation_xp INTEGER NOT NULL,     -- XP cần tích lũy để tốt nghiệp (Lv 20)
  xp_base INTEGER NOT NULL,           -- Base parameter cho công thức XP
  xp_slope DECIMAL NOT NULL,          -- Slope parameter cho công thức XP
  icon_emoji TEXT DEFAULT '⚔️',
  color_hex TEXT DEFAULT '#00E5FF'     -- Màu sắc đại diện cho class
);

-- Seed dữ liệu Class Definitions theo đặc tả CLASS_SYSTEM_SPEC.md
INSERT INTO public.class_definitions (class_id, class_name, focus, difficulty, graduation_xp, xp_base, xp_slope, icon_emoji, color_hex) VALUES
  ('A', 'Fat Slayer',       'Đa dạng, Cardio, Pace',        'easy',     6000,  80, 1.40, '⚡', '#FF6D00'),
  ('B', 'Recomp Ghost',     'Variety + Volume',              'medium',   8500, 100, 1.45, '👻', '#7C4DFF'),
  ('C', 'Mass Architect',   'Volume, Reps (8-12)',           'hard',    11000, 130, 1.55, '🏗️', '#00E676'),
  ('D', 'Titan Strength',   'Trọng lượng (Weight)',          'hard',    12000, 130, 1.55, '🛡️', '#FF1744'),
  ('E', 'Nitro Athlete',    'Tốc độ, Bộc phát',             'medium',   9000, 100, 1.45, '🏃', '#00E5FF'),
  ('F', 'Enduro Guard',     'Số hiệp cao, Nghỉ ngắn',       'easy',     7000,  80, 1.40, '🔋', '#76FF03'),
  ('G', 'Gravity Defier',   'Kỹ thuật Bodyweight',           'medium',   9000, 100, 1.45, '🧘', '#E040FB'),
  ('H', 'Apex Competitor',  'Tỉ lệ, Đối xứng, Khắt khe',   'hardcore', 15000, 160, 1.65, '👑', '#FFD600')
ON CONFLICT (class_id) DO NOTHING;

-- ==============================================================================
-- 4. BẢNG SYNERGY MATRIX (Ma Trận Tương Thích)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.class_synergies (
  primary_class_id TEXT REFERENCES public.class_definitions(class_id) NOT NULL,
  secondary_class_id TEXT REFERENCES public.class_definitions(class_id) NOT NULL,
  synergy_name TEXT NOT NULL,          -- 'The Shredder', 'Juggernaut', etc.
  bonus_percent INTEGER DEFAULT 5,     -- Bonus XP khi là cặp hoàn hảo
  is_perfect BOOLEAN DEFAULT FALSE,    -- Cặp đôi hoàn hảo (Perfect Synergy)
  PRIMARY KEY (primary_class_id, secondary_class_id)
);

-- Seed dữ liệu Synergy theo CLASS_SYSTEM_SPEC.md
INSERT INTO public.class_synergies (primary_class_id, secondary_class_id, synergy_name, bonus_percent, is_perfect) VALUES
  -- Perfect Synergy Pairs
  ('A', 'B', 'The Shredder',     5, TRUE),
  ('B', 'A', 'The Shredder',     5, TRUE),
  ('C', 'D', 'Juggernaut',       5, TRUE),
  ('D', 'C', 'Juggernaut',       5, TRUE),
  ('G', 'D', 'Cyber Monk',       5, TRUE),
  ('D', 'G', 'Cyber Monk',       5, TRUE),
  ('E', 'F', 'First Responder',  5, TRUE),
  ('F', 'E', 'First Responder',  5, TRUE),
  -- Recommended Pairs (non-perfect)
  ('A', 'C', 'Lean Machine',     3, FALSE),
  ('C', 'F', 'Volume Lord',      3, FALSE),
  ('C', 'B', 'Balanced Builder', 3, FALSE),
  ('B', 'C', 'Balanced Builder', 3, FALSE)
ON CONFLICT (primary_class_id, secondary_class_id) DO NOTHING;

-- ==============================================================================
-- 5. THÊM TRƯỜNG XP CLASS VÀO XP_LOGS (Tracking XP theo class)
-- ==============================================================================

ALTER TABLE public.xp_logs
ADD COLUMN IF NOT EXISTS class_id TEXT,
ADD COLUMN IF NOT EXISTS class_xp_earned INTEGER DEFAULT 0;

-- ==============================================================================
-- 6. ROW LEVEL SECURITY (RLS) CHO CÁC BẢNG MỚI
-- ==============================================================================

-- USER_CLASSES
ALTER TABLE public.user_classes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own classes" ON public.user_classes;
CREATE POLICY "Users can view own classes" ON public.user_classes FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own classes" ON public.user_classes;
CREATE POLICY "Users can insert own classes" ON public.user_classes FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own classes" ON public.user_classes;
CREATE POLICY "Users can update own classes" ON public.user_classes FOR UPDATE
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own classes" ON public.user_classes;
CREATE POLICY "Users can delete own classes" ON public.user_classes FOR DELETE
USING (auth.uid() = user_id);

-- CLASS_DEFINITIONS (Public read)
ALTER TABLE public.class_definitions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view class definitions" ON public.class_definitions;
CREATE POLICY "Anyone can view class definitions" ON public.class_definitions FOR SELECT
USING (true);

-- CLASS_SYNERGIES (Public read)
ALTER TABLE public.class_synergies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view synergies" ON public.class_synergies;
CREATE POLICY "Anyone can view synergies" ON public.class_synergies FOR SELECT
USING (true);

-- ==============================================================================
-- 7. INDEXES CHO PERFORMANCE
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_user_classes_user_id ON public.user_classes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_classes_class_id ON public.user_classes(class_id);
CREATE INDEX IF NOT EXISTS idx_xp_logs_class_id ON public.xp_logs(class_id);

-- ==============================================================================
-- 8. TRIGGER CẬP NHẬT UPDATED_AT CHO USER_CLASSES
-- ==============================================================================

DROP TRIGGER IF EXISTS update_user_classes_modtime ON public.user_classes;
DROP TRIGGER IF EXISTS update_user_classes_modtime ON public.user_classes;
CREATE TRIGGER update_user_classes_modtime
BEFORE UPDATE ON public.user_classes
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Hoàn tất Phase 2.8 Schema!

-- Source: migrations/add_baseline_weight.sql
-- Cập nhật bảng workout_sets thêm trường baseline_weight_kg để phục vụ cơ chế Overload
ALTER TABLE public.workout_sets
ADD COLUMN IF NOT EXISTS baseline_weight_kg DECIMAL DEFAULT 0;

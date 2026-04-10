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
CREATE POLICY "Users can view own streak" ON public.streaks FOR SELECT USING (auth.uid() = user_id);

-- PRs
CREATE POLICY "Users can view own PRs" ON public.exercise_prs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own PRs" ON public.exercise_prs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own PRs" ON public.exercise_prs FOR UPDATE USING (auth.uid() = user_id);

-- Quest Instances
CREATE POLICY "Users can view own quests" ON public.quest_instances FOR SELECT USING (auth.uid() = user_id);

-- Indexes cho performance
CREATE INDEX IF NOT EXISTS idx_quest_instances_user_id_status ON public.quest_instances(user_id, status);
CREATE INDEX IF NOT EXISTS idx_exercise_prs_user_exercise ON public.exercise_prs(user_id, exercise_id);

-- Trigger cập nhật updated_at cho các bảng
CREATE TRIGGER update_streaks_modtime BEFORE UPDATE ON public.streaks FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_exercise_prs_modtime BEFORE UPDATE ON public.exercise_prs FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

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
CREATE POLICY "Users can view own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

-- Mỗi User chỉ được tạo Profile (Insert) cho chính ID của mình
CREATE POLICY "Users can insert own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Mỗi User chỉ được cập nhật Profile của chính mình
CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE 
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
CREATE TRIGGER update_profiles_modtime
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Hoàn tất!

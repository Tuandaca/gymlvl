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
CREATE POLICY "Anyone can view exercises" 
ON public.exercises FOR SELECT 
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
CREATE TRIGGER update_exercises_modtime
BEFORE UPDATE ON public.exercises
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

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
CREATE POLICY "Users can view own profile" 
ON public.users FOR SELECT 
USING (auth.uid() = id);

-- Policy: Chỉ Edge Function hoặc User có quyền sửa data của mình
CREATE POLICY "Users can update own profile" 
ON public.users FOR UPDATE 
USING (auth.uid() = id);

-- Policy: Insert khi đăng ký mới (Trigger thực hiện việc này nên có thể bỏ qua insert policy của client)
CREATE POLICY "Users can insert own profile" 
ON public.users FOR INSERT 
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

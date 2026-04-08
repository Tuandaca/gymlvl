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

CREATE POLICY "Users can view own xp logs"
ON public.xp_logs FOR SELECT
USING (auth.uid() = user_id);

-- INDEXES cho performance
CREATE INDEX IF NOT EXISTS idx_xp_logs_user_id ON public.xp_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_logs_created_at ON public.xp_logs(created_at);

-- Hoàn tất Phase 2.3 Schema!

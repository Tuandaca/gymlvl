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

CREATE POLICY "Users can view own classes"
ON public.user_classes FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own classes"
ON public.user_classes FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own classes"
ON public.user_classes FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own classes"
ON public.user_classes FOR DELETE
USING (auth.uid() = user_id);

-- CLASS_DEFINITIONS (Public read)
ALTER TABLE public.class_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view class definitions"
ON public.class_definitions FOR SELECT
USING (true);

-- CLASS_SYNERGIES (Public read)
ALTER TABLE public.class_synergies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view synergies"
ON public.class_synergies FOR SELECT
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
CREATE TRIGGER update_user_classes_modtime
BEFORE UPDATE ON public.user_classes
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Hoàn tất Phase 2.8 Schema!

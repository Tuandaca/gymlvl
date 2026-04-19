-- Cập nhật bảng workout_sets thêm trường baseline_weight_kg để phục vụ cơ chế Overload
ALTER TABLE public.workout_sets
ADD COLUMN IF NOT EXISTS baseline_weight_kg DECIMAL DEFAULT 0;

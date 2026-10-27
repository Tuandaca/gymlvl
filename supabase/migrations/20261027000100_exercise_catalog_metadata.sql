-- Additive Database Migration: Exercise Catalog Metadata & Workout Set Duration
-- Milestone M3: Catalog Schema Expansion & Duration Support
-- Safe, additive migration preserving all existing user records and history.

-- 1. Extend public.exercises schema with rich bilingual metadata and movement categorization
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS slug text;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS name_vi text NOT NULL DEFAULT '';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS name_en text NOT NULL DEFAULT '';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS secondary_muscles text[] DEFAULT '{}';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS movement_pattern text;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS difficulty text;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS form_cues text[] DEFAULT '{}';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS common_mistakes text[] DEFAULT '{}';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS alternative_exercise_slugs text[] DEFAULT '{}';

-- 2. Ensure slug uniqueness
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'exercises_slug_key'
  ) THEN
    ALTER TABLE public.exercises ADD CONSTRAINT exercises_slug_key UNIQUE (slug);
  END IF;
END $$;

-- 3. Add validation constraints on movement patterns and difficulty
ALTER TABLE public.exercises DROP CONSTRAINT IF EXISTS exercises_valid_movement_pattern;
ALTER TABLE public.exercises ADD CONSTRAINT exercises_valid_movement_pattern CHECK (
  movement_pattern IS NULL OR movement_pattern IN ('push', 'pull', 'squat', 'hinge', 'carry', 'lunge', 'isolation')
) NOT VALID;

ALTER TABLE public.exercises DROP CONSTRAINT IF EXISTS exercises_valid_difficulty;
ALTER TABLE public.exercises ADD CONSTRAINT exercises_valid_difficulty CHECK (
  difficulty IS NULL OR difficulty IN ('beginner', 'intermediate', 'advanced')
) NOT VALID;

-- 4. Trigger to auto-generate slug and name_en if omitted during ad-hoc inserts
CREATE OR REPLACE FUNCTION public.set_exercise_slug_default()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.slug IS NULL OR NEW.slug = '' THEN
    NEW.slug := CASE NEW.name
      WHEN 'Bench Press (Barbell)' THEN 'barbell-bench-press'
      WHEN 'Incline Bench Press (Dumbbell)' THEN 'incline-dumbbell-bench-press'
      WHEN 'Chest Fly (Machine)' THEN 'machine-chest-fly'
      WHEN 'Push-up' THEN 'push-up'
      WHEN 'Deadlift (Barbell)' THEN 'barbell-deadlift'
      WHEN 'Pull-up' THEN 'pull-up'
      WHEN 'Lat Pulldown (Cable)' THEN 'cable-lat-pulldown'
      WHEN 'Seated Cable Row' THEN 'seated-cable-row'
      WHEN 'Squat (Barbell)' THEN 'barbell-squat'
      WHEN 'Leg Press' THEN 'leg-press'
      WHEN 'Leg Extension' THEN 'leg-extension'
      WHEN 'Lying Leg Curl' THEN 'lying-leg-curl'
      WHEN 'Overhead Press (Barbell)' THEN 'barbell-overhead-press'
      WHEN 'Lateral Raise (Dumbbell)' THEN 'dumbbell-lateral-raise'
      WHEN 'Face Pull (Cable)' THEN 'cable-face-pull'
      WHEN 'Bicep Curl (Barbell)' THEN 'barbell-bicep-curl'
      WHEN 'Hammer Curl (Dumbbell)' THEN 'dumbbell-hammer-curl'
      WHEN 'Tricep Pushdown (Cable)' THEN 'cable-tricep-pushdown'
      WHEN 'Skull Crusher (Barbell)' THEN 'barbell-skull-crusher'
      WHEN 'Plank' THEN 'plank'
      WHEN 'Crunch' THEN 'crunch'
      WHEN 'Leg Raise' THEN 'leg-raise'
      ELSE lower(regexp_replace(regexp_replace(NEW.name, '[^a-zA-Z0-9]+', '-', 'g'), '^-+|-+$', '', 'g'))
    END;
  END IF;
  IF NEW.name_en IS NULL OR NEW.name_en = '' THEN
    NEW.name_en := NEW.name;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_set_exercise_slug ON public.exercises;
CREATE TRIGGER trigger_set_exercise_slug
BEFORE INSERT ON public.exercises
FOR EACH ROW EXECUTE FUNCTION public.set_exercise_slug_default();

-- 5. Backfill existing 22 exercises with slugs, Vietnamese names, and movement patterns
UPDATE public.exercises SET
  slug = 'barbell-bench-press',
  name_en = 'Barbell Bench Press',
  name_vi = 'Đẩy Ngực Ngang Với Tạ Đòn',
  movement_pattern = 'push',
  difficulty = 'intermediate',
  secondary_muscles = ARRAY['Triceps', 'Anterior Deltoids'],
  form_cues = ARRAY['Giữ 5 điểm tiếp xúc: đầu, vai, mông, hai bàn chân', 'Ưỡn ngực, thu hai xương bả vai về sau', 'Hạ thanh đòn chạm nhẹ phần ngực dưới', 'Đẩy thanh đòn theo đường cong nhẹ lên trên'],
  common_mistakes = ARRAY['Khóa khớp khuỷu tay quá mạnh ở đỉnh', 'Nhấc mông khỏi ghế khi đẩy nặng', 'Khuỷu tay bẹt 90 độ gây áp lực vai'],
  alternative_exercise_slugs = ARRAY['dumbbell-bench-press', 'incline-dumbbell-bench-press', 'push-up']
WHERE name = 'Bench Press (Barbell)' AND (slug IS NULL OR slug = 'barbell-bench-press');

UPDATE public.exercises SET
  slug = 'incline-dumbbell-bench-press',
  name_en = 'Incline Dumbbell Bench Press',
  name_vi = 'Đẩy Ngực Trên Với Tạ Đơn',
  movement_pattern = 'push',
  difficulty = 'intermediate',
  secondary_muscles = ARRAY['Anterior Deltoids', 'Triceps'],
  form_cues = ARRAY['Chỉnh ghế dốc 30-45 độ', 'Hạ tạ có kiểm soát ngang tầm ngực trên', 'Ép ngực vào nhau ở đỉnh chuyển động'],
  common_mistakes = ARRAY['Độ dốc quá cao (>45 độ) chuyển lực sang vai', 'Tạ đập vào nhau ở đỉnh gây mất thăng bằng'],
  alternative_exercise_slugs = ARRAY['incline-barbell-bench-press', 'barbell-bench-press']
WHERE name = 'Incline Bench Press (Dumbbell)' AND (slug IS NULL OR slug = 'incline-dumbbell-bench-press');

UPDATE public.exercises SET
  slug = 'machine-chest-fly',
  name_en = 'Machine Chest Fly',
  name_vi = 'Ép Ngực Với Máy Pec Deck',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Anterior Deltoids'],
  form_cues = ARRAY['Điều chỉnh ghế để tay cầm ngang ngực', 'Khuỷu tay hơi cong cố định góc', 'Tập trung ép hai cùi chỏ lại gần nhau'],
  common_mistakes = ARRAY['Duỗi thẳng hoặc gập khuỷu tay quá nhiều khi kéo', 'Đưa tay quá sâu về sau gây áp lực khớp vai'],
  alternative_exercise_slugs = ARRAY['cable-crossover-high-to-low', 'flat-dumbbell-fly']
WHERE name = 'Chest Fly (Machine)' AND (slug IS NULL OR slug = 'machine-chest-fly');

UPDATE public.exercises SET
  slug = 'push-up',
  name_en = 'Push-up',
  name_vi = 'Hít Đất Cổ Điển',
  movement_pattern = 'push',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Triceps', 'Anterior Deltoids', 'Core'],
  form_cues = ARRAY['Giữ cơ thể thẳng từ đầu đến gót chân', 'Gồng chặt cơ bụng và cơ mông', 'Khuỷu tay tạo góc 45 độ so với thân người', 'Ngực chạm nhẹ sàn rồi đẩy dứt khoát'],
  common_mistakes = ARRAY['Võng lưng hoặc nhô mông lên cao', 'Cúi đầu nhìn chân', 'Biên độ không hết'],
  alternative_exercise_slugs = ARRAY['barbell-bench-press', 'incline-push-up', 'diamond-push-up']
WHERE name = 'Push-up' AND (slug IS NULL OR slug = 'push-up');

UPDATE public.exercises SET
  slug = 'barbell-deadlift',
  name_en = 'Barbell Deadlift',
  name_vi = 'Kéo Tạ Đòn (Deadlift)',
  movement_pattern = 'hinge',
  difficulty = 'advanced',
  secondary_muscles = ARRAY['Hamstrings', 'Glutes', 'Core', 'Forearms', 'Traps'],
  form_cues = ARRAY['Thanh đòn đặt trên giữa bàn chân', 'Khóa lưng thẳng, kéo vai về sau', 'Đẩy sàn bằng gót chân, nâng tạ thẳng đứng bám sát cẳng chân', 'Khóa hông ở đỉnh không ngả lưng quá mức'],
  common_mistakes = ARRAY['Gù lưng khi nâng tạ', 'Kéo tạ rời xa cẳng chân', 'Giật tạ đột ngột thay vì tạo lực căng trước'],
  alternative_exercise_slugs = ARRAY['romanian-deadlift', 'trap-bar-deadlift']
WHERE name = 'Deadlift (Barbell)' AND (slug IS NULL OR slug = 'barbell-deadlift');

UPDATE public.exercises SET
  slug = 'pull-up',
  name_en = 'Pull-up',
  name_vi = 'Hít Xà Đơn',
  movement_pattern = 'pull',
  difficulty = 'intermediate',
  secondary_muscles = ARRAY['Biceps', 'Rhomboids', 'Rear Deltoids', 'Core'],
  form_cues = ARRAY['Cầm xà rộng hơn vai một chút', 'Kéo xương bả vai xuống trước khi gập tay', 'Kéo ngực hướng về phía thanh xà đến khi cằm qua xà', 'Hạ người xuống có kiểm soát hết biên độ'],
  common_mistakes = ARRAY['Vung vẩy đung đưa người lấy đà (kipping)', 'Không hạ hết tay ở cuối chuyển động', 'Rụt cổ rụt vai'],
  alternative_exercise_slugs = ARRAY['chin-up', 'cable-lat-pulldown', 'inverted-row']
WHERE name = 'Pull-up' AND (slug IS NULL OR slug = 'pull-up');

UPDATE public.exercises SET
  slug = 'cable-lat-pulldown',
  name_en = 'Cable Lat Pulldown',
  name_vi = 'Kéo Xô Cáp Xuống',
  movement_pattern = 'pull',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Biceps', 'Rear Deltoids'],
  form_cues = ARRAY['Cố định đùi chặt dưới đệm đỡ', 'Ưỡn ngực, nghiêng thân người nhẹ về sau khoảng 10-15 độ', 'Kéo thanh bar chạm nhẹ ngực trên', 'Kiểm soát nhịp đi lên giãn cơ xô'],
  common_mistakes = ARRAY['Ngả người về sau quá nhiều lấy đà', 'Kéo thanh bar ra sau gáy', 'Dùng lực cánh tay thay vì cơ xô'],
  alternative_exercise_slugs = ARRAY['pull-up', 'straight-arm-cable-pulldown']
WHERE name = 'Lat Pulldown (Cable)' AND (slug IS NULL OR slug = 'cable-lat-pulldown');

UPDATE public.exercises SET
  slug = 'seated-cable-row',
  name_en = 'Seated Cable Row',
  name_vi = 'Kéo Cáp Ngồi (Chèo Cáp)',
  movement_pattern = 'pull',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Biceps', 'Rhomboids'],
  form_cues = ARRAY['Ngồi thẳng lưng, đầu gối hơi chùng nhẹ', 'Kéo tay cầm về phía rốn hoặc bụng dưới', 'Ép chặt hai bả vai vào nhau ở điểm co cơ', 'Thả tay ra từ từ không gù lưng'],
  common_mistakes = ARRAY['Đung đưa thân người về trước sau quá nhiều', 'Nhấc vai lên tai làm mỏi cơ cầu vai', 'Gập lưng dưới'],
  alternative_exercise_slugs = ARRAY['barbell-bent-over-row', 'one-arm-dumbbell-row']
WHERE name = 'Seated Cable Row' AND (slug IS NULL OR slug = 'seated-cable-row');

UPDATE public.exercises SET
  slug = 'barbell-squat',
  name_en = 'Barbell Back Squat',
  name_vi = 'Gánh Tạ Đòn (Back Squat)',
  movement_pattern = 'squat',
  difficulty = 'advanced',
  secondary_muscles = ARRAY['Glutes', 'Hamstrings', 'Calves', 'Core'],
  form_cues = ARRAY['Thanh đòn đặt chắc chắn trên cơ cầu vai/vai sau', 'Chân rộng bằng vai, mũi chân mở 15-30 độ', 'Hít sâu gồng chặt cơ bụng (Brace)', 'Hạ mông xuống cho đến khi nếp gấp hông thấp hơn đầu gối', 'Đạp đều toàn bàn chân đứng dậy'],
  common_mistakes = ARRAY['Đầu gối chụm vào nhau (Knee valgus)', 'Nhấc gót chân khỏi sàn', 'Gập thân người về trước quá nhiều'],
  alternative_exercise_slugs = ARRAY['front-squat', 'goblet-squat', 'leg-press']
WHERE name = 'Squat (Barbell)' AND (slug IS NULL OR slug = 'barbell-squat');

UPDATE public.exercises SET
  slug = 'leg-press',
  name_en = 'Leg Press',
  name_vi = 'Đạp Đùi Với Máy',
  movement_pattern = 'squat',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Glutes', 'Hamstrings'],
  form_cues = ARRAY['Lưng và mông áp sát đệm ghế', 'Đặt chân rộng bằng vai giữa bàn đạp', 'Hạ bàn đạp xuống có kiểm soát tới khi đùi tạo góc 90 độ', 'Đẩy bàn đạp ra không khóa thẳng khớp gối'],
  common_mistakes = ARRAY['Khóa thẳng khớp gối ở đỉnh chuyển động', 'Nhấc mông khỏi đệm ghế khi hạ chân sâu', 'Đặt chân quá thấp gây áp lực xương bánh chè'],
  alternative_exercise_slugs = ARRAY['barbell-squat', 'hack-squat-machine', 'goblet-squat']
WHERE name = 'Leg Press' AND (slug IS NULL OR slug = 'leg-press');

UPDATE public.exercises SET
  slug = 'leg-extension',
  name_en = 'Leg Extension',
  name_vi = 'Đá Đùi Trước Với Máy',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY[]::text[],
  form_cues = ARRAY['Khớp gối thẳng hàng với trục quay của máy', 'Đệm chân đặt ngay trên mu bàn chân/cổ chân', 'Đá thẳng chân lên có kiểm soát, giữ đỉnh 1 giây', 'Hạ xuống chậm rãi không để tạ va chạm'],
  common_mistakes = ARRAY['Văng chân lấy đà quá nhanh', 'Chỉnh trục quay máy lệch khớp gối'],
  alternative_exercise_slugs = ARRAY['sissy-squat', 'goblet-squat']
WHERE name = 'Leg Extension' AND (slug IS NULL OR slug = 'leg-extension');

UPDATE public.exercises SET
  slug = 'lying-leg-curl',
  name_en = 'Lying Leg Curl',
  name_vi = 'Nằm Cuốn Đùi Sau Với Máy',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Calves'],
  form_cues = ARRAY['Nằm sấp, đệm lăn đặt dưới bắp chân ngay trên gót', 'Giữ hông áp sát bề mặt đệm', 'Cuộn chân về phía mông hết biên độ', 'Duỗi chân từ từ có kiểm soát'],
  common_mistakes = ARRAY['Nhấc hông lên cao để mượn lực lưng dưới', 'Thả rơi tạ khi hạ chân'],
  alternative_exercise_slugs = ARRAY['seated-leg-curl', 'romanian-deadlift']
WHERE name = 'Lying Leg Curl' AND (slug IS NULL OR slug = 'lying-leg-curl');

UPDATE public.exercises SET
  slug = 'barbell-overhead-press',
  name_en = 'Barbell Overhead Press',
  name_vi = 'Đẩy Vai Đòn Đứng (OHP)',
  movement_pattern = 'push',
  difficulty = 'intermediate',
  secondary_muscles = ARRAY['Triceps', 'Upper Chest', 'Core'],
  form_cues = ARRAY['Đứng chân rộng bằng hông, gồng chặt cơ bụng và mông', 'Nắm thanh đòn rộng hơn vai một chút, cùi chỏ hướng nhẹ về trước', 'Đẩy tạ thẳng đứng lên qua đầu, khóa hông vững chắc', 'Hạ thanh đòn về lại trước xương quai xanh'],
  common_mistakes = ARRAY['Ưỡn lưng dưới quá mức để đẩy tạ', 'Nhún chân lấy đà (thành Push Press)', 'Đẩy tạ ra xa phía trước đầu'],
  alternative_exercise_slugs = ARRAY['seated-dumbbell-shoulder-press', 'seated-barbell-overhead-press']
WHERE name = 'Overhead Press (Barbell)' AND (slug IS NULL OR slug = 'barbell-overhead-press');

UPDATE public.exercises SET
  slug = 'dumbbell-lateral-raise',
  name_en = 'Dumbbell Lateral Raise',
  name_vi = 'Nâng Tạ Đơn Sang Ngang (Vai Giữa)',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Front Deltoids', 'Traps'],
  form_cues = ARRAY['Đứng thẳng hoặc hơi nghiêng người về trước nhẹ', 'Khuỷu tay hơi chùng, nâng hai cánh tay sang ngang ngang vai', 'Cổ tay không cao hơn khuỷu tay ở đỉnh', 'Hạ tạ xuống có kiểm soát'],
  common_mistakes = ARRAY['Vung tạ dùng đà thân người', 'Nhún vai (dùng cơ cầu vai thay vì vai giữa)', 'Nâng tạ cao quá vai'],
  alternative_exercise_slugs = ARRAY['cable-lateral-raise', 'band-overhead-pull-apart']
WHERE name = 'Lateral Raise (Dumbbell)' AND (slug IS NULL OR slug = 'dumbbell-lateral-raise');

UPDATE public.exercises SET
  slug = 'cable-face-pull',
  name_en = 'Cable Face Pull',
  name_vi = 'Kéo Cáp Vào Mặt (Face Pull)',
  movement_pattern = 'pull',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Rear Deltoids', 'Rotator Cuff', 'Rhomboids'],
  form_cues = ARRAY['Chỉnh ròng rọc ngang tầm mắt hoặc cao hơn nhẹ', 'Cầm dây thừng bằng ngón cái hướng về sau', 'Kéo dây về phía mắt/trán, xoay ngoài khớp vai', 'Tách hai đầu dây thừng sang hai bên ở điểm kết thúc'],
  common_mistakes = ARRAY['Kéo khuỷu tay chúc xuống dưới', 'Dùng tạ quá nặng ngửa người về sau', 'Không xoay ngoài vai'],
  alternative_exercise_slugs = ARRAY['rear-delt-dumbbell-fly', 'reverse-pec-deck-fly']
WHERE name = 'Face Pull (Cable)' AND (slug IS NULL OR slug = 'cable-face-pull');

UPDATE public.exercises SET
  slug = 'barbell-bicep-curl',
  name_en = 'Barbell Bicep Curl',
  name_vi = 'Cuốn Tay Trước Với Tạ Đòn',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Forearms'],
  form_cues = ARRAY['Đứng thẳng, cùi chỏ ép sát hai bên sườn', 'Cuộn thanh đòn lên hướng về phía ngực', 'Gồng cơ bắp tay ở đỉnh 1 giây', 'Hạ thanh đòn xuống chậm rãi có kiểm soát'],
  common_mistakes = ARRAY['Vung thân người lấy đà', 'Đưa cùi chỏ ra trước quá nhiều', 'Không duỗi hết tay khi hạ tạ'],
  alternative_exercise_slugs = ARRAY['ez-bar-bicep-curl', 'incline-dumbbell-curl']
WHERE name = 'Bicep Curl (Barbell)' AND (slug IS NULL OR slug = 'barbell-bicep-curl');

UPDATE public.exercises SET
  slug = 'dumbbell-hammer-curl',
  name_en = 'Dumbbell Hammer Curl',
  name_vi = 'Cuốn Búa Với Tạ Đơn (Hammer Curl)',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Brachialis', 'Forearms'],
  form_cues = ARRAY['Hai lòng bàn tay hướng vào nhau (Neutral grip)', 'Giữ cùi chỏ cố định sát thân người', 'Nâng tạ lên như động tác gõ búa', 'Hạ tạ chậm rãi'],
  common_mistakes = ARRAY['Vung tay và vai', 'Xoay cổ tay khi cuốn tạ'],
  alternative_exercise_slugs = ARRAY['cable-rope-hammer-curl', 'barbell-bicep-curl']
WHERE name = 'Hammer Curl (Dumbbell)' AND (slug IS NULL OR slug = 'dumbbell-hammer-curl');

UPDATE public.exercises SET
  slug = 'cable-tricep-pushdown',
  name_en = 'Cable Tricep Pushdown',
  name_vi = 'Kéo Cáp Tay Sau Xuống (Tricep Pushdown)',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY[]::text[],
  form_cues = ARRAY['Đứng thẳng hoặc hơi cúi nhẹ người về trước', 'Cùi chỏ ghim cố định hai bên sườn', 'Đẩy thanh bar/dây cáp xuống cho tới khi khóa thẳng tay sau', 'Kiểm soát đường lên tới góc 90 độ ở khuỷu tay'],
  common_mistakes = ARRAY['Để cùi chỏ di chuyển tự do ra trước sau', 'Dùng trọng lượng cơ thể đè lên thanh đòn'],
  alternative_exercise_slugs = ARRAY['barbell-skull-crusher', 'overhead-cable-tricep-extension']
WHERE name = 'Tricep Pushdown (Cable)' AND (slug IS NULL OR slug = 'cable-tricep-pushdown');

UPDATE public.exercises SET
  slug = 'barbell-skull-crusher',
  name_en = 'Barbell Skull Crusher',
  name_vi = 'Nằm Duỗi Tay Sau Với Tạ Đòn (Skull Crusher)',
  movement_pattern = 'isolation',
  difficulty = 'intermediate',
  secondary_muscles = ARRAY[]::text[],
  form_cues = ARRAY['Nằm trên ghế phẳng, cầm tạ đòn thẳng trên ngực', 'Hơi nghiêng cánh tay trên về phía sau đầu vài độ', 'Chỉ gập cẳng tay hạ tạ xuống trán hoặc đỉnh đầu', 'Đẩy tạ về lại vị trí ban đầu bằng cơ tay sau'],
  common_mistakes = ARRAY['Khuỷu tay bẹt sang hai bên quá rộng', 'Di chuyển toàn bộ cánh tay thay vì chỉ gập khuỷu'],
  alternative_exercise_slugs = ARRAY['cable-tricep-pushdown', 'overhead-cable-tricep-extension']
WHERE name = 'Skull Crusher (Barbell)' AND (slug IS NULL OR slug = 'barbell-skull-crusher');

UPDATE public.exercises SET
  slug = 'plank',
  name_en = 'Plank',
  name_vi = 'Tư Thế Tấm Ván (Plank)',
  movement_pattern = 'carry',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Shoulders', 'Glutes', 'Lower Back'],
  form_cues = ARRAY['Chống khuỷu tay thẳng dưới vai', 'Thân người tạo thành một đường thẳng từ vai đến gót', 'Gồng chặt cơ bụng và cơ mông', 'Hít thở đều đặn không nín thở'],
  common_mistakes = ARRAY['Võng lưng dưới', 'Nhô mông lên quá cao', 'Cúi gập cổ'],
  alternative_exercise_slugs = ARRAY['ab-wheel-rollout', 'side-plank']
WHERE name = 'Plank' AND (slug IS NULL OR slug = 'plank');

UPDATE public.exercises SET
  slug = 'crunch',
  name_en = 'Abdominal Crunch',
  name_vi = 'Gập Bụng Cơ Bản',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY[]::text[],
  form_cues = ARRAY['Nằm ngửa, đầu gối co, bàn chân chạm sàn', 'Hai tay đặt sau tai hoặc bắt chéo trước ngực', 'Gập cơ bụng nâng bả vai lên khỏi sàn 5-10cm', 'Ép lưng dưới xuống sàn khi cuộn bụng'],
  common_mistakes = ARRAY['Dùng tay kéo giật cổ về trước', 'Ngồi dậy toàn thân (thành Sit-up) làm mỏi cơ gấp hông'],
  alternative_exercise_slugs = ARRAY['cable-crunch', 'ab-wheel-rollout']
WHERE name = 'Crunch' AND (slug IS NULL OR slug = 'crunch');

UPDATE public.exercises SET
  slug = 'leg-raise',
  name_en = 'Lying Leg Raise',
  name_vi = 'Nằm Nâng Chân Tập Bụng Dưới',
  movement_pattern = 'isolation',
  difficulty = 'beginner',
  secondary_muscles = ARRAY['Hip Flexors'],
  form_cues = ARRAY['Nằm ngửa trên thảm, hai tay đặt dọc thân hoặc lót dưới mông', 'Ép lưng dưới sát sàn nhà', 'Nâng hai chân lên góc 80-90 độ', 'Hạ chân xuống từ từ, không để lưng dưới cong lên'],
  common_mistakes = ARRAY['Võng lưng dưới khi hạ chân gây đau thắt lưng', 'Dùng đà văng chân lên'],
  alternative_exercise_slugs = ARRAY['hanging-leg-raise', 'ab-wheel-rollout']
WHERE name = 'Leg Raise' AND (slug IS NULL OR slug = 'leg-raise');

-- 6. Clean fallback for any additional legacy exercises
UPDATE public.exercises
SET slug = lower(regexp_replace(regexp_replace(name, '[^a-zA-Z0-9]+', '-', 'g'), '^-+|-+$', '', 'g'))
WHERE slug IS NULL OR slug = '';

UPDATE public.exercises
SET name_en = name
WHERE name_en IS NULL OR name_en = '';

UPDATE public.exercises
SET name_vi = name
WHERE name_vi IS NULL OR name_vi = '';

-- 7. Add duration_seconds to workout_sets and update check constraint
ALTER TABLE public.workout_sets ADD COLUMN IF NOT EXISTS duration_seconds integer DEFAULT 0;

ALTER TABLE public.workout_sets DROP CONSTRAINT IF EXISTS workout_sets_valid_values;
ALTER TABLE public.workout_sets ADD CONSTRAINT workout_sets_valid_values CHECK (
  set_number BETWEEN 1 AND 100 AND reps BETWEEN 0 AND 1000 AND weight_kg BETWEEN 0 AND 1000
  AND rest_seconds BETWEEN 0 AND 7200 AND baseline_weight_kg BETWEEN 0 AND 1000
  AND (duration_seconds IS NULL OR duration_seconds BETWEEN 0 AND 7200)
  AND (NOT is_completed OR reps > 0 OR duration_seconds > 0)
) NOT VALID;

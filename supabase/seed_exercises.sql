-- Idempotent Curated Exercise Catalog (150 exercises)
-- Milestone M3: Full Exercise Catalog Schema & Seed Data Expansion
-- Safe, additive seed script using ON CONFLICT (slug) DO UPDATE.

DO $$
BEGIN
  -- Reconcile legacy seed.sql entries to standard slugs if they exist with null slug
  UPDATE public.exercises SET slug = 'barbell-bench-press' WHERE name = 'Bench Press (Barbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'incline-dumbbell-bench-press' WHERE name = 'Incline Bench Press (Dumbbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'machine-chest-fly' WHERE name = 'Chest Fly (Machine)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'push-up' WHERE name = 'Push-up' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'barbell-deadlift' WHERE name = 'Deadlift (Barbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'pull-up' WHERE name = 'Pull-up' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'cable-lat-pulldown' WHERE name = 'Lat Pulldown (Cable)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'seated-cable-row' WHERE name = 'Seated Cable Row' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'barbell-squat' WHERE name = 'Squat (Barbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'leg-press' WHERE name = 'Leg Press' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'leg-extension' WHERE name = 'Leg Extension' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'lying-leg-curl' WHERE name = 'Lying Leg Curl' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'barbell-overhead-press' WHERE name = 'Overhead Press (Barbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'dumbbell-lateral-raise' WHERE name = 'Lateral Raise (Dumbbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'cable-face-pull' WHERE name = 'Face Pull (Cable)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'barbell-bicep-curl' WHERE name = 'Bicep Curl (Barbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'dumbbell-hammer-curl' WHERE name = 'Hammer Curl (Dumbbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'cable-tricep-pushdown' WHERE name = 'Tricep Pushdown (Cable)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'barbell-skull-crusher' WHERE name = 'Skull Crusher (Barbell)' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'plank' WHERE name = 'Plank' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'crunch' WHERE name = 'Crunch' AND (slug IS NULL OR slug = '');
  UPDATE public.exercises SET slug = 'leg-raise' WHERE name = 'Leg Raise' AND (slug IS NULL OR slug = '');
END $$;

INSERT INTO public.exercises (
  slug, name, name_vi, name_en, category, equipment, force_type, mechanic, movement_pattern, difficulty, secondary_muscles, form_cues, common_mistakes, alternative_exercise_slugs, instructions
) VALUES
-- ==============================================================================
-- 1. CHEST (24 Exercises)
-- ==============================================================================
(
  'barbell-bench-press', 'Bench Press (Barbell)', 'Đẩy Ngực Ngang Với Tạ Đòn', 'Barbell Bench Press',
  'Chest', 'Barbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Triceps', 'Anterior Deltoids'],
  ARRAY['Giữ 5 điểm tiếp xúc: đầu, vai, mông, hai bàn chân bám chặt sàn', 'Ưỡn ngực, thu hai bả vai về sau và ghim chặt vào ghế', 'Hạ thanh đòn có kiểm soát chạm nhẹ ngực dưới', 'Đẩy thanh đòn theo quỹ đạo cong nhẹ về vị trí ngang vai'],
  ARRAY['Khóa khớp khuỷu tay quá mạnh ở đỉnh', 'Nhấc mông khỏi ghế khi đẩy nặng', 'Khuỷu tay bẹt 90 độ gây áp lực khớp vai'],
  ARRAY['dumbbell-bench-press', 'incline-dumbbell-bench-press', 'push-up'],
  ARRAY['Nằm ngửa trên ghế tập trung', 'Hạ thanh đòn xuống ngực', 'Đẩy thanh đòn lên cao']
),
(
  'incline-dumbbell-bench-press', 'Incline Bench Press (Dumbbell)', 'Đẩy Ngực Trên Với Tạ Đơn', 'Incline Dumbbell Bench Press',
  'Chest', 'Dumbbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Anterior Deltoids', 'Triceps'],
  ARRAY['Chỉnh ghế nghiêng góc 30-45 độ', 'Hạ tạ có kiểm soát ngang tầm ngực trên', 'Ép ngực vào nhau ở đỉnh chuyển động'],
  ARRAY['Góc ghế quá dốc (>45 độ) dồn lực vào vai trước', 'Tạ va chạm đập vào nhau ở đỉnh làm mất độ căng cơ'],
  ARRAY['incline-barbell-bench-press', 'barbell-bench-press'],
  ARRAY['Nằm trên ghế dốc lên 30-45 độ', 'Đẩy tạ đôi lên cao', 'Hạ tạ xuống phía trên ngực']
),
(
  'machine-chest-fly', 'Chest Fly (Machine)', 'Ép Ngực Với Máy Pec Deck', 'Machine Chest Fly',
  'Chest', 'Machine', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Anterior Deltoids'],
  ARRAY['Chỉnh ghế sao cho tay nắm ngang ngực giữa', 'Khuỷu tay hơi cong cố định góc suốt bài tập', 'Tập trung ép hai cùi chỏ lại gần nhau ở đỉnh'],
  ARRAY['Gập duỗi khuỷu tay liên tục biến thành bài đẩy', 'Mở tay quá sâu ra sau gây căng rách dây chằng vai'],
  ARRAY['cable-crossover-high-to-low', 'flat-dumbbell-fly'],
  ARRAY['Ngồi vào máy ép ngực', 'Mở rộng hai tay sang ngang', 'Ép hai tay lại gần nhau ở phía trước']
),
(
  'push-up', 'Push-up', 'Hít Đất Cổ Điển', 'Push-up',
  'Chest', 'Bodyweight', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Triceps', 'Anterior Deltoids', 'Core'],
  ARRAY['Giữ cơ thể thẳng từ đầu đến gót chân', 'Gồng chặt cơ bụng và cơ mông', 'Khuỷu tay tạo góc 45 độ so với thân người', 'Hạ ngực chạm sàn rồi đẩy dứt khoát lên'],
  ARRAY['Võng lưng dưới hoặc nhô mông lên cao', 'Cúi đầu nhìn chân làm mất đường cong tự nhiên cổ', 'Hạ nửa vời không hết biên độ'],
  ARRAY['barbell-bench-press', 'incline-push-up', 'diamond-push-up'],
  ARRAY['Tư thế plank cao', 'Hạ người xuống gần mặt đất', 'Đẩy người lên vị trí cũ']
),
(
  'incline-barbell-bench-press', 'Incline Barbell Bench Press', 'Đẩy Ngực Trên Với Tạ Đòn', 'Incline Barbell Bench Press',
  'Chest', 'Barbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Anterior Deltoids', 'Triceps'],
  ARRAY['Ghế dốc 30 độ, bả vai thu chặt', 'Hạ thanh đòn xuống xương quai xanh/ngực trên', 'Đẩy thẳng tạ lên trên có kiểm soát'],
  ARRAY['Thanh đòn rơi tự do đập vào ngực', 'Góc ghế quá cao biến thành bài đẩy vai'],
  ARRAY['incline-dumbbell-bench-press', 'smith-machine-incline-press'],
  ARRAY['Nằm ghế dốc 30 độ', 'Nắm thanh đòn rộng hơn vai', 'Hạ thanh đòn chạm ngực trên và đẩy lên']
),
(
  'decline-barbell-bench-press', 'Decline Barbell Bench Press', 'Đẩy Ngực Dưới Với Tạ Đòn', 'Decline Barbell Bench Press',
  'Chest', 'Barbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Triceps', 'Anterior Deltoids'],
  ARRAY['Cố định chân chặt vào móc đệm', 'Hạ thanh đòn chạm ngực dưới', 'Đẩy tạ dứt khoát thẳng lên'],
  ARRAY['Thả rơi tạ nhanh mất kiểm soát', 'Không khóa chân an toàn'],
  ARRAY['decline-dumbbell-bench-press', 'chest-dip'],
  ARRAY['Nằm trên ghế dốc xuống', 'Hạ thanh đòn xuống ngực dưới', 'Đẩy tạ lên dứt khoát']
),
(
  'dumbbell-bench-press', 'Flat Dumbbell Bench Press', 'Đẩy Ngực Ngang Với Tạ Đơn', 'Flat Dumbbell Bench Press',
  'Chest', 'Dumbbell', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Triceps', 'Anterior Deltoids'],
  ARRAY['Bàn chân đạp sàn vững chắc', 'Hạ tạ sâu ngang ngực cảm nhận độ căng', 'Đẩy tạ lên không để tạ va vào nhau'],
  ARRAY['Cùi chỏ bẹt 90 độ', 'Mất thăng bằng cổ tay gập ra sau'],
  ARRAY['barbell-bench-press', 'machine-chest-press'],
  ARRAY['Nằm trên ghế phẳng, hai tạ đơn ở hai bên ngực', 'Đẩy hai tạ lên trên đỉnh', 'Hạ tạ chậm rãi có kiểm soát']
),
(
  'decline-dumbbell-bench-press', 'Decline Dumbbell Bench Press', 'Đẩy Ngực Dưới Với Tạ Đơn', 'Decline Dumbbell Bench Press',
  'Chest', 'Dumbbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Triceps'],
  ARRAY['Nằm ghế dốc xuống 15-30 độ', 'Hạ tạ sâu ngang viền ngực dưới', 'Đẩy tạ hội tụ nhẹ ở đỉnh'],
  ARRAY['Cổ tay yếu không giữ thẳng tạ', 'Mất thăng bằng khi hạ tạ xuống'],
  ARRAY['decline-barbell-bench-press', 'chest-dip'],
  ARRAY['Nằm ghế dốc xuống, cố định chân', 'Đẩy tạ đơn từ ngực dưới lên', 'Hạ tạ chậm']
),
(
  'cable-crossover-high-to-low', 'Cable Crossover (High to Low)', 'Kéo Cáp Ép Ngực Từ Trên Xuống', 'Cable Crossover (High to Low)',
  'Chest', 'Cable', 'Push', 'Isolation', 'isolation', 'intermediate',
  ARRAY['Anterior Deltoids'],
  ARRAY['Ròng rọc đặt vị trí cao nhất', 'Bước một chân lên trước giữ thăng bằng', 'Kéo cáp chéo xuống phía trước hông', 'Ép chặt ngực dưới ở điểm cuối'],
  ARRAY['Dùng đà thân người đung đưa', 'Gập tay quá nhiều biến thành ép cơ tay sau'],
  ARRAY['machine-chest-fly', 'cable-crossover-low-to-high'],
  ARRAY['Cáp đặt vị trí cao', 'Kéo chéo tay về phía dưới trước người', 'Giữ căng ngực 1 giây và thả về']
),
(
  'cable-crossover-low-to-high', 'Cable Crossover (Low to High)', 'Kéo Cáp Ép Ngực Từ Dưới Lên', 'Cable Crossover (Low to High)',
  'Chest', 'Cable', 'Push', 'Isolation', 'isolation', 'intermediate',
  ARRAY['Anterior Deltoids'],
  ARRAY['Ròng rọc đặt ở nấc thấp nhất', 'Lòng bàn tay hướng lên hoặc vào nhau', 'Kéo cáp hướng lên ngang tầm cằm/ngực trên', 'Siết chặt cơ ngực trên'],
  ARRAY['Nhún gối mượn đà', 'Kéo bằng cơ vai trước thay vì ép cơ ngực'],
  ARRAY['incline-dumbbell-fly', 'middle-cable-fly'],
  ARRAY['Cáp đặt vị trí sát sàn', 'Kéo cáp vòng lên phía trên ngực', 'Hạ từ từ về vị trí ban đầu']
),
(
  'middle-cable-fly', 'Middle Cable Fly', 'Ép Cáp Ngang Ngực', 'Middle Cable Fly',
  'Chest', 'Cable', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Anterior Deltoids'],
  ARRAY['Ròng rọc đặt ngang tầm ngực', 'Khuỷu tay giữ góc cong nhẹ cố định', 'Ép hai tay lại trước ngực'],
  ARRAY['Thân người nghiêng ngả quá nhiều', 'Duỗi thẳng hoàn toàn khớp khuỷu'],
  ARRAY['machine-chest-fly', 'flat-dumbbell-fly'],
  ARRAY['Đặt ròng rọc ngang ngực', 'Kéo hai tay ép lại phía trước', 'Kiểm soát nhịp mở tay']
),
(
  'chest-dip', 'Chest Dip', 'Chống Xà Kép Tập Ngực', 'Chest Dip',
  'Chest', 'Bodyweight', 'Push', 'Compound', 'push', 'advanced',
  ARRAY['Triceps', 'Anterior Deltoids'],
  ARRAY['Nghiêng thân người về phía trước 20-30 độ', 'Khuỷu tay hơi mở sang hai bên', 'Hạ người cho đến khi ngực căng', 'Đẩy người lên bằng lực cơ ngực'],
  ARRAY['Giữ người quá thẳng đứng (dồn vào tay sau)', 'Hạ quá sâu gây chấn thương khớp vai'],
  ARRAY['decline-barbell-bench-press', 'push-up'],
  ARRAY['Nắm hai thanh xà kép, hơi nghiêng người về trước', 'Hạ thân người xuống có kiểm soát', 'Đẩy người lên vị trí ban đầu']
),
(
  'dumbbell-pullover', 'Dumbbell Pullover', 'Vớt Tạ Đơn Tập Ngực Và Xô', 'Dumbbell Pullover',
  'Chest', 'Dumbbell', 'Pull', 'Compound', 'push', 'intermediate',
  ARRAY['Latissimus Dorsi', 'Triceps', 'Serratus Anterior'],
  ARRAY['Nằm vuông góc hoặc dọc ghế', 'Hai tay ôm đĩa tạ hình kim cương', 'Hạ tạ qua đầu cảm nhận độ giãn lồng ngực', 'Kéo tạ về vị trí trên ngực'],
  ARRAY['Hạ tạ quá sâu làm đau vai', 'Gập khuỷu tay quá nhiều'],
  ARRAY['straight-arm-cable-pulldown', 'cable-lat-pulldown'],
  ARRAY['Nằm trên ghế, giữ tạ đơn trên ngực', 'Hạ tạ vòng qua sau đầu', 'Kéo tạ trở lại vị trí cũ']
),
(
  'flat-dumbbell-fly', 'Flat Dumbbell Fly', 'Banh Ngực Ngang Với Tạ Đơn', 'Flat Dumbbell Fly',
  'Chest', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'intermediate',
  ARRAY['Anterior Deltoids'],
  ARRAY['Nằm phẳng trên ghế, khuỷu tay hơi cong', 'Mở tạ sang ngang có kiểm soát đến khi căng ngực', 'Khép tạ lại vòng cung như ôm thân cây'],
  ARRAY['Hạ tạ quá sâu dưới mức vai', 'Đổi góc khuỷu tay liên tục'],
  ARRAY['machine-chest-fly', 'middle-cable-fly'],
  ARRAY['Nằm trên ghế phẳng, hai tay cầm tạ trên ngực', 'Mở rộng tay sang hai bên', 'Ép tạ trở lại điểm ban đầu']
),
(
  'incline-dumbbell-fly', 'Incline Dumbbell Fly', 'Banh Ngực Dốc Lên Với Tạ Đơn', 'Incline Dumbbell Fly',
  'Chest', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'intermediate',
  ARRAY['Anterior Deltoids'],
  ARRAY['Ghế dốc 30 độ', 'Mở rộng hai tay sang hai bên cảm nhận cơ ngực trên căng', 'Đưa tạ về vị trí trên ngực trên'],
  ARRAY['Dùng tạ quá nặng làm sai form', 'Đẩy tạ va đập vào nhau'],
  ARRAY['cable-crossover-low-to-high', 'incline-dumbbell-bench-press'],
  ARRAY['Nằm ghế dốc 30 độ', 'Mở hai tạ sang bên hình cánh cung', 'Khép tạ về giữa ngực']
),
(
  'diamond-push-up', 'Diamond Push-up', 'Hít Đất Tay Kim Cương', 'Diamond Push-up',
  'Chest', 'Bodyweight', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Triceps', 'Anterior Deltoids'],
  ARRAY['Hai bàn tay chụm lại hình tam giác/kim cương', 'Hạ ngực sát chạm vào mu bàn tay', 'Đẩy thẳng tay gồng chặt ngực trong và tay sau'],
  ARRAY['Khuỷu tay xòe ngang quá rộng gây đau cổ tay', 'Võng lưng'],
  ARRAY['close-grip-bench-press', 'push-up'],
  ARRAY['Tạo hình kim cương bằng ngón cái và ngón trỏ trên sàn', 'Hạ ngực xuống chạm tay', 'Đẩy người lên']
),
(
  'decline-push-up', 'Decline Push-up', 'Hít Đất Dốc Xuống (Chân Cao)', 'Decline Push-up',
  'Chest', 'Bodyweight', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Anterior Deltoids', 'Upper Chest'],
  ARRAY['Đặt hai chân lên bục hoặc ghế', 'Hai tay chống sàn rộng bằng vai', 'Hạ người chậm rãi chạm sàn rồi đẩy lên'],
  ARRAY['Chùng lưng xệ bụng', 'Đầu chúc xuống sàn'],
  ARRAY['incline-dumbbell-bench-press', 'pike-push-up'],
  ARRAY['Đặt chân lên bục cao, hai tay chống đất', 'Hạ ngực xuống sát đất', 'Đẩy người lên']
),
(
  'incline-push-up', 'Incline Push-up', 'Hít Đất Dốc Lên (Tay Cao)', 'Incline Push-up',
  'Chest', 'Bodyweight', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Triceps'],
  ARRAY['Đặt hai tay lên bục hoặc ghế cao', 'Cơ thể thẳng tắp', 'Hạ ngực chạm mép bục rồi đẩy lên'],
  ARRAY['Ưỡn ngực không hết', 'Mông nhô lên quá cao'],
  ARRAY['push-up', 'machine-chest-press'],
  ARRAY['Chống tay lên bục cao', 'Hạ ngực chạm bục', 'Đẩy tay thẳng về vị trí ban đầu']
),
(
  'machine-chest-press', 'Machine Chest Press', 'Đẩy Ngực Bằng Máy', 'Machine Chest Press',
  'Chest', 'Machine', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Triceps', 'Anterior Deltoids'],
  ARRAY['Điều chỉnh ghế tay cầm ngang ngực', 'Đạp chân vững, bả vai ép vào đệm', 'Đẩy tay cầm ra trước không khóa khuỷu'],
  ARRAY['Nhấc vai về trước rời khỏi đệm ghế', 'Thả tạ đập kêu mạnh'],
  ARRAY['barbell-bench-press', 'dumbbell-bench-press'],
  ARRAY['Ngồi vào máy đẩy ngực', 'Đẩy thanh cầm ra xa', 'Hạ tay về vị trí căng cơ ngực']
),
(
  'incline-machine-chest-press', 'Incline Machine Chest Press', 'Đẩy Ngực Trên Bằng Máy', 'Incline Machine Chest Press',
  'Chest', 'Machine', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Anterior Deltoids', 'Triceps'],
  ARRAY['Ghế dốc cố định, hướng đẩy chéo lên', 'Đẩy có kiểm soát siết cơ ngực trên', 'Hạ về từ từ'],
  ARRAY['Mất tiếp xúc lưng trên đệm', 'Khóa cùi chỏ giật mạnh'],
  ARRAY['incline-dumbbell-bench-press', 'smith-machine-incline-press'],
  ARRAY['Ngồi vào máy đẩy ngực trên', 'Đẩy tay cầm chéo lên trước', 'Hạ về chậm rãi']
),
(
  'svend-press', 'Svend Press', 'Ép Tạ Đĩa Ngực (Svend Press)', 'Svend Press',
  'Chest', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Anterior Deltoids'],
  ARRAY['Kẹp hai bánh tạ đĩa giữa hai lòng bàn tay', 'Ép chặt hai tay vào nhau liên tục', 'Đẩy đĩa tạ thẳng ra trước ngực rồi thu về'],
  ARRAY['Giảm lực ép giữa hai tay', 'Dùng ngón tay móc tạ thay vì ép lòng bàn tay'],
  ARRAY['machine-chest-fly', 'middle-cable-fly'],
  ARRAY['Kẹp đĩa tạ trước ngực bằng hai lòng bàn tay', 'Đẩy tạ thẳng ra trước mặt', 'Thu tạ về ngực trong khi vẫn ép chặt']
),
(
  'smith-machine-bench-press', 'Smith Machine Bench Press', 'Đẩy Ngực Ngang Với Máy Smith', 'Smith Machine Bench Press',
  'Chest', 'Machine', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Triceps', 'Anterior Deltoids'],
  ARRAY['Căn chỉnh ghế chính giữa thanh trượt', 'Hạ thanh đòn xuống ngực có kiểm soát', 'Đẩy dứt khoát lên trên'],
  ARRAY['Cổ tay gập ra sau quá nhiều', 'Khóa cùi chỏ đột ngột'],
  ARRAY['barbell-bench-press', 'machine-chest-press'],
  ARRAY['Nằm trên ghế dưới thanh Smith', 'Mở khóa tạ, hạ chạm ngực', 'Đẩy tạ lên và xoay khóa an toàn khi kết thúc']
),
(
  'smith-machine-incline-press', 'Smith Machine Incline Press', 'Đẩy Ngực Trên Với Máy Smith', 'Smith Machine Incline Press',
  'Chest', 'Machine', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Anterior Deltoids', 'Triceps'],
  ARRAY['Ghế nghiêng 30 độ dưới máy Smith', 'Hạ tạ chạm ngực trên', 'Đẩy thẳng tạ lên cao'],
  ARRAY['Đặt vị trí ghế quá xa hoặc quá gần trục trượt', 'Nhún vai'],
  ARRAY['incline-barbell-bench-press', 'incline-dumbbell-bench-press'],
  ARRAY['Nằm ghế dốc dưới máy Smith', 'Hạ thanh đòn chạm ngực trên', 'Đẩy lên vị trí cao nhất']
),
(
  'resistance-band-chest-press', 'Resistance Band Chest Press', 'Đẩy Ngực Với Dây Kháng Lực', 'Resistance Band Chest Press',
  'Chest', 'Resistance Band', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Triceps', 'Anterior Deltoids'],
  ARRAY['Vòng dây qua lưng hoặc cột cố định sau lưng', 'Hai tay cầm hai đầu dây ngang ngực', 'Đẩy hai tay thẳng ra trước siết ngực'],
  ARRAY['Dây bị tuột khỏi vị trí tựa', 'Thả tay quá nhanh làm dây giật'],
  ARRAY['push-up', 'dumbbell-bench-press'],
  ARRAY['Vòng dây kháng lực qua lưng', 'Đẩy hai tay ra phía trước', 'Thu tay về chậm rãi']
),

-- ==============================================================================
-- 2. BACK (26 Exercises)
-- ==============================================================================
(
  'barbell-deadlift', 'Deadlift (Barbell)', 'Kéo Tạ Đòn (Deadlift)', 'Barbell Deadlift',
  'Back', 'Barbell', 'Pull', 'Compound', 'hinge', 'advanced',
  ARRAY['Hamstrings', 'Glutes', 'Core', 'Forearms', 'Traps'],
  ARRAY['Thanh đòn đặt trên giữa bàn chân', 'Khóa lưng thẳng, kéo vai về sau', 'Đẩy sàn bằng gót chân nâng tạ bám sát cẳng chân', 'Khóa hông ở đỉnh không ngả lưng quá mức'],
  ARRAY['Gù lưng khi kéo nặng', 'Kéo tạ rời xa cẳng chân', 'Giật tạ đột ngột thay vì nén áp lực trước'],
  ARRAY['romanian-deadlift', 'trap-bar-deadlift'],
  ARRAY['Đứng chân rộng bằng vai', 'Nắm thanh đòn dưới sàn', 'Kéo thanh đòn lên cao theo thân người']
),
(
  'pull-up', 'Pull-up', 'Hít Xà Đơn', 'Pull-up',
  'Back', 'Bodyweight', 'Pull', 'Compound', 'pull', 'intermediate',
  ARRAY['Biceps', 'Rhomboids', 'Rear Deltoids', 'Core'],
  ARRAY['Cầm xà rộng hơn vai một chút', 'Kéo xương bả vai xuống trước khi gập tay', 'Kéo ngực hướng về thanh xà đến khi cằm qua xà', 'Hạ người xuống có kiểm soát hết biên độ'],
  ARRAY['Vung vẩy đung đưa người lấy đà (kipping)', 'Không hạ hết tay ở cuối chuyển động', 'Rụt vai rụt cổ'],
  ARRAY['chin-up', 'cable-lat-pulldown', 'inverted-row'],
  ARRAY['Bám vào thanh xà ngang', 'Kéo thân người lên cao cho đến khi cằm qua xà', 'Hạ người xuống chậm rãi']
),
(
  'cable-lat-pulldown', 'Lat Pulldown (Cable)', 'Kéo Xô Cáp Xuống', 'Cable Lat Pulldown',
  'Back', 'Cable', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Biceps', 'Rear Deltoids'],
  ARRAY['Cố định đùi chặt dưới đệm đỡ', 'Ưỡn ngực, nghiêng thân người nhẹ về sau 10-15 độ', 'Kéo thanh bar chạm nhẹ ngực trên', 'Kiểm soát nhịp đi lên giãn cơ xô'],
  ARRAY['Ngả người về sau quá nhiều lấy đà', 'Kéo thanh bar ra sau cổ', 'Dùng lực cánh tay thay vì cơ xô'],
  ARRAY['pull-up', 'straight-arm-cable-pulldown'],
  ARRAY['Ngồi vào máy kéo xô', 'Kéo thanh bar xuống phía trên ngực', 'Để thanh bar đi lên chậm rãi']
),
(
  'seated-cable-row', 'Seated Cable Row', 'Kéo Cáp Ngồi (Chèo Cáp)', 'Seated Cable Row',
  'Back', 'Cable', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Biceps', 'Rhomboids'],
  ARRAY['Ngồi thẳng lưng, đầu gối hơi chùng nhẹ', 'Kéo tay cầm về phía rốn hoặc bụng dưới', 'Ép chặt hai bả vai vào nhau ở điểm co cơ', 'Thả tay ra từ từ không gù lưng'],
  ARRAY['Đung đưa thân người về trước sau quá nhiều', 'Nhấc vai lên tai làm mỏi cơ cầu vai', 'Gập lưng dưới'],
  ARRAY['barbell-bent-over-row', 'one-arm-dumbbell-row'],
  ARRAY['Ngồi vào máy chèo cáp', 'Kéo tay cầm về phía sát bụng', 'Giữ lưng thẳng trong suốt quá trình']
),
(
  'chin-up', 'Chin-up', 'Hít Xà Đơn Lòng Bàn Tay Ngửa', 'Chin-up',
  'Back', 'Bodyweight', 'Pull', 'Compound', 'pull', 'intermediate',
  ARRAY['Biceps', 'Latissimus Dorsi'],
  ARRAY['Nắm xà lòng bàn tay hướng vào trong người', 'Kéo người lên dứt khoát cằm vượt xà', 'Hạ người chậm có kiểm soát'],
  ARRAY['Đung đưa người', 'Thả rơi tự do ở cuối hiệp'],
  ARRAY['pull-up', 'cable-lat-pulldown'],
  ARRAY['Nắm thanh xà lòng bàn tay ngửa', 'Kéo thân người lên cằm qua xà', 'Hạ người xuống từ từ']
),
(
  'barbell-bent-over-row', 'Barbell Bent-over Row', 'Gập Người Kéo Tạ Đòn', 'Barbell Bent-over Row',
  'Back', 'Barbell', 'Pull', 'Compound', 'pull', 'intermediate',
  ARRAY['Rhomboids', 'Latissimus Dorsi', 'Biceps', 'Lower Back'],
  ARRAY['Gập hông 45 độ, lưng giữ thẳng tắp', 'Kéo thanh đòn chạm nhẹ bụng dưới', 'Ép bả vai ở đỉnh và hạ tạ có kiểm soát'],
  ARRAY['Gù lưng dưới gây chấn thương đĩa đệm', 'Nhún người lấy đà nâng tạ'],
  ARRAY['t-bar-row', 'one-arm-dumbbell-row', 'chest-supported-dumbbell-row'],
  ARRAY['Đứng gập hông lưng thẳng', 'Kéo thanh đòn về phía rốn', 'Hạ tạ chậm về vị trí ban đầu']
),
(
  'one-arm-dumbbell-row', 'One-arm Dumbbell Row', 'Chèo Tạ Đơn Một Tay', 'One-arm Dumbbell Row',
  'Back', 'Dumbbell', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Latissimus Dorsi', 'Rhomboids', 'Biceps'],
  ARRAY['Một tay và đầu gối tựa ghế phẳng', 'Kéo tạ đơn theo quỹ đạo cong về phía hông', 'Siết cơ xô ở đỉnh chuyển động'],
  ARRAY['Xoay vặn toàn bộ thân người để giật tạ', 'Kéo tạ thẳng lên vai thay vì kéo về hông'],
  ARRAY['seated-cable-row', 'barbell-bent-over-row'],
  ARRAY['Tựa một tay lên ghế, tay kia cầm tạ đơn', 'Kéo tạ về phía hông', 'Hạ tạ giãn hết cơ lưng']
),
(
  't-bar-row', 'T-Bar Row', 'Chèo Tạ Chữ T (T-Bar Row)', 'T-Bar Row',
  'Back', 'Barbell', 'Pull', 'Compound', 'pull', 'intermediate',
  ARRAY['Rhomboids', 'Traps', 'Biceps'],
  ARRAY['Hai chân đứng vững hai bên thanh đòn', 'Lưng thẳng gập hông 45 độ', 'Kéo tạ chạm nhẹ lồng ngực'],
  ARRAY['Đứng thẳng dậy khi kéo nặng', 'Gù cột sống lưng'],
  ARRAY['barbell-bent-over-row', 'seated-cable-row'],
  ARRAY['Đứng trên bục máy chữ T', 'Nắm tay cầm kéo tạ về phía ngực', 'Hạ tạ có kiểm soát']
),
(
  'romanian-deadlift', 'Romanian Deadlift (RDL)', 'Romanian Deadlift Với Tạ Đòn', 'Romanian Deadlift (RDL)',
  'Back', 'Barbell', 'Pull', 'Compound', 'hinge', 'intermediate',
  ARRAY['Hamstrings', 'Glutes', 'Lower Back'],
  ARRAY['Đầu gối hơi chùng cố định góc', 'Đẩy mông ra sau hạ tạ lướt sát đùi', 'Cảm nhận căng mạnh cơ đùi sau rồi siết mông đứng lên'],
  ARRAY['Cúi lưng gập người thay vì đẩy mông (Hinge)', 'Hạ tạ quá sâu chạm sàn biến thành Deadlift'],
  ARRAY['dumbbell-romanian-deadlift', 'good-morning'],
  ARRAY['Cầm tạ đòn ngang hông', 'Đẩy hông ra sau hạ tạ qua gối', 'Siết mông đẩy hông về trước đứng dậy']
),
(
  'dumbbell-romanian-deadlift', 'Dumbbell Romanian Deadlift', 'Romanian Deadlift Với Tạ Đơn', 'Dumbbell Romanian Deadlift',
  'Back', 'Dumbbell', 'Pull', 'Compound', 'hinge', 'beginner',
  ARRAY['Hamstrings', 'Glutes', 'Lower Back'],
  ARRAY['Hai tạ đơn lướt sát mặt trước đùi', 'Đẩy khớp hông tối đa ra phía sau', 'Giữ cột sống trung tính'],
  ARRAY['Gù lưng trên và lưng dưới', 'Đầu gối gập quá nhiều biến thành squat'],
  ARRAY['romanian-deadlift', 'back-extension-hyperextension'],
  ARRAY['Hai tay cầm hai tạ đơn', 'Đẩy hông ra sau hạ tạ xuống cẳng chân', 'Đứng thẳng dậy siết mông']
),
(
  'chest-supported-dumbbell-row', 'Chest-supported Dumbbell Row', 'Nằm Ghế Dốc Kéo Tạ Đơn', 'Chest-supported Dumbbell Row',
  'Back', 'Dumbbell', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Rhomboids', 'Rear Deltoids', 'Biceps'],
  ARRAY['Nằm sấp áp ngực vào ghế dốc 30-45 độ', 'Kéo hai tạ đơn về hông ép bả vai', 'Cô lập cơ lưng không dùng lực eo'],
  ARRAY['Nhấc ngực rời khỏi đệm ghế', 'Kéo tạ bằng quán tính giật'],
  ARRAY['one-arm-dumbbell-row', 'seated-cable-row'],
  ARRAY['Nằm sấp ngực tựa ghế dốc', 'Kéo hai tạ đơn lên phía sườn', 'Hạ tạ chậm rãi']
),
(
  'close-grip-lat-pulldown', 'Close Grip Lat Pulldown', 'Kéo Xô Cáp Tay Hẹp V-Bar', 'Close Grip Lat Pulldown',
  'Back', 'Cable', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Biceps', 'Middle Back'],
  ARRAY['Gắn tay cầm chữ V hẹp', 'Kéo tay cầm xuống chạm xương ức', 'Ép chặt cùi chỏ vào mạn sườn'],
  ARRAY['Ngửa người về sau quá nhiều', 'Nhún vai'],
  ARRAY['cable-lat-pulldown', 'pull-up'],
  ARRAY['Cầm tay kéo V-bar trên máy cáp', 'Kéo xuống chạm ngực trên', 'Thả tay lên chậm']
),
(
  'straight-arm-cable-pulldown', 'Straight-arm Cable Pulldown', 'Đứng Đè Cáp Thẳng Tay Tập Xô', 'Straight-arm Cable Pulldown',
  'Back', 'Cable', 'Pull', 'Isolation', 'pull', 'beginner',
  ARRAY['Triceps', 'Rear Deltoids'],
  ARRAY['Khuỷu tay hơi chùng khóa cứng góc', 'Dùng cơ xô kéo thanh bar xuống chạm đùi', 'Siết chặt cơ xô 1 giây ở đáy'],
  ARRAY['Gập duỗi khuỷu tay dùng lực tay sau', 'Vung thân người'],
  ARRAY['dumbbell-pullover', 'cable-lat-pulldown'],
  ARRAY['Đứng trước máy cáp cao, hai tay thẳng', 'Đè thanh đòn xuống sát đùi', 'Đưa tạ lên chậm rãi']
),
(
  'back-extension-hyperextension', 'Back Extension (Hyperextension)', 'Gập Lưng Trên Ghế Dốc (Hyperextension)', 'Back Extension',
  'Back', 'Bodyweight', 'Pull', 'Compound', 'hinge', 'beginner',
  ARRAY['Glutes', 'Hamstrings', 'Lower Back'],
  ARRAY['Đệm đỡ ngang dưới khớp hông', 'Gập người xuống căng cơ đùi sau', 'Nâng thân người lên thành đường thẳng không ngửa quá mức'],
  ARRAY['Ngửa cong lưng quá đà ở đỉnh', 'Vung người lấy đà'],
  ARRAY['good-morning', 'romanian-deadlift'],
  ARRAY['Cố định chân trên ghế dốc', 'Gập thân người xuống', 'Nâng người lên ngang thân']
),
(
  'good-morning', 'Good Morning', 'Chào Buổi Sáng Với Tạ Đòn (Good Morning)', 'Good Morning',
  'Back', 'Barbell', 'Pull', 'Compound', 'hinge', 'intermediate',
  ARRAY['Hamstrings', 'Glutes', 'Lower Back'],
  ARRAY['Thanh đòn đặt trên vai sau', 'Đẩy hông ra sau gập người góc 45-60 độ', 'Đứng thẳng dậy siết cơ mông'],
  ARRAY['Gù lưng dưới', 'Gập đầu gối quá nhiều'],
  ARRAY['romanian-deadlift', 'back-extension-hyperextension'],
  ARRAY['Đặt thanh đòn trên vai sau', 'Gập hông đưa mông ra sau', 'Đứng thẳng dậy']
),
(
  'inverted-row', 'Inverted Row (Australian Pull-up)', 'Hít Xà Dốc Nghiêng Ngửa Người', 'Inverted Row',
  'Back', 'Bodyweight', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Biceps', 'Rhomboids', 'Rear Deltoids'],
  ARRAY['Gót chân chạm đất, thân người thẳng tắp', 'Kéo ngực chạm thanh xà', 'Hạ người xuống có kiểm soát'],
  ARRAY['Chùng hông xệ mông', 'Không chạm ngực vào xà'],
  ARRAY['pull-up', 'seated-cable-row'],
  ARRAY['Nắm thanh đòn ngang tầm ngực từ dưới', 'Kéo ngực chạm thanh đòn', 'Hạ người xuống']
),
(
  'machine-lat-pulldown', 'Machine Lat Pulldown', 'Kéo Xô Bằng Máy', 'Machine Lat Pulldown',
  'Back', 'Machine', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Biceps'],
  ARRAY['Ngồi cố định đùi dưới đệm máy', 'Kéo hai tay cầm xuống hai bên ngực', 'Thả tạ lên từ từ'],
  ARRAY['Nhấc mông khỏi ghế', 'Kéo lệch một bên'],
  ARRAY['cable-lat-pulldown', 'pull-up'],
  ARRAY['Ngồi vào máy kéo xô', 'Kéo tay nắm xuống', 'Nhả tạ lên chậm']
),
(
  'machine-seated-row', 'Machine Seated Row', 'Ngồi Chèo Lưng Bằng Máy', 'Machine Seated Row',
  'Back', 'Machine', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Rhomboids', 'Biceps'],
  ARRAY['Áp ngực vào đệm đỡ', 'Kéo tay cầm về sau ép bả vai', 'Hạ tạ giãn hết cơ lưng'],
  ARRAY['Rời ngực khỏi đệm lấy đà', 'Rụt vai'],
  ARRAY['seated-cable-row', 'chest-supported-dumbbell-row'],
  ARRAY['Ngồi áp ngực vào đệm máy', 'Kéo hai tay cầm về phía sau', 'Thả tạ về phía trước']
),
(
  'cable-face-pull-high', 'High Cable Face Pull', 'Kéo Cáp Cao Vào Mặt', 'High Cable Face Pull',
  'Back', 'Cable', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Rear Deltoids', 'Rotator Cuff'],
  ARRAY['Kéo dây thừng về phía trán', 'Tách hai cùi chỏ sang hai bên', 'Xoay ngoài cánh tay'],
  ARRAY['Hạ khuỷu tay quá thấp', 'Dùng tạ quá nặng ngửa người'],
  ARRAY['cable-face-pull', 'rear-delt-dumbbell-fly'],
  ARRAY['Cáp đặt góc cao', 'Kéo dây thừng về mặt', 'Thả tay ra chậm']
),
(
  'trap-bar-deadlift', 'Trap Bar Deadlift', 'Kéo Khung Tạ Lục Giác (Trap Bar)', 'Trap Bar Deadlift',
  'Back', 'Barbell', 'Pull', 'Compound', 'hinge', 'intermediate',
  ARRAY['Quadriceps', 'Hamstrings', 'Glutes', 'Traps'],
  ARRAY['Đứng giữa tâm khung lục giác', 'Hạ hông lưng thẳng nắm tay cầm hai bên', 'Đạp sàn đứng thẳng dậy dứt khoát'],
  ARRAY['Gù lưng', 'Đầu gối chụm vào trong'],
  ARRAY['barbell-deadlift', 'romanian-deadlift'],
  ARRAY['Đứng vào giữa khung trap bar', 'Nắm hai tay cầm hai bên', 'Đạp chân kéo tạ đứng thẳng dậy']
),
(
  'sumo-deadlift', 'Sumo Deadlift', 'Kéo Tạ Đòn Tư Thế Sumo', 'Sumo Deadlift',
  'Back', 'Barbell', 'Pull', 'Compound', 'hinge', 'advanced',
  ARRAY['Glutes', 'Quadriceps', 'Adductors', 'Hamstrings'],
  ARRAY['Chân đứng rộng, mũi chân mở 45 độ ra ngoài', 'Hai tay nắm đòn bên trong hai chân', 'Mở khớp gối theo hướng mũi chân đạp sàn kéo tạ'],
  ARRAY['Khép gối khi bắt đầu kéo', 'Đẩy mông lên trước khi tạ rời sàn'],
  ARRAY['barbell-deadlift', 'trap-bar-deadlift'],
  ARRAY['Đứng chân rộng hai tay nắm trong', 'Hạ hông xuống mở gối', 'Kéo tạ thẳng lên khóa hông']
),
(
  'single-arm-cable-row', 'Single-arm Cable Row', 'Kéo Cáp Một Tay Đứng Hoặc Ngồi', 'Single-arm Cable Row',
  'Back', 'Cable', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Latissimus Dorsi', 'Obliques'],
  ARRAY['Một tay nắm cáp kéo sát mạn sườn', 'Siết chặt cơ xô một bên', 'Không vặn xoay thân người'],
  ARRAY['Xoay cả người để kéo', 'Thả tạ quá nhanh'],
  ARRAY['one-arm-dumbbell-row', 'seated-cable-row'],
  ARRAY['Cầm tay nắm cáp một tay', 'Kéo về sát sườn hông', 'Nhả tạ chậm có kiểm soát']
),
(
  'meadows-row', 'Meadows Row', 'Chèo Tạ Đòn Một Tay Landmine (Meadows Row)', 'Meadows Row',
  'Back', 'Barbell', 'Pull', 'Compound', 'pull', 'advanced',
  ARRAY['Latissimus Dorsi', 'Rear Deltoids'],
  ARRAY['Đứng vuông góc thanh tạ cắm sàn (Landmine)', 'Nắm đầu thanh tạ kéo lên hướng khuỷu tay ra sau', 'Tập trung cơ xô ngoài'],
  ARRAY['Đứng quá thẳng', 'Giật tạ mạnh'],
  ARRAY['one-arm-dumbbell-row', 'barbell-bent-over-row'],
  ARRAY['Đứng cạnh thanh đòn landmine', 'Kéo đầu đòn tạ lên sát hông', 'Hạ tạ xuống có kiểm soát']
),
(
  'dumbbell-shrug', 'Dumbbell Shrug', 'Nhún Vai Tạ Đơn (Cơ Cầu Vai)', 'Dumbbell Shrug',
  'Back', 'Dumbbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Traps', 'Forearms'],
  ARRAY['Đứng thẳng tạ đơn hai bên hông', 'Nhấc hai vai lên thẳng hướng về tai', 'Giữ đỉnh 1 giây rồi hạ xuống'],
  ARRAY['Xoay tròn khớp vai gây mòn sụn', 'Gập khuỷu tay'],
  ARRAY['barbell-shrug', 'cable-face-pull'],
  ARRAY['Hai tay cầm hai tạ đơn', 'Nhún vai thẳng lên', 'Hạ vai xuống chậm rãi']
),
(
  'barbell-shrug', 'Barbell Shrug', 'Nhún Vai Tạ Đòn', 'Barbell Shrug',
  'Back', 'Barbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Traps', 'Forearms'],
  ARRAY['Cầm đòn tạ trước đùi hoặc sau mông', 'Kéo cơ cầu vai lên cao hết mức', 'Hạ tạ xuống chậm'],
  ARRAY['Xoay vai vòng cung', 'Cúi gập cổ'],
  ARRAY['dumbbell-shrug', 'trap-bar-deadlift'],
  ARRAY['Cầm thanh đòn ngang đùi', 'Nhún vai lên cao hướng về tai', 'Hạ tạ về vị trí cũ']
),
(
  'resistance-band-pull-apart', 'Resistance Band Pull-apart', 'Banh Dây Kháng Lực Ngang Ngực', 'Resistance Band Pull-apart',
  'Back', 'Resistance Band', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Rear Deltoids', 'Rhomboids'],
  ARRAY['Cầm dây ngang ngực hai tay thẳng', 'Banh dây sang hai bên chạm ngực', 'Ép chặt hai bả vai'],
  ARRAY['Gập cùi chỏ', 'Nhún vai lên tai'],
  ARRAY['cable-face-pull', 'rear-delt-dumbbell-fly'],
  ARRAY['Hai tay cầm dây trước ngực', 'Kéo căng dây sang hai bên', 'Thu tay về chậm']
),

-- ==============================================================================
-- 3. LEGS (28 Exercises)
-- ==============================================================================
(
  'barbell-squat', 'Squat (Barbell)', 'Gánh Tạ Đòn (Back Squat)', 'Barbell Back Squat',
  'Legs', 'Barbell', 'Push', 'Compound', 'squat', 'advanced',
  ARRAY['Glutes', 'Hamstrings', 'Calves', 'Core'],
  ARRAY['Thanh đòn đặt chắc chắn trên vai sau', 'Chân rộng bằng vai, mũi chân mở 15-30 độ', 'Hít sâu gồng chặt cơ bụng (Brace)', 'Hạ mông xuống cho đến khi nếp gấp hông thấp hơn đầu gối', 'Đạp đều toàn bàn chân đứng dậy'],
  ARRAY['Đầu gối chụm vào nhau (Knee valgus)', 'Nhấc gót chân khỏi sàn', 'Gập thân người về trước quá nhiều'],
  ARRAY['front-squat', 'goblet-squat', 'leg-press'],
  ARRAY['Đặt thanh đòn trên vai sau', 'Hạ mông xuống cho đến khi đùi song song sàn', 'Đẩy người lên lại']
),
(
  'leg-press', 'Leg Press', 'Đạp Đùi Với Máy', 'Leg Press',
  'Legs', 'Machine', 'Push', 'Compound', 'squat', 'beginner',
  ARRAY['Glutes', 'Hamstrings'],
  ARRAY['Lưng và mông áp sát đệm ghế', 'Đặt chân rộng bằng vai giữa bàn đạp', 'Hạ bàn đạp xuống có kiểm soát tới khi đùi tạo góc 90 độ', 'Đẩy bàn đạp ra không khóa thẳng khớp gối'],
  ARRAY['Khóa thẳng khớp gối ở đỉnh chuyển động', 'Nhấc mông khỏi đệm ghế khi hạ chân sâu', 'Đặt chân quá thấp gây áp lực xương bánh chè'],
  ARRAY['barbell-squat', 'hack-squat-machine', 'goblet-squat'],
  ARRAY['Ngồi vào máy đạp đùi', 'Đẩy bàn đạp ra xa', 'Hạ bàn đạp xuống gần ngực']
),
(
  'leg-extension', 'Leg Extension', 'Đá Đùi Trước Với Máy', 'Leg Extension',
  'Legs', 'Machine', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Khớp gối thẳng hàng với trục quay của máy', 'Đệm chân đặt ngay trên mu bàn chân/cổ chân', 'Đá thẳng chân lên có kiểm soát, giữ đỉnh 1 giây', 'Hạ xuống chậm rãi không để tạ va chạm'],
  ARRAY['Văng chân lấy đà quá nhanh', 'Chỉnh trục quay máy lệch khớp gối'],
  ARRAY['sissy-squat', 'goblet-squat'],
  ARRAY['Ngồi vào máy đá đùi', 'Đá thẳng chân lên cao', 'Hạ chân xuống chậm rãi']
),
(
  'lying-leg-curl', 'Lying Leg Curl', 'Nằm Cuốn Đùi Sau Với Máy', 'Lying Leg Curl',
  'Legs', 'Machine', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Calves'],
  ARRAY['Nằm sấp, đệm lăn đặt dưới bắp chân ngay trên gót', 'Giữ hông áp sát bề mặt đệm', 'Cuộn chân về phía mông hết biên độ', 'Duỗi chân từ từ có kiểm soát'],
  ARRAY['Nhấc hông lên cao để mượn lực lưng dưới', 'Thả rơi tạ khi hạ chân'],
  ARRAY['seated-leg-curl', 'romanian-deadlift'],
  ARRAY['Nằm sấp vào máy cuốn đùi', 'Cuộn chân về phía mông', 'Duỗi chân ra chậm rãi']
),
(
  'front-squat', 'Barbell Front Squat', 'Gánh Tạ Đòn Phía Trước (Front Squat)', 'Barbell Front Squat',
  'Legs', 'Barbell', 'Push', 'Compound', 'squat', 'advanced',
  ARRAY['Quadriceps', 'Core', 'Upper Back'],
  ARRAY['Đòn tạ tựa trên vai trước, nâng cùi chỏ cao song song sàn', 'Lưng giữ thẳng đứng tối đa', 'Squat sâu cảm nhận đùi trước'],
  ARRAY['Hạ cùi chỏ làm rơi thanh tạ', 'Gù lưng trên'],
  ARRAY['barbell-squat', 'goblet-squat'],
  ARRAY['Thanh đòn đặt trước vai', 'Giữ cùi chỏ cao', 'Hạ người squat và đẩy lên']
),
(
  'goblet-squat', 'Goblet Squat', 'Squat Ôm Tạ Dumbbell (Goblet Squat)', 'Goblet Squat',
  'Legs', 'Dumbbell', 'Push', 'Compound', 'squat', 'beginner',
  ARRAY['Quadriceps', 'Glutes', 'Core'],
  ARRAY['Hai tay ôm tạ đơn trước ngực', 'Mở rộng gối ngồi sâu xuống giữa hai chân', 'Đạp gót đứng thẳng dậy'],
  ARRAY['Để tạ trượt xa khỏi ngực', 'Khép gối'],
  ARRAY['barbell-squat', 'bodyweight-air-squat'],
  ARRAY['Hai tay ôm quả tạ trước ngực', 'Hạ mông xuống tư thế squat', 'Đứng thẳng dậy']
),
(
  'bulgarian-split-squat', 'Bulgarian Split Squat', 'Squat Một Chân Kê Ghế (Bulgarian Split Squat)', 'Bulgarian Split Squat',
  'Legs', 'Dumbbell', 'Push', 'Compound', 'lunge', 'intermediate',
  ARRAY['Glutes', 'Hamstrings', 'Quadriceps'],
  ARRAY['Một chân đặt mu bàn chân lên ghế sau', 'Hạ đầu gối chân sau xuống gần sàn', 'Đầu gối chân trước thẳng hàng mũi chân'],
  ARRAY['Chân trước đặt quá gần ghế làm đau gối', 'Nghiêng vẹo hông'],
  ARRAY['walking-lunge', 'reverse-lunge'],
  ARRAY['Kê một chân ra ghế phía sau', 'Hạ thấp đùi chân trước', 'Đẩy thẳng người lên']
),
(
  'walking-lunge', 'Walking Lunge', 'Bước Chùng Chân Di Chuyển (Walking Lunge)', 'Walking Lunge',
  'Legs', 'Dumbbell', 'Push', 'Compound', 'lunge', 'beginner',
  ARRAY['Glutes', 'Quadriceps', 'Hamstrings'],
  ARRAY['Bước chân dài về trước, hạ gối sau vuông góc sát sàn', 'Giữ thân người thẳng đứng', 'Bước tiếp chân kia lên'],
  ARRAY['Bước quá ngắn làm gối trước vượt quá mũi chân', 'Nghiêng thân sang hai bên'],
  ARRAY['reverse-lunge', 'bulgarian-split-squat'],
  ARRAY['Cầm tạ hai bên, bước dài về trước', 'Hạ gối vuông góc sàn', 'Bước tiếp chân sau lên']
),
(
  'reverse-lunge', 'Reverse Lunge', 'Bước Chùng Chân Lùi Sau', 'Reverse Lunge',
  'Legs', 'Dumbbell', 'Push', 'Compound', 'lunge', 'beginner',
  ARRAY['Glutes', 'Hamstrings'],
  ARRAY['Bước một chân lùi về sau', 'Hạ gối xuống vuông góc', 'Đạp bằng gót chân trước đứng về vị trí cũ'],
  ARRAY['Mất thăng bằng khi lùi', 'Dồn trọng lượng vào ngón chân'],
  ARRAY['walking-lunge', 'step-up'],
  ARRAY['Đứng thẳng, bước lùi một chân về sau', 'Hạ trọng tâm thân người', 'Đạp chân trước đứng lên']
),
(
  'hack-squat-machine', 'Hack Squat Machine', 'Gánh Tạ Với Máy Hack Squat', 'Hack Squat Machine',
  'Legs', 'Machine', 'Push', 'Compound', 'squat', 'intermediate',
  ARRAY['Quadriceps', 'Glutes'],
  ARRAY['Lưng và vai áp sát đệm đỡ', 'Đặt chân giữa bàn đạp rộng bằng vai', 'Hạ tạ sâu đùi tạo góc vuông rồi đẩy lên'],
  ARRAY['Nhấc gót chân', 'Khóa thẳng khớp gối ở đỉnh'],
  ARRAY['leg-press', 'barbell-squat'],
  ARRAY['Vào máy hack squat', 'Mở khóa an toàn hạ đùi vuông góc', 'Đạp mạnh đẩy tạ lên']
),
(
  'seated-leg-curl', 'Seated Leg Curl', 'Ngồi Cuốn Đùi Sau Với Máy', 'Seated Leg Curl',
  'Legs', 'Machine', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Hamstrings'],
  ARRAY['Khóa đệm đùi chặt trên đùi', 'Gập gối cuốn chân xuống dưới sâu', 'Duỗi chân chậm rãi'],
  ARRAY['Để đệm chân trượt lên cổ chân', 'Nhấc mông khỏi ghế'],
  ARRAY['lying-leg-curl', 'romanian-deadlift'],
  ARRAY['Ngồi vào máy, cố định đùi', 'Cuộn chân xuống dưới ghế', 'Nhả chân từ từ lên']
),
(
  'standing-calf-raise', 'Standing Calf Raise', 'Nhón Bắp Chân Đứng Với Máy/Tạ', 'Standing Calf Raise',
  'Legs', 'Machine', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Gastrocnemius'],
  ARRAY['Nửa bàn chân đặt trên bục, gót chân hạ sâu giãn bắp chuối', 'Nhón cao hết mức bằng ức bàn chân', 'Giữ đỉnh 1 giây'],
  ARRAY['Nhún lò xo lấy đà', 'Gập gối khi nhón'],
  ARRAY['seated-calf-raise', 'jump-rope'],
  ARRAY['Đứng trên bục mũi chân tựa mép', 'Hạ gót chân sâu', 'Nhón gót chân lên cao tối đa']
),
(
  'seated-calf-raise', 'Seated Calf Raise', 'Ngồi Nhón Bắp Chân Với Máy', 'Seated Calf Raise',
  'Legs', 'Machine', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Soleus'],
  ARRAY['Ngồi cố định đệm trên đầu gối', 'Hạ sâu gót chân rồi nhón cao', 'Tập trung cơ bắp chân dưới (Soleus)'],
  ARRAY['Biên độ ngắn nửa vời', 'Thả tạ rơi'],
  ARRAY['standing-calf-raise', 'jump-rope'],
  ARRAY['Ngồi cố định đệm trên gối', 'Nhón gót lên cao', 'Hạ gót xuống sâu']
),
(
  'barbell-hip-thrust', 'Barbell Hip Thrust', 'Đẩy Hông Với Tạ Đòn (Hip Thrust)', 'Barbell Hip Thrust',
  'Legs', 'Barbell', 'Push', 'Compound', 'hinge', 'intermediate',
  ARRAY['Glutes', 'Hamstrings', 'Core'],
  ARRAY['Lưng trên kê mép ghế ngang xương bả vai', 'Đòn tạ bọc đệm đặt ngang nếp gấp hông', 'Đạp gót đẩy hông lên song song sàn siết chặt cơ mông'],
  ARRAY['Ưỡn cong lưng dưới thay vì dùng hông', 'Đặt chân quá xa hoặc quá gần'],
  ARRAY['dumbbell-hip-thrust', 'glute-bridge'],
  ARRAY['Tựa lưng vào ghế băng, tạ đặt trên hông', 'Đẩy hông lên cao siết cơ mông', 'Hạ hông xuống chậm']
),
(
  'dumbbell-hip-thrust', 'Dumbbell Hip Thrust', 'Đẩy Hông Với Tạ Đơn', 'Dumbbell Hip Thrust',
  'Legs', 'Dumbbell', 'Push', 'Compound', 'hinge', 'beginner',
  ARRAY['Glutes', 'Hamstrings'],
  ARRAY['Đặt quả tạ đơn ngang hông', 'Đẩy hông lên khóa cứng cơ mông 1-2 giây', 'Hạ xuống kiểm soát'],
  ARRAY['Nhấc gót chân', 'Ngửa đầu ra sau'],
  ARRAY['barbell-hip-thrust', 'glute-bridge'],
  ARRAY['Kê vai lên ghế, tạ đơn trên hông', 'Đẩy hông lên cao', 'Hạ mông xuống nhẹ nhàng']
),
(
  'glute-bridge', 'Bodyweight Glute Bridge', 'Nằm Nâng Mông Cơ Bản (Glute Bridge)', 'Glute Bridge',
  'Legs', 'Bodyweight', 'Push', 'Compound', 'hinge', 'beginner',
  ARRAY['Glutes', 'Hamstrings'],
  ARRAY['Nằm ngửa gập gối, bàn chân đặt phẳng sàn', 'Đạp gót nâng hông lên thẳng hàng vai và gối', 'Siết chặt cơ mông'],
  ARRAY['Võng lưng dưới', 'Dùng gân kheo thay vì cơ mông'],
  ARRAY['barbell-hip-thrust', 'dumbbell-hip-thrust'],
  ARRAY['Nằm ngửa trên sàn, co hai chân', 'Đẩy hông lên cao tạo đường thẳng', 'Hạ mông chạm đất']
),
(
  'step-up', 'Dumbbell Step-up', 'Bước Lên Bục Cao Với Tạ Đơn', 'Dumbbell Step-up',
  'Legs', 'Dumbbell', 'Push', 'Compound', 'lunge', 'beginner',
  ARRAY['Quadriceps', 'Glutes'],
  ARRAY['Đặt toàn bộ bàn chân lên bục vững chắc', 'Đạp chân trên bục nâng người lên', 'Hạ chân sau xuống chậm'],
  ARRAY['Dùng chân dưới bật nhảy lấy đà', 'Chỉ đặt mũi chân lên mép bục'],
  ARRAY['walking-lunge', 'bulgarian-split-squat'],
  ARRAY['Cầm tạ đơn hai bên', 'Bước một chân lên bục nâng toàn thân', 'Hạ chân xuống nhẹ nhàng']
),
(
  'cable-pull-through', 'Cable Pull-through', 'Kéo Cáp Qua Háng Tập Mông Đùi Sau', 'Cable Pull-through',
  'Legs', 'Cable', 'Pull', 'Compound', 'hinge', 'beginner',
  ARRAY['Glutes', 'Hamstrings'],
  ARRAY['Đứng quay lưng lại máy cáp nấc thấp, luồn dây qua hai chân', 'Đẩy hông ra sau cúi người', 'Đẩy hông về trước siết mông đứng thẳng'],
  ARRAY['Squat thay vì Hinge', 'Dùng tay kéo cáp'],
  ARRAY['romanian-deadlift', 'kettlebell-swing'],
  ARRAY['Đứng quay lưng vào cáp thấp', 'Gập hông đưa dây qua hai chân', 'Đẩy hông đứng thẳng dậy']
),
(
  'sissy-squat', 'Sissy Squat', 'Sissy Squat Tập Đùi Trước Tự Do', 'Sissy Squat',
  'Legs', 'Bodyweight', 'Push', 'Isolation', 'squat', 'advanced',
  ARRAY['Quadriceps', 'Core'],
  ARRAY['Đứng nhón gót, thân người ngả về sau', 'Đẩy đầu gối ra trước cảm nhận đùi trước căng tối đa', 'Đẩy lên bằng cơ đùi trước'],
  ARRAY['Gập hông mất độ căng đùi', 'Tập khi khớp gối có tiền sử chấn thương'],
  ARRAY['leg-extension', 'hack-squat-machine'],
  ARRAY['Đứng thẳng nhón gót', 'Đẩy gối ra trước ngả thân ra sau', 'Đạp đùi đứng thẳng dậy']
),
(
  'bodyweight-air-squat', 'Bodyweight Air Squat', 'Squat Tay Không (Air Squat)', 'Bodyweight Air Squat',
  'Legs', 'Bodyweight', 'Push', 'Compound', 'squat', 'beginner',
  ARRAY['Quadriceps', 'Glutes'],
  ARRAY['Chân rộng bằng vai, mũi chân mở', 'Hạ mông ra sau như ngồi vào ghế', 'Đứng thẳng dậy siết mông'],
  ARRAY['Nhấc gót chân', 'Đầu gối khép vào trong'],
  ARRAY['goblet-squat', 'barbell-squat'],
  ARRAY['Đứng thẳng hai chân mở rộng', 'Hạ người xuống ngồi xổm', 'Đứng thẳng dậy']
),
(
  'jump-squat', 'Jump Squat', 'Squat Bật Nhảy Tăng Sức Bật', 'Jump Squat',
  'Legs', 'Bodyweight', 'Push', 'Compound', 'squat', 'intermediate',
  ARRAY['Quadriceps', 'Calves', 'Glutes'],
  ARRAY['Hạ người tư thế squat', 'Bật nhảy dứt khoát lên cao', 'Tiếp đất êm ái bằng mũi bàn chân chuyển sang squat'],
  ARRAY['Tiếp đất bằng gót chân gây chấn động khớp', 'Đầu gối chụm khi bật'],
  ARRAY['bodyweight-air-squat', 'burpee'],
  ARRAY['Hạ người squat', 'Bật nhảy mạnh mẽ lên không trung', 'Tiếp đất êm và hạ người lặp lại']
),
(
  'cossack-squat', 'Cossack Squat', 'Squat Sang Ngang Từng Bên (Cossack Squat)', 'Cossack Squat',
  'Legs', 'Bodyweight', 'Push', 'Compound', 'lunge', 'intermediate',
  ARRAY['Adductors', 'Glutes', 'Hamstrings'],
  ARRAY['Đứng chân rất rộng', 'Dồn trọng lượng squat sâu sang một bên, chân kia duỗi thẳng nhón gót', 'Đổi bên linh hoạt'],
  ARRAY['Nhấc gót chân bên squat', 'Gù cong cột sống'],
  ARRAY['curtsy-lunge', 'bulgarian-split-squat'],
  ARRAY['Đứng dạng chân rộng', 'Hạ thấp người sang một bên chân', 'Đổi trọng tâm sang chân còn lại']
),
(
  'curtsy-lunge', 'Curtsy Lunge', 'Bước Chéo Chân Sau Tập Mông Đùi Ngoài', 'Curtsy Lunge',
  'Legs', 'Dumbbell', 'Push', 'Compound', 'lunge', 'intermediate',
  ARRAY['Glutes', 'Adductors'],
  ARRAY['Bước chân chéo về phía sau góc 45 độ như cúi chào', 'Hạ thấp đùi cảm nhận cơ mông nhỡ căng', 'Đứng lên đổi chân'],
  ARRAY['Vặn khớp gối quá mức', 'Nghiêng thân người'],
  ARRAY['reverse-lunge', 'walking-lunge'],
  ARRAY['Đứng thẳng cầm tạ', 'Bước một chân chéo ra sau', 'Hạ gối rồi đứng dậy']
),
(
  'cable-glute-kickback', 'Cable Glute Kickback', 'Đá Cáp Về Sau Tập Cơ Mông', 'Cable Glute Kickback',
  'Legs', 'Cable', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Glutes', 'Hamstrings'],
  ARRAY['Gắn đai cổ chân vào cáp thấp', 'Đá thẳng chân ra sau siết chặt cơ mông', 'Thu chân về có kiểm soát'],
  ARRAY['Võng lưng dưới để đá cao', 'Vung chân lấy đà'],
  ARRAY['barbell-hip-thrust', 'hip-abduction-machine'],
  ARRAY['Móc cáp vào cổ chân', 'Đá chân thẳng ra sau siết mông', 'Thu chân về từ từ']
),
(
  'hip-abduction-machine', 'Hip Abduction Machine', 'Máy Banh Đùi Tập Cơ Mông Nhỡ', 'Hip Abduction Machine',
  'Legs', 'Machine', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Gluteus Medius'],
  ARRAY['Ngồi thẳng hoặc hơi nghiêng người về trước', 'Mở rộng hai đùi ép vào đệm máy', 'Giữ căng ở điểm mở rộng nhất'],
  ARRAY['Khép chân quá nhanh làm tạ rơi', 'Rời lưng khỏi đệm'],
  ARRAY['cable-glute-kickback', 'curtsy-lunge'],
  ARRAY['Ngồi vào máy banh đùi', 'Mở hai chân sang hai bên', 'Khép chân lại có kiểm soát']
),
(
  'hip-adduction-machine', 'Hip Adduction Machine', 'Máy Ép Đùi Trong', 'Hip Adduction Machine',
  'Legs', 'Machine', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Adductors'],
  ARRAY['Mở chân rộng, đặt đệm mặt trong đùi', 'Ép hai chân lại gần nhau', 'Thả chân mở ra chậm rãi'],
  ARRAY['Dùng đà giật tạ', 'Mở chân quá rộng gây căng cơ háng'],
  ARRAY['cossack-squat', 'sumo-deadlift'],
  ARRAY['Ngồi vào máy ép đùi trong', 'Ép hai chân lại sát nhau', 'Thả ra từ từ']
),
(
  'nordic-hamstring-curl', 'Nordic Hamstring Curl', 'Gập Đùi Sau Kiểu Bắc Âu (Nordic Curl)', 'Nordic Hamstring Curl',
  'Legs', 'Bodyweight', 'Pull', 'Compound', 'isolation', 'advanced',
  ARRAY['Hamstrings', 'Calves'],
  ARRAY['Cố định cổ chân chắc chắn dưới bục', 'Hạ thân người thẳng tắp về phía trước có kiểm soát bằng đùi sau', 'Chống nhẹ tay đẩy lên'],
  ARRAY['Gập gãy hông làm mất lực đùi sau', 'Thả rơi người đập mặt xuống sàn'],
  ARRAY['lying-leg-curl', 'seated-leg-curl'],
  ARRAY['Quỳ gối cố định cổ chân', 'Hạ thân người từ từ về phía trước', 'Dùng đùi sau kéo người lên']
),
(
  'smith-machine-squat', 'Smith Machine Squat', 'Squat Với Khung Smith', 'Smith Machine Squat',
  'Legs', 'Machine', 'Push', 'Compound', 'squat', 'beginner',
  ARRAY['Quadriceps', 'Glutes'],
  ARRAY['Đặt chân hơi nhích về trước một chút', 'Hạ mông squat sâu có điểm tựa vững chắc', 'Đẩy tạ đứng lên'],
  ARRAY['Khóa khớp gối quá mạnh', 'Đặt chân quá xa làm trượt'],
  ARRAY['barbell-squat', 'hack-squat-machine'],
  ARRAY['Vào vị trí dưới thanh đòn Smith', 'Mở khóa tạ và hạ người squat', 'Đẩy lên khóa tạ an toàn']
),

-- ==============================================================================
-- 4. SHOULDERS (22 Exercises)
-- ==============================================================================
(
  'barbell-overhead-press', 'Overhead Press (Barbell)', 'Đẩy Vai Đòn Đứng (OHP)', 'Barbell Overhead Press',
  'Shoulders', 'Barbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Triceps', 'Upper Chest', 'Core'],
  ARRAY['Đứng chân rộng bằng hông, gồng chặt cơ bụng và mông', 'Nắm thanh đòn rộng hơn vai một chút, cùi chỏ hướng nhẹ về trước', 'Đẩy tạ thẳng đứng lên qua đầu, khóa hông vững chắc', 'Hạ thanh đòn về lại trước xương quai xanh'],
  ARRAY['Ưỡn lưng dưới quá mức để đẩy tạ', 'Nhún chân lấy đà (thành Push Press)', 'Đẩy tạ ra xa phía trước đầu'],
  ARRAY['seated-dumbbell-shoulder-press', 'seated-barbell-overhead-press'],
  ARRAY['Đứng thẳng, thanh đòn trước vai', 'Đẩy thanh đòn lên quá đầu', 'Hạ thanh đòn xuống trước vai']
),
(
  'dumbbell-lateral-raise', 'Lateral Raise (Dumbbell)', 'Nâng Tạ Đơn Sang Ngang (Vai Giữa)', 'Dumbbell Lateral Raise',
  'Shoulders', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Front Deltoids', 'Traps'],
  ARRAY['Đứng thẳng hoặc hơi nghiêng người về trước nhẹ', 'Khuỷu tay hơi chùng, nâng hai cánh tay sang ngang ngang vai', 'Cổ tay không cao hơn khuỷu tay ở đỉnh', 'Hạ tạ xuống có kiểm soát'],
  ARRAY['Vung tạ dùng đà thân người', 'Nhún vai (dùng cơ cầu vai thay vì vai giữa)', 'Nâng tạ cao quá vai'],
  ARRAY['cable-lateral-raise', 'band-overhead-pull-apart'],
  ARRAY['Đứng thẳng, tạ đôi hai bên hông', 'Nâng hai tay sang ngang cao bằng vai', 'Hạ tạ xuống hai bên hông']
),
(
  'cable-face-pull', 'Face Pull (Cable)', 'Kéo Cáp Vào Mặt (Face Pull)', 'Cable Face Pull',
  'Shoulders', 'Cable', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Rear Deltoids', 'Rotator Cuff', 'Rhomboids'],
  ARRAY['Chỉnh ròng rọc ngang tầm mắt hoặc cao hơn nhẹ', 'Cầm dây thừng bằng ngón cái hướng về sau', 'Kéo dây về phía mắt/trán, xoay ngoài khớp vai', 'Tách hai đầu dây thừng sang hai bên ở điểm kết thúc'],
  ARRAY['Kéo khuỷu tay chúc xuống dưới', 'Dùng tạ quá nặng ngửa người về sau', 'Không xoay ngoài vai'],
  ARRAY['rear-delt-dumbbell-fly', 'reverse-pec-deck-fly'],
  ARRAY['Đứng trước máy cáp cao', 'Kéo dây về phía mặt, khuỷu tay sang hai bên', 'Để dây đi ra chậm rãi']
),
(
  'seated-dumbbell-shoulder-press', 'Seated Dumbbell Shoulder Press', 'Ngồi Đẩy Vai Với Tạ Đơn', 'Seated Dumbbell Shoulder Press',
  'Shoulders', 'Dumbbell', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Triceps', 'Upper Chest'],
  ARRAY['Ngồi ghế tựa lưng 75-80 độ', 'Hạ tạ ngang tầm tai khuỷu tay góc 75 độ', 'Đẩy tạ lên đỉnh không chạm nhau'],
  ARRAY['Ưỡn cong thắt lưng', 'Khuỷu tay bẹt sang hai bên 90 độ'],
  ARRAY['barbell-overhead-press', 'arnold-press'],
  ARRAY['Ngồi trên ghế có tựa lưng', 'Hai tay cầm hai tạ đơn ngang vai', 'Đẩy tạ lên qua đầu và hạ xuống']
),
(
  'arnold-press', 'Arnold Press', 'Đẩy Vai Xoay Cổ Tay (Arnold Press)', 'Arnold Press',
  'Shoulders', 'Dumbbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Front Deltoids', 'Side Deltoids', 'Triceps'],
  ARRAY['Bắt đầu tạ trước ngực lòng bàn tay hướng vào người', 'Đẩy tạ lên đồng thời xoay lòng bàn tay hướng ra trước', 'Hạ tạ xoay ngược lại'],
  ARRAY['Xoay giật cục mất kiểm soát', 'Dùng tạ quá nặng gây quá tải khớp xoay'],
  ARRAY['seated-dumbbell-shoulder-press', 'barbell-overhead-press'],
  ARRAY['Cầm tạ trước ngực lòng bàn tay hướng vào trong', 'Đẩy lên đồng thời xoay tay ra ngoài', 'Hạ xuống xoay về vị trí cũ']
),
(
  'standing-dumbbell-shoulder-press', 'Standing Dumbbell Shoulder Press', 'Đứng Đẩy Vai Với Tạ Đơn', 'Standing Dumbbell Shoulder Press',
  'Shoulders', 'Dumbbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Triceps', 'Core'],
  ARRAY['Đứng thẳng gồng cơ bụng', 'Đẩy tạ đơn thẳng lên qua đầu', 'Hạ tạ ngang tầm cằm'],
  ARRAY['Nhún chân lấy đà', 'Ngả lưng ra sau'],
  ARRAY['barbell-overhead-press', 'seated-dumbbell-shoulder-press'],
  ARRAY['Đứng thẳng hai tay giữ tạ ngang vai', 'Đẩy tạ qua đầu', 'Hạ tạ có kiểm soát']
),
(
  'seated-barbell-overhead-press', 'Seated Barbell Overhead Press', 'Ngồi Ghế Đẩy Tạ Đòn Qua Đầu', 'Seated Barbell Overhead Press',
  'Shoulders', 'Barbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Triceps'],
  ARRAY['Ngồi ghế tựa lưng vững', 'Hạ thanh đòn xuống xương quai xanh', 'Đẩy tạ thẳng lên trên'],
  ARRAY['Đập tạ vào cằm', 'Cong lưng dưới'],
  ARRAY['barbell-overhead-press', 'seated-dumbbell-shoulder-press'],
  ARRAY['Ngồi trên ghế băng', 'Đẩy thanh đòn từ vai lên qua đầu', 'Hạ thanh đòn xuống chậm']
),
(
  'cable-lateral-raise', 'Cable Lateral Raise', 'Kéo Cáp Sang Ngang Tập Vai Giữa', 'Cable Lateral Raise',
  'Shoulders', 'Cable', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Side Deltoids'],
  ARRAY['Cáp nấc thấp luồn sau lưng hoặc trước đùi', 'Nâng tay sang ngang ngang tầm vai', 'Duy trì lực căng liên tục của cáp'],
  ARRAY['Nhún người giật cáp', 'Nâng quá cao hơn vai'],
  ARRAY['dumbbell-lateral-raise', 'reverse-pec-deck-fly'],
  ARRAY['Đứng cạnh máy cáp thấp', 'Kéo tay cầm sang ngang vai', 'Hạ tay về chậm rãi']
),
(
  'dumbbell-front-raise', 'Dumbbell Front Raise', 'Nâng Tạ Đơn Phía Trước Tập Vai Trước', 'Dumbbell Front Raise',
  'Shoulders', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Front Deltoids'],
  ARRAY['Cầm tạ đơn trước đùi', 'Nâng tạ thẳng ra trước mặt ngang tầm mắt', 'Hạ tạ từ từ'],
  ARRAY['Vung thân người lấy đà', 'Nâng quá cao trên đầu'],
  ARRAY['barbell-front-raise', 'cable-lateral-raise'],
  ARRAY['Đứng thẳng tạ trước đùi', 'Nâng tạ thẳng lên trước mặt', 'Hạ tạ xuống từ từ']
),
(
  'barbell-front-raise', 'Barbell Front Raise', 'Nâng Tạ Đòn Phía Trước', 'Barbell Front Raise',
  'Shoulders', 'Barbell', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Front Deltoids'],
  ARRAY['Cầm thanh đòn rộng bằng vai', 'Nâng đòn tạ lên ngang cằm', 'Hạ tạ có kiểm soát'],
  ARRAY['Ngả người về sau', 'Gập khuỷu tay'],
  ARRAY['dumbbell-front-raise', 'cable-lateral-raise'],
  ARRAY['Cầm thanh tạ đòn trước đùi', 'Nâng tạ lên ngang tầm mắt', 'Hạ tạ xuống chậm']
),
(
  'rear-delt-dumbbell-fly', 'Rear Delt Dumbbell Fly', 'Cúi Người Banh Tạ Đơn Tập Vai Sau', 'Rear Delt Dumbbell Fly',
  'Shoulders', 'Dumbbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Rear Deltoids', 'Rhomboids'],
  ARRAY['Gập người góc gần song song sàn, lưng thẳng', 'Nâng tạ sang hai bên hướng cùi chỏ lên trần', 'Ép chặt cơ vai sau'],
  ARRAY['Đứng dậy dùng đà', 'Kéo bằng cơ lưng xô thay vì vai sau'],
  ARRAY['reverse-pec-deck-fly', 'cable-face-pull'],
  ARRAY['Cúi người gập hông lưng thẳng', 'Nâng hai tạ sang hai bên', 'Hạ tạ xuống chậm']
),
(
  'reverse-pec-deck-fly', 'Reverse Pec Deck Fly', 'Ép Vai Sau Với Máy Pec Deck Ngược', 'Reverse Pec Deck Fly',
  'Shoulders', 'Machine', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Rear Deltoids', 'Rhomboids'],
  ARRAY['Ngồi quay mặt vào máy, ngực áp đệm', 'Nắm tay cầm mở sang hai bên cảm nhận cơ vai sau', 'Giữ căng ở điểm mở rộng nhất'],
  ARRAY['Nhún vai rụt cổ', 'Rời ngực khỏi đệm'],
  ARRAY['rear-delt-dumbbell-fly', 'cable-rear-delt-crossover'],
  ARRAY['Ngồi áp ngực vào máy', 'Banh hai tay ra phía sau', 'Thu tay về chậm rãi']
),
(
  'upright-row-barbell', 'Barbell Upright Row', 'Kéo Tạ Đòn Dọc Thân Lên Cằm', 'Barbell Upright Row',
  'Shoulders', 'Barbell', 'Pull', 'Compound', 'pull', 'intermediate',
  ARRAY['Side Deltoids', 'Traps', 'Biceps'],
  ARRAY['Nắm đòn rộng bằng vai', 'Kéo thanh đòn sát thân người lên ngang ngực cùi chỏ cao hơn cổ tay', 'Hạ tạ xuống chậm'],
  ARRAY['Nắm quá hẹp gây chèn ép khớp vai', 'Giật tạ đột ngột'],
  ARRAY['upright-row-cable', 'dumbbell-lateral-raise'],
  ARRAY['Cầm tạ đòn trước đùi', 'Kéo tạ lên dọc thân ngực', 'Hạ tạ xuống từ từ']
),
(
  'upright-row-cable', 'Cable Upright Row', 'Kéo Cáp Dọc Thân Lên Cằm', 'Cable Upright Row',
  'Shoulders', 'Cable', 'Pull', 'Compound', 'pull', 'beginner',
  ARRAY['Side Deltoids', 'Traps'],
  ARRAY['Kéo thanh cáp thẳng lên ngang ngực', 'Cùi chỏ luôn dẫn đầu đường kéo', 'Hạ tạ giữ độ căng'],
  ARRAY['Cổ tay cao hơn cùi chỏ', 'Ngửa người'],
  ARRAY['upright-row-barbell', 'cable-face-pull'],
  ARRAY['Đứng trước cáp thấp', 'Kéo thanh bar lên ngang ngực', 'Hạ tay về vị trí cũ']
),
(
  'machine-shoulder-press', 'Machine Shoulder Press', 'Máy Đẩy Vai Ngồi', 'Machine Shoulder Press',
  'Shoulders', 'Machine', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Triceps'],
  ARRAY['Chỉnh ghế tay cầm ngang vai', 'Đẩy tay cầm thẳng lên qua đầu', 'Hạ xuống chậm'],
  ARRAY['Khóa cùi chỏ giật mạnh', 'Nhấc lưng dưới'],
  ARRAY['seated-dumbbell-shoulder-press', 'barbell-overhead-press'],
  ARRAY['Ngồi vào máy đẩy vai', 'Đẩy hai tay cầm lên cao', 'Hạ tay về ngang cằm']
),
(
  'landmine-press', 'Landmine Press', 'Đẩy Tạ Đòn Chân Cố Định (Landmine Press)', 'Landmine Press',
  'Shoulders', 'Barbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Upper Chest', 'Triceps', 'Core'],
  ARRAY['Một tay cầm đầu thanh đòn landmine đặt trước vai', 'Đẩy tạ chéo lên trước khóa khớp vai an toàn', 'Hạ về có kiểm soát'],
  ARRAY['Vặn người quá mức', 'Nhún gối mượn đà'],
  ARRAY['seated-dumbbell-shoulder-press', 'incline-dumbbell-bench-press'],
  ARRAY['Cầm đầu tạ landmine trước vai', 'Đẩy tạ chéo lên phía trước', 'Hạ tạ về vai']
),
(
  'cable-rear-delt-crossover', 'Cable Rear Delt Crossover', 'Banh Cáp Chéo Tay Tập Vai Sau', 'Cable Rear Delt Crossover',
  'Shoulders', 'Cable', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Rear Deltoids'],
  ARRAY['Cáp cao không gắn tay cầm, tay trái bắt cáp phải và ngược lại', 'Kéo hai tay mở rộng sang hai bên', 'Ép chặt cơ vai sau'],
  ARRAY['Gập cùi chỏ biến thành kéo tay sau', 'Vung thân người'],
  ARRAY['reverse-pec-deck-fly', 'rear-delt-dumbbell-fly'],
  ARRAY['Cầm chéo hai dây cáp cao', 'Banh hai tay ra hai bên vai', 'Thu tay về chậm']
),
(
  'pike-push-up', 'Pike Push-up', 'Hít Đất Dốc Hình Chữ V Tập Vai', 'Pike Push-up',
  'Shoulders', 'Bodyweight', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Triceps', 'Upper Chest'],
  ARRAY['Nhô mông lên cao tạo góc chữ V ngược', 'Hạ đầu về phía trước hai bàn tay', 'Đẩy người lên về lại tư thế chữ V'],
  ARRAY['Trượt chân', 'Hạ đỉnh đầu vuông góc thay vì hơi tiến về trước'],
  ARRAY['handstand-push-up', 'barbell-overhead-press'],
  ARRAY['Tạo tư thế chữ V ngược', 'Hạ đỉnh đầu xuống sàn', 'Đẩy người lên']
),
(
  'handstand-push-up', 'Handstand Push-up', 'Hít Đất Trồng Chuối', 'Handstand Push-up',
  'Shoulders', 'Bodyweight', 'Push', 'Compound', 'push', 'advanced',
  ARRAY['Triceps', 'Upper Back', 'Core'],
  ARRAY['Trồng chuối tựa chân vào tường', 'Hạ đầu xuống có kiểm soát chạm đệm', 'Đẩy mạnh mẽ thẳng tay lên'],
  ARRAY['Võng lưng hình trái chuối', 'Thả rơi tự do gây chấn thương cổ'],
  ARRAY['pike-push-up', 'barbell-overhead-press'],
  ARRAY['Trồng chuối dựa tường', 'Hạ đầu chạm nhẹ sàn', 'Đẩy tay thẳng lên vị trí ban đầu']
),
(
  'dumbbell-scaption', 'Dumbbell Scaption', 'Nâng Tạ Đơn Góc 45 Độ Khớp Vai', 'Dumbbell Scaption',
  'Shoulders', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY['Serratus Anterior', 'Supraspinatus'],
  ARRAY['Nâng tạ ở góc 30-45 độ so với mặt phẳng ngực (mặt phẳng bả vai)', 'Ngón cái hơi hướng lên trên', 'Hạ tạ có kiểm soát'],
  ARRAY['Nâng tạ nặng vung người', 'Khóa cứng cổ tay'],
  ARRAY['dumbbell-lateral-raise', 'dumbbell-front-raise'],
  ARRAY['Đứng thẳng tạ hai bên', 'Nâng tạ theo góc chéo 45 độ', 'Hạ tạ xuống từ từ']
),
(
  'lu-raise', 'Lu Raise', 'Nâng Tạ Qua Đầu Vòng Cung (Lu Raise)', 'Lu Raise',
  'Shoulders', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'intermediate',
  ARRAY['Side Deltoids', 'Traps'],
  ARRAY['Nâng tạ từ hai bên đùi theo vòng cung tròn lên chạm nhẹ qua đầu', 'Kiểm soát nhịp hạ xuống rộng'],
  ARRAY['Dùng tạ nặng', 'Khóa cùi chỏ'],
  ARRAY['dumbbell-lateral-raise', 'dumbbell-scaption'],
  ARRAY['Cầm tạ đơn nhẹ hai bên', 'Nâng tạ vòng cung qua đầu', 'Hạ tạ vòng cung xuống']
),
(
  'band-overhead-pull-apart', 'Band Overhead Pull-apart', 'Banh Dây Kháng Lực Qua Đầu', 'Band Overhead Pull-apart',
  'Shoulders', 'Resistance Band', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Rear Deltoids', 'Rotator Cuff'],
  ARRAY['Hai tay giữ dây trên đầu', 'Kéo dây sang hai bên hạ xuống ngang vai sau', 'Siết chặt cơ bả vai'],
  ARRAY['Ưỡn ngực cong lưng', 'Thả tay nhanh'],
  ARRAY['resistance-band-pull-apart', 'cable-face-pull'],
  ARRAY['Giơ dây kháng lực lên trên đầu', 'Kéo banh hai tay sang hai bên', 'Thu tay về vị trí cũ']
),

-- ==============================================================================
-- 5. ARMS (24 Exercises - 12 Biceps, 12 Triceps)
-- ==============================================================================
(
  'barbell-bicep-curl', 'Bicep Curl (Barbell)', 'Cuốn Tay Trước Với Tạ Đòn', 'Barbell Bicep Curl',
  'Arms', 'Barbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Forearms'],
  ARRAY['Đứng thẳng, cùi chỏ ép sát hai bên sườn', 'Cuộn thanh đòn lên hướng về phía ngực', 'Gồng cơ bắp tay ở đỉnh 1 giây', 'Hạ thanh đòn xuống chậm rãi có kiểm soát'],
  ARRAY['Vung thân người lấy đà', 'Đưa cùi chỏ ra trước quá nhiều', 'Không duỗi hết tay khi hạ tạ'],
  ARRAY['ez-bar-bicep-curl', 'incline-dumbbell-curl'],
  ARRAY['Đứng thẳng, nắm thanh đòn lòng bàn tay hướng lên', 'Cuộn thanh đòn lên phía vai', 'Hạ thanh đòn xuống chậm rãi']
),
(
  'dumbbell-hammer-curl', 'Hammer Curl (Dumbbell)', 'Cuốn Búa Với Tạ Đơn (Hammer Curl)', 'Dumbbell Hammer Curl',
  'Arms', 'Dumbbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Brachialis', 'Forearms'],
  ARRAY['Hai lòng bàn tay hướng vào nhau (Neutral grip)', 'Giữ cùi chỏ cố định sát thân người', 'Nâng tạ lên như động tác gõ búa', 'Hạ tạ chậm rãi'],
  ARRAY['Vung tay và vai', 'Xoay cổ tay khi cuốn tạ'],
  ARRAY['cable-rope-hammer-curl', 'barbell-bicep-curl'],
  ARRAY['Đứng thẳng, nắm tạ đôi lòng bàn tay hướng vào nhau', 'Cuộn tạ lên giống như cầm búa', 'Hạ tạ xuống chậm rãi']
),
(
  'cable-tricep-pushdown', 'Tricep Pushdown (Cable)', 'Kéo Cáp Tay Sau Xuống (Tricep Pushdown)', 'Cable Tricep Pushdown',
  'Arms', 'Cable', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Đứng thẳng hoặc hơi cúi nhẹ người về trước', 'Cùi chỏ ghim cố định hai bên sườn', 'Đẩy thanh bar/dây cáp xuống cho tới khi khóa thẳng tay sau', 'Kiểm soát đường lên tới góc 90 độ ở khuỷu tay'],
  ARRAY['Để cùi chỏ di chuyển tự do ra trước sau', 'Dùng trọng lượng cơ thể đè lên thanh đòn'],
  ARRAY['barbell-skull-crusher', 'overhead-cable-tricep-extension'],
  ARRAY['Đứng trước máy cáp', 'Đẩy thanh cầm xuống dưới cho đến khi thẳng tay', 'Để thanh cầm đi lên chậm rãi']
),
(
  'barbell-skull-crusher', 'Skull Crusher (Barbell)', 'Nằm Duỗi Tay Sau Với Tạ Đòn (Skull Crusher)', 'Barbell Skull Crusher',
  'Arms', 'Barbell', 'Push', 'Isolation', 'isolation', 'intermediate',
  ARRAY[]::text[],
  ARRAY['Nằm trên ghế phẳng, cầm tạ đòn thẳng trên ngực', 'Hơi nghiêng cánh tay trên về phía sau đầu vài độ', 'Chỉ gập cẳng tay hạ tạ xuống trán hoặc đỉnh đầu', 'Đẩy tạ về lại vị trí ban đầu bằng cơ tay sau'],
  ARRAY['Khuỷu tay bẹt sang hai bên quá rộng', 'Di chuyển toàn bộ cánh tay thay vì chỉ gập khuỷu'],
  ARRAY['cable-tricep-pushdown', 'overhead-cable-tricep-extension'],
  ARRAY['Nằm ngửa trên ghế', 'Hạ thanh đòn xuống phía trán', 'Đẩy thanh đòn lên vị trí ban đầu']
),
(
  'ez-bar-bicep-curl', 'EZ Bar Bicep Curl', 'Cuốn Tay Trước Thanh Đòn Z (EZ Bar)', 'EZ Bar Bicep Curl',
  'Arms', 'Barbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Forearms'],
  ARRAY['Nắm vị trí uốn lượn giảm áp lực cổ tay', 'Cố định cùi chỏ cuốn tạ lên ngực', 'Hạ tạ có kiểm soát'],
  ARRAY['Đung đưa lưng', 'Nâng cùi chỏ lên cao'],
  ARRAY['barbell-bicep-curl', 'dumbbell-hammer-curl'],
  ARRAY['Cầm thanh đòn EZ bar', 'Cuốn tạ lên phía ngực', 'Hạ tạ xuống chậm']
),
(
  'incline-dumbbell-curl', 'Incline Dumbbell Curl', 'Ngồi Ghế Dốc Cuốn Tạ Đơn Căng Bắp Tay', 'Incline Dumbbell Curl',
  'Arms', 'Dumbbell', 'Pull', 'Isolation', 'isolation', 'intermediate',
  ARRAY[]::text[],
  ARRAY['Ngồi ghế dốc 45-60 độ, cánh tay thả thẳng', 'Cuốn tạ lên xoay cổ tay ngửa tối đa', 'Cảm nhận độ giãn đỉnh cao của đầu dài bắp tay'],
  ARRAY['Nhấc vai lên để kéo tạ', 'Đưa cùi chỏ về trước'],
  ARRAY['barbell-bicep-curl', 'spider-curl'],
  ARRAY['Ngồi ghế dốc ngả lưng', 'Cuốn hai quả tạ đơn lên', 'Hạ tay xuống hết biên độ']
),
(
  'preacher-curl-barbell', 'Preacher Curl With Barbell', 'Cuốn Tay Trước Trên Bàn Đệm (Preacher)', 'Preacher Curl',
  'Arms', 'Barbell', 'Pull', 'Isolation', 'isolation', 'intermediate',
  ARRAY['Brachialis'],
  ARRAY['Áp sát nách và cánh tay trên vào mặt đệm nghiêng', 'Hạ tạ gần hết tay không khóa khớp', 'Cuốn tạ lên siết chặt bắp tay'],
  ARRAY['Duỗi thẳng tay giật khớp cùi chỏ ở đáy', 'Nhấc mông khỏi ghế'],
  ARRAY['spider-curl', 'dumbbell-concentration-curl'],
  ARRAY['Tựa hai tay lên bàn đệm', 'Cuốn thanh tạ lên đỉnh', 'Hạ tạ xuống chậm']
),
(
  'dumbbell-concentration-curl', 'Concentration Curl', 'Ngồi Cuốn Tạ Đơn Tựa Đùi (Concentration Curl)', 'Concentration Curl',
  'Arms', 'Dumbbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Ngồi tựa khuỷu tay vào mặt trong đùi cùng bên', 'Cuộn tạ lên siết đỉnh 2 giây', 'Hạ tạ từ từ'],
  ARRAY['Nhấc cùi chỏ khỏi đùi', 'Vung thân người'],
  ARRAY['preacher-curl-barbell', 'incline-dumbbell-curl'],
  ARRAY['Ngồi trên ghế, tựa khuỷu tay vào đùi trong', 'Cuốn quả tạ lên sát ngực', 'Hạ tạ xuống chậm']
),
(
  'cable-bicep-curl', 'Cable Bicep Curl', 'Cuốn Tay Trước Với Máy Cáp Dưới', 'Cable Bicep Curl',
  'Arms', 'Cable', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Forearms'],
  ARRAY['Đứng trước ròng rọc thấp', 'Kéo thanh bar cuộn lên giữ độ căng liên tục', 'Hạ xuống chậm rãi'],
  ARRAY['Ngửa người về sau', 'Đưa cùi chỏ ra trước'],
  ARRAY['barbell-bicep-curl', 'ez-bar-bicep-curl'],
  ARRAY['Cầm thanh cáp thấp', 'Cuốn cáp lên ngực', 'Thả tạ xuống chậm']
),
(
  'cable-rope-hammer-curl', 'Cable Rope Hammer Curl', 'Cuốn Búa Dây Thừng Với Cáp', 'Cable Rope Hammer Curl',
  'Arms', 'Cable', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Brachialis', 'Forearms'],
  ARRAY['Cầm dây thừng lòng bàn tay hướng vào nhau', 'Kéo cuộn lên tách nhẹ hai đầu dây ở đỉnh', 'Hạ xuống giữ cơ căng'],
  ARRAY['Khép cùi chỏ giật mạnh', 'Vung người'],
  ARRAY['dumbbell-hammer-curl', 'reverse-curl-barbell'],
  ARRAY['Cầm dây thừng máy cáp thấp', 'Cuộn dây lên tách hai bên', 'Hạ tạ chậm rãi']
),
(
  'spider-curl', 'Spider Curl', 'Nằm Ghế Dốc Sấp Cuốn Bắp Tay (Spider Curl)', 'Spider Curl',
  'Arms', 'Dumbbell', 'Pull', 'Isolation', 'isolation', 'intermediate',
  ARRAY[]::text[],
  ARRAY['Nằm sấp ngực tựa ghế dốc 45 độ', 'Hai cánh tay vuông góc với sàn', 'Cuộn tạ lên cô lập hoàn toàn cơ bắp tay'],
  ARRAY['Đung đưa cánh tay lấy đà', 'Nhấc ngực khỏi ghế'],
  ARRAY['preacher-curl-barbell', 'dumbbell-concentration-curl'],
  ARRAY['Nằm sấp ngực trên ghế dốc', 'Cuốn hai tạ đơn lên ngực', 'Hạ tạ thẳng xuống sàn']
),
(
  'reverse-curl-barbell', 'Barbell Reverse Curl', 'Cuốn Tạ Đòn Cổ Tay Ngược Tập Cẳng Tay', 'Barbell Reverse Curl',
  'Arms', 'Barbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Brachioradialis', 'Forearms'],
  ARRAY['Cầm thanh đòn mu bàn tay hướng lên trên', 'Cuộn tạ lên tập trung cơ cẳng tay ngoài', 'Hạ tạ chậm'],
  ARRAY['Gập cổ tay quá mức', 'Dùng tạ quá nặng'],
  ARRAY['dumbbell-hammer-curl', 'dumbbell-wrist-curl'],
  ARRAY['Cầm đòn tạ úp mu bàn tay lên', 'Cuốn tạ lên ngang vai', 'Hạ tạ chậm']
),
(
  'dumbbell-wrist-curl', 'Dumbbell Wrist Curl', 'Cuộn Cổ Tay Tạ Đơn Tập Cẳng Tay Trong', 'Dumbbell Wrist Curl',
  'Arms', 'Dumbbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Forearms'],
  ARRAY['Cẳng tay tựa trên đùi cổ tay thò ra ngoài gối', 'Cuộn cổ tay lên tối đa', 'Thả tạ lướt nhẹ ngón tay'],
  ARRAY['Nhấc cẳng tay khỏi đùi', 'Giật tạ mạnh'],
  ARRAY['reverse-wrist-curl', 'reverse-curl-barbell'],
  ARRAY['Tựa cẳng tay lên đùi ngửa cổ tay', 'Cuộn cổ tay lên cao', 'Hạ tạ xuống hết cỡ']
),
(
  'reverse-wrist-curl', 'Reverse Wrist Curl', 'Cuộn Ngược Cổ Tay Tập Cẳng Tay Ngoài', 'Reverse Wrist Curl',
  'Arms', 'Dumbbell', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Forearms'],
  ARRAY['Cẳng tay tựa đùi mu bàn tay hướng lên', 'Gập cổ tay ngược lên trên', 'Hạ tạ xuống từ từ'],
  ARRAY['Dùng tạ nặng làm đau khớp cổ tay', 'Vung tay'],
  ARRAY['dumbbell-wrist-curl', 'reverse-curl-barbell'],
  ARRAY['Tựa cẳng tay úp mu bàn tay lên', 'Gập cổ tay ngược lên', 'Hạ tạ xuống chậm']
),
(
  'overhead-cable-tricep-extension', 'Overhead Cable Tricep Extension', 'Kéo Cáp Qua Đầu Tập Tay Sau Dây Thừng', 'Overhead Cable Tricep Extension',
  'Arms', 'Cable', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Quay lưng vào máy cáp nấc ngang hoặc cao, cầm dây thừng sau gáy', 'Duỗi thẳng hai tay ra trước qua đầu', 'Khóa cùi chỏ cố định góc'],
  ARRAY['Mở toang cùi chỏ sang hai bên', 'Võng lưng'],
  ARRAY['cable-tricep-pushdown', 'dumbbell-overhead-tricep-extension'],
  ARRAY['Đứng quay lưng vào máy cáp', 'Đẩy dây thừng từ sau đầu ra trước', 'Thu tay về sau đầu có kiểm soát']
),
(
  'tricep-bench-dip', 'Tricep Bench Dip', 'Chống Tay Xuống Ghế Tập Tay Sau (Bench Dip)', 'Tricep Bench Dip',
  'Arms', 'Bodyweight', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Anterior Deltoids'],
  ARRAY['Hai tay chống mép ghế phẳng phía sau lưng', 'Hạ mông sát mép ghế cùi chỏ góc 90 độ', 'Đẩy thẳng tay lên'],
  ARRAY['Đưa mông ra quá xa ghế gây chấn thương vai', 'Hạ quá sâu'],
  ARRAY['parallel-bar-tricep-dip', 'close-grip-bench-press'],
  ARRAY['Chống hai tay sau mép ghế', 'Hạ thân người xuống sàn', 'Đẩy thẳng tay đưa người lên']
),
(
  'close-grip-bench-press', 'Close-grip Bench Press', 'Đẩy Tạ Đòn Tay Hẹp Tập Tay Sau', 'Close-grip Bench Press',
  'Arms', 'Barbell', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Chest', 'Anterior Deltoids'],
  ARRAY['Nắm thanh đòn rộng bằng vai (không quá hẹp)', 'Hạ thanh đòn sát sườn chạm ngực dưới', 'Đẩy tạ thẳng lên tập trung cơ tay sau'],
  ARRAY['Cầm tay quá sát nhau (<20cm) làm đau cổ tay', 'Xòe khuỷu tay'],
  ARRAY['barbell-bench-press', 'parallel-bar-tricep-dip'],
  ARRAY['Nằm ghế phẳng cầm tạ tay hẹp bằng vai', 'Hạ tạ chạm ngực cùi chỏ ép sườn', 'Đẩy dứt khoát lên']
),
(
  'parallel-bar-tricep-dip', 'Parallel Bar Tricep Dip', 'Chống Xà Kép Thẳng Lưng Tập Tay Sau', 'Parallel Bar Tricep Dip',
  'Arms', 'Bodyweight', 'Push', 'Compound', 'push', 'advanced',
  ARRAY['Chest', 'Shoulders'],
  ARRAY['Giữ thân người thẳng đứng tối đa', 'Khuỷu tay khép sát thân người', 'Hạ người xuống góc 90 độ rồi đẩy lên dứt khoát'],
  ARRAY['Nghiêng người về trước (chuyển sang ngực)', 'Hạ quá sâu gây áp lực vai'],
  ARRAY['chest-dip', 'close-grip-bench-press'],
  ARRAY['Giữ người thẳng đứng trên xà kép', 'Hạ người gập khuỷu tay 90 độ', 'Đẩy thẳng tay lên đỉnh']
),
(
  'dumbbell-overhead-tricep-extension', 'Dumbbell Overhead Tricep Extension', 'Ngồi Duỗi Tạ Đơn Qua Đầu Tập Tay Sau', 'Dumbbell Overhead Tricep Extension',
  'Arms', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Hai tay ôm một quả tạ đơn đưa ra sau gáy', 'Cùi chỏ ép sát đầu hướng lên trần', 'Duỗi cẳng tay đẩy tạ lên cao'],
  ARRAY['Xòe cùi chỏ sang hai bên quá rộng', 'Võng lưng dưới'],
  ARRAY['overhead-cable-tricep-extension', 'barbell-skull-crusher'],
  ARRAY['Ngồi thẳng hai tay ôm tạ đơn sau đầu', 'Duỗi thẳng tay đưa tạ lên trần', 'Hạ tạ xuống sau gáy']
),
(
  'dumbbell-kickback', 'Dumbbell Tricep Kickback', 'Cúi Người Đá Tạ Đơn Về Sau (Kickback)', 'Dumbbell Tricep Kickback',
  'Arms', 'Dumbbell', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Gập người lưng thẳng, nâng cùi chỏ cao song song thân', 'Đá tạ đơn thẳng về sau khóa khớp tay sau', 'Giữ đỉnh 1 giây'],
  ARRAY['Hạ cùi chỏ xuống khi đá', 'Vung tạ lấy đà'],
  ARRAY['cable-kickback', 'cable-tricep-pushdown'],
  ARRAY['Cúi người một tay tựa ghế', 'Đá quả tạ đơn ra sau thẳng cánh tay', 'Thu tạ về góc 90 độ']
),
(
  'cable-kickback', 'Cable Tricep Kickback', 'Kéo Cáp Đá Tay Sau Về Sau', 'Cable Tricep Kickback',
  'Arms', 'Cable', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Cáp nấc ngang không dùng tay cầm, cùi chỏ khóa cố định', 'Duỗi cẳng tay thẳng về sau siết cơ tay sau', 'Thu tay về chậm'],
  ARRAY['Di chuyển cùi chỏ', 'Đung đưa người'],
  ARRAY['dumbbell-kickback', 'cable-tricep-pushdown'],
  ARRAY['Cầm đầu dây cáp ngang hông', 'Đá tay thẳng về phía sau', 'Thu tay về từ từ']
),
(
  'single-arm-cable-pushdown', 'Single-arm Cable Pushdown', 'Đè Cáp Một Tay Tập Đầu Ngoài Tay Sau', 'Single-arm Cable Pushdown',
  'Arms', 'Cable', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Đứng thẳng cùi chỏ ghim sườn', 'Đẩy cáp xuống bằng một tay khóa thẳng', 'Cảm nhận từng bên tay sau'],
  ARRAY['Nhún vai', 'Thả tay nhanh'],
  ARRAY['cable-tricep-pushdown', 'barbell-skull-crusher'],
  ARRAY['Một tay cầm tay nắm cáp cao', 'Đẩy thẳng tay xuống dưới', 'Hạ tạ lên chậm']
),
(
  'ez-bar-french-press', 'EZ Bar French Press', 'Ngồi Duỗi Đòn Z Qua Đầu (French Press)', 'EZ Bar French Press',
  'Arms', 'Barbell', 'Push', 'Isolation', 'isolation', 'intermediate',
  ARRAY[]::text[],
  ARRAY['Ngồi trên ghế dốc đứng cầm thanh EZ bar trên đầu', 'Hạ đòn tạ ra sau đầu', 'Duỗi tay đẩy thanh tạ lên'],
  ARRAY['Xòe cùi chỏ', 'Va tạ vào đầu'],
  ARRAY['dumbbell-overhead-tricep-extension', 'overhead-cable-tricep-extension'],
  ARRAY['Ngồi cầm tạ đòn EZ trên đầu', 'Hạ tạ ra sau gáy', 'Đẩy thẳng tay lên']
),
(
  'diamond-push-up-tricep', 'Diamond Push-up For Triceps', 'Hít Đất Hẹp Tay Tập Tay Sau', 'Diamond Push-up For Triceps',
  'Arms', 'Bodyweight', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Chest', 'Anterior Deltoids'],
  ARRAY['Hai bàn tay sát nhau cùi chỏ ép sát sườn', 'Hạ ngực chạm tay', 'Đẩy dứt khoát tập trung cơ tay sau'],
  ARRAY['Xòe cùi chỏ ra ngoài', 'Chùng lưng'],
  ARRAY['close-grip-bench-press', 'push-up'],
  ARRAY['Chống hai tay sát nhau', 'Hạ thân người xuống sát sàn', 'Đẩy người lên khóa tay sau']
),

-- ==============================================================================
-- 6. CORE (14 Exercises)
-- ==============================================================================
(
  'plank', 'Plank', 'Tư Thế Tấm Ván (Plank)', 'Plank',
  'Core', 'Bodyweight', 'Static', 'Compound', 'carry', 'beginner',
  ARRAY['Shoulders', 'Glutes', 'Lower Back'],
  ARRAY['Chống khuỷu tay thẳng dưới vai', 'Thân người tạo thành một đường thẳng từ vai đến gót', 'Gồng chặt cơ bụng và cơ mông', 'Hít thở đều đặn không nín thở'],
  ARRAY['Võng lưng dưới gây đau cột sống', 'Nhô mông lên quá cao', 'Cúi gập cổ nhìn chân'],
  ARRAY['ab-wheel-rollout', 'side-plank'],
  ARRAY['Chống khuỷu tay và mũi chân xuống sàn', 'Giữ thân người thẳng', 'Giữ nguyên tư thế lâu nhất có thể']
),
(
  'crunch', 'Crunch', 'Gập Bụng Cơ Bản', 'Abdominal Crunch',
  'Core', 'Bodyweight', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Nằm ngửa, đầu gối co, bàn chân chạm sàn', 'Hai tay đặt sau tai hoặc bắt chéo trước ngực', 'Gập cơ bụng nâng bả vai lên khỏi sàn 5-10cm', 'Ép lưng dưới xuống sàn khi cuộn bụng'],
  ARRAY['Dùng tay kéo giật cổ về trước', 'Ngồi dậy toàn thân (thành Sit-up) làm mỏi cơ gấp hông'],
  ARRAY['cable-crunch', 'ab-wheel-rollout'],
  ARRAY['Nằm ngửa, chân gập', 'Nhấc vai lên khỏi mặt đất', 'Hạ vai xuống chậm rãi']
),
(
  'leg-raise', 'Leg Raise', 'Nằm Nâng Chân Tập Bụng Dưới', 'Lying Leg Raise',
  'Core', 'Bodyweight', 'Pull', 'Isolation', 'isolation', 'beginner',
  ARRAY['Hip Flexors'],
  ARRAY['Nằm ngửa trên thảm, hai tay đặt dọc thân hoặc lót dưới mông', 'Ép lưng dưới sát sàn nhà', 'Nâng hai chân lên góc 80-90 độ', 'Hạ chân xuống từ từ, không để lưng dưới cong lên'],
  ARRAY['Võng lưng dưới khi hạ chân gây đau thắt lưng', 'Dùng đà văng chân lên'],
  ARRAY['hanging-leg-raise', 'ab-wheel-rollout'],
  ARRAY['Nằm ngửa, hai tay ép sát hông', 'Nâng hai chân lên cao cho đến khi vuông góc sàn', 'Hạ chân xuống nhưng không chạm đất']
),
(
  'hanging-leg-raise', 'Hanging Leg Raise', 'Treo Xà Nâng Chân Tập Bụng Dưới', 'Hanging Leg Raise',
  'Core', 'Bodyweight', 'Pull', 'Compound', 'isolation', 'intermediate',
  ARRAY['Hip Flexors', 'Forearms'],
  ARRAY['Treo người trên xà đơn giữ thân ổn định', 'Cuộn xương chậu nâng chân lên chạm hoặc gần xà', 'Hạ chân chậm tránh đung đưa'],
  ARRAY['Đung đưa người văng chân lấy đà', 'Chỉ nâng chân không cuộn xương chậu'],
  ARRAY['leg-raise', 'captain-chair-leg-raise'],
  ARRAY['Bám vào thanh xà đơn', 'Nâng hai chân lên vuông góc thân người', 'Hạ chân xuống có kiểm soát']
),
(
  'cable-crunch', 'Cable Kneeling Crunch', 'Quỳ Gập Bụng Kéo Dây Cáp', 'Cable Kneeling Crunch',
  'Core', 'Cable', 'Push', 'Isolation', 'isolation', 'beginner',
  ARRAY[]::text[],
  ARRAY['Quỳ trước máy cáp cao, hai tay cầm dây thừng đặt hai bên đầu', 'Cố định hông, cuộn cột sống gập cùi chỏ về phía đùi', 'Ép chặt bụng ở đáy'],
  ARRAY['Gập bằng khớp hông thay vì cuộn cơ bụng', 'Kéo bằng lực cánh tay'],
  ARRAY['crunch', 'ab-wheel-rollout'],
  ARRAY['Quỳ gối giữ dây thừng ngang tai', 'Gập cuộn cơ bụng xuống sàn', 'Nhả người lên chậm']
),
(
  'ab-wheel-rollout', 'Ab Wheel Rollout', 'Lăn Bánh Xe Tập Cơ Bụng (Ab Wheel)', 'Ab Wheel Rollout',
  'Core', 'Bodyweight', 'Pull', 'Compound', 'carry', 'advanced',
  ARRAY['Lats', 'Shoulders', 'Lower Back'],
  ARRAY['Quỳ gối trên thảm, hai tay cầm hai bên bánh xe', 'Lăn bánh xe từ từ về trước giữ lưng hơi gù nhẹ (khóa bụng)', 'Dùng cơ bụng kéo bánh xe trở lại vị trí cũ'],
  ARRAY['Võng thắt lưng gây chấn thương lưng dưới', 'Lăn quá xa mất kiểm soát'],
  ARRAY['plank', 'hollow-body-hold'],
  ARRAY['Quỳ trên sàn cầm con lăn', 'Lăn bánh xe thẳng ra phía trước', 'Dùng cơ bụng kéo người trở lại']
),
(
  'russian-twist', 'Russian Twist', 'Xoay Thân Ngồi Tập Cơ Bụng Chéo', 'Russian Twist',
  'Core', 'Bodyweight', 'Static', 'Isolation', 'isolation', 'beginner',
  ARRAY['Obliques'],
  ARRAY['Ngồi trên thảm, chân nhấc nhẹ khỏi sàn, thân ngả 45 độ', 'Xoay thân người lần lượt sang hai bên chạm tay xuống sàn', 'Giữ hông cố định'],
  ARRAY['Chỉ xoay cánh tay mà không xoay thân ngực', 'Gù cong lưng'],
  ARRAY['woodchopper-cable', 'side-plank'],
  ARRAY['Ngồi ngả lưng co chân khỏi sàn', 'Xoay thân người sang trái rồi sang phải', 'Duy trì nhịp thở đều']
),
(
  'side-plank', 'Side Plank', 'Plank Nghiêng Tập Bụng Nghiêng Và Cân Bằng', 'Side Plank',
  'Core', 'Bodyweight', 'Static', 'Isolation', 'carry', 'beginner',
  ARRAY['Obliques', 'Gluteus Medius'],
  ARRAY['Nằm nghiêng chống khuỷu tay vuông góc dưới vai', 'Nâng hông lên tạo thành đường thẳng từ vai đến chân', 'Giữ nguyên vị trí'],
  ARRAY['Hông bị xệ chúc xuống sàn', 'Xoay thân người chúi về trước'],
  ARRAY['plank', 'pallof-press'],
  ARRAY['Nằm nghiêng chống một khuỷu tay', 'Nâng hông tạo thân người thẳng', 'Giữ nguyên tư thế']
),
(
  'pallof-press', 'Pallof Press', 'Đứng Kháng Xoay Với Cáp (Pallof Press)', 'Pallof Press',
  'Core', 'Cable', 'Static', 'Isolation', 'carry', 'beginner',
  ARRAY['Obliques', 'Core'],
  ARRAY['Đứng vuông góc với máy cáp ngang ngực', 'Giữ hai tay cầm cáp trước ngực, đẩy thẳng ra trước kháng lại lực kéo xoay', 'Giữ 2 giây rồi thu về'],
  ARRAY['Để cáp kéo xoay người', 'Nghiêng thân'],
  ARRAY['woodchopper-cable', 'side-plank'],
  ARRAY['Đứng ngang máy cáp hai tay cầm cáp trước ngực', 'Đẩy thẳng hai tay ra trước mặt', 'Thu tay về trước ngực']
),
(
  'woodchopper-cable', 'Cable Woodchopper', 'Chém Cáp Chéo Tập Cơ Bụng Xiên', 'Cable Woodchopper',
  'Core', 'Cable', 'Pull', 'Compound', 'isolation', 'intermediate',
  ARRAY['Obliques', 'Shoulders'],
  ARRAY['Cáp nấc cao, hai tay cầm kéo chém chéo xuống hông đối diện', 'Xoay thân người dùng lực cơ liên sườn', 'Kiểm soát nhịp quay về'],
  ARRAY['Dùng tay kéo thay vì xoay thân eo', 'Xoay trẹo khớp gối'],
  ARRAY['russian-twist', 'pallof-press'],
  ARRAY['Cáp đặt vị trí cao', 'Xoay người chém cáp chéo xuống hông bên kia', 'Thả người về vị trí ban đầu']
),
(
  'mountain-climber', 'Mountain Climber', 'Đạp Chân Leo Núi Nhanh (Mountain Climber)', 'Mountain Climber',
  'Core', 'Bodyweight', 'Push', 'Compound', 'isolation', 'beginner',
  ARRAY['Shoulders', 'Hip Flexors', 'Cardio'],
  ARRAY['Tư thế plank cao tay thẳng', 'Luân phiên kéo gối về phía ngực nhịp nhàng nhanh', 'Giữ hông ổn định không nhấp nhô'],
  ARRAY['Nhô mông lên trời', 'Chạm chân xuống sàn khi kéo gối'],
  ARRAY['plank', 'burpee'],
  ARRAY['Tư thế chống đẩy', 'Kéo luân phiên từng gối lên ngực nhanh', 'Duy trì nhịp độ ổn định']
),
(
  'hollow-body-hold', 'Hollow Body Hold', 'Tư Thế Thuyền Rỗng Gồng Bụng Thắt Lưng', 'Hollow Body Hold',
  'Core', 'Bodyweight', 'Static', 'Isolation', 'carry', 'intermediate',
  ARRAY['Hip Flexors', 'Quadriceps'],
  ARRAY['Nằm ngửa hai tay duỗi qua đầu hai chân thẳng', 'Ép chặt lưng dưới xuống sàn, nâng vai và chân lên tạo hình thuyền rỗng', 'Giữ nguyên'],
  ARRAY['Lưng dưới bị cong hổng khỏi sàn', 'Gập cổ'],
  ARRAY['plank', 'deadbug'],
  ARRAY['Nằm ngửa nâng nhẹ vai và chân khỏi sàn', 'Ép lưng dưới sát thảm', 'Giữ nguyên tư thế']
),
(
  'deadbug', 'Dead Bug', 'Tư Thế Bọ Chết Khóa Lưng Dưới (Dead Bug)', 'Dead Bug',
  'Core', 'Bodyweight', 'Static', 'Isolation', 'isolation', 'beginner',
  ARRAY['Core Stability'],
  ARRAY['Nằm ngửa giơ hai tay lên trần gối gập 90 độ', 'Hạ đồng thời tay phải và chân trái sát sàn giữ lưng dính chặt đất', 'Đổi bên nhịp nhàng'],
  ARRAY['Hổng lưng dưới khi duỗi chân', 'Chuyển động quá nhanh'],
  ARRAY['hollow-body-hold', 'plank'],
  ARRAY['Nằm ngửa giơ tay gập gối', 'Hạ chéo tay và chân chạm sàn', 'Thu về đổi bên còn lại']
),
(
  'dragon-flag', 'Dragon Flag', 'Cờ Rồng Nâng Thân Tập Bụng Đỉnh Cao', 'Dragon Flag',
  'Core', 'Bodyweight', 'Pull', 'Compound', 'carry', 'advanced',
  ARRAY['Lats', 'Glutes', 'Core'],
  ARRAY['Nằm trên ghế hai tay bám mép ghế sau đầu', 'Nâng toàn bộ thân người thẳng tắp lên trời tựa trên bả vai', 'Hạ thân người thẳng từ từ không gãy hông'],
  ARRAY['Võng gãy hông biến dạng', 'Thả rơi người đập lưng'],
  ARRAY['hanging-leg-raise', 'hollow-body-hold'],
  ARRAY['Nằm nắm mép ghế sau đầu', 'Nâng toàn thân thẳng lên cao', 'Hạ từ từ xuống không chạm ghế']
),

-- ==============================================================================
-- 7. FULL BODY (6 Exercises)
-- ==============================================================================
(
  'burpee', 'Burpee', 'Nhảy Bật Hít Đất Toàn Thân (Burpee)', 'Burpee',
  'Full Body', 'Bodyweight', 'Push', 'Compound', 'push', 'intermediate',
  ARRAY['Chest', 'Quadriceps', 'Core', 'Cardio'],
  ARRAY['Từ tư thế đứng nhảy lùi hai chân về sau thành plank', 'Hạ ngực chạm sàn hít đất', 'Bật hai chân lên thu về và nhảy vọt lên cao vỗ tay qua đầu'],
  ARRAY['Võng lưng khi chạm đất', 'Tiếp đất cứng gót chân'],
  ARRAY['jump-squat', 'mountain-climber'],
  ARRAY['Ngồi xổm chống tay xuống sàn', 'Bật chân ra sau hít đất', 'Thu chân và nhảy bật lên cao']
),
(
  'kettlebell-swing', 'Kettlebell Swing', 'Vung Tạ Ấm (Kettlebell Swing)', 'Kettlebell Swing',
  'Full Body', 'Dumbbell', 'Pull', 'Compound', 'hinge', 'intermediate',
  ARRAY['Glutes', 'Hamstrings', 'Lower Back', 'Shoulders'],
  ARRAY['Đẩy hông ra sau luồn tạ giữa hai chân', 'Bùng nổ lực khớp hông vung tạ lên ngang ngực', 'Khóa chặt cơ mông ở đỉnh'],
  ARRAY['Squat thay vì Hinge', 'Dùng cánh tay nâng tạ lên'],
  ARRAY['barbell-deadlift', 'cable-pull-through'],
  ARRAY['Hai tay nắm quai tạ ấm', 'Đẩy hông ra sau vung tạ qua háng', 'Đẩy hông mạnh về trước vung tạ ngang ngực']
),
(
  'barbell-clean-and-press', 'Barbell Clean and Press', 'Cử Giật Nâng Tạ Qua Đầu Toàn Thân', 'Barbell Clean and Press',
  'Full Body', 'Barbell', 'Push', 'Compound', 'push', 'advanced',
  ARRAY['Shoulders', 'Glutes', 'Traps', 'Legs', 'Back'],
  ARRAY['Kéo thanh đòn từ sàn dứt khoát lên vai trước (Clean)', 'Ổn định thăng bằng đẩy thẳng tạ lên qua đầu (Press)', 'Hạ tạ có kiểm soát'],
  ARRAY['Gù lưng khi nâng từ sàn', 'Đẩy tạ khi cơ thể chưa ổn định'],
  ARRAY['barbell-snatch', 'thruster'],
  ARRAY['Kéo tạ từ sàn lên vai trước', 'Ổn định thân người', 'Đẩy tạ qua đầu đứng thẳng']
),
(
  'barbell-snatch', 'Barbell Snatch', 'Cử Giật Đòn Tạ Nhanh (Snatch)', 'Barbell Snatch',
  'Full Body', 'Barbell', 'Pull', 'Compound', 'pull', 'advanced',
  ARRAY['Full Body', 'Shoulders', 'Glutes', 'Core'],
  ARRAY['Cầm tay rộng kéo tạ từ sàn trong một chuyển động liên tục bùng nổ', 'Đón tạ trên đầu trong tư thế squat sâu', 'Đứng thẳng dậy'],
  ARRAY['Tách rời nhịp kéo', 'Mất thăng bằng cổ tay'],
  ARRAY['barbell-clean-and-press', 'thruster'],
  ARRAY['Cầm tạ đòn tay rộng', 'Giật tạ một nhịp lên qua đầu', 'Đón tạ ngồi sâu và đứng dậy']
),
(
  'thruster', 'Dumbbell Thruster', 'Squat Kết Hợp Đẩy Vai (Thruster)', 'Dumbbell Thruster',
  'Full Body', 'Dumbbell', 'Push', 'Compound', 'squat', 'intermediate',
  ARRAY['Quadriceps', 'Glutes', 'Shoulders', 'Triceps'],
  ARRAY['Giữ tạ trên vai squat sâu', 'Đạp đứng dậy tận dụng lực đẩy tạ thẳng lên qua đầu trong một nhịp', 'Hạ tạ về vai khi bắt đầu squat'],
  ARRAY['Dừng lại ngắt quãng giữa squat và đẩy vai', 'Gập lưng khi squat'],
  ARRAY['barbell-clean-and-press', 'goblet-squat'],
  ARRAY['Cầm tạ trên vai ngồi squat sâu', 'Đạp đứng dậy đẩy tạ qua đầu', 'Hạ tạ lặp lại liên tục']
),
(
  'farmers-walk', 'Farmer''s Walk', 'Xách Tạ Đi Bộ (Farmer''s Walk)', 'Farmer''s Walk',
  'Full Body', 'Dumbbell', 'Static', 'Compound', 'carry', 'intermediate',
  ARRAY['Forearms', 'Traps', 'Core', 'Calves'],
  ARRAY['Cầm hai tạ nặng hai bên tay thẳng', 'Ưỡn ngực kéo vai sau gồng chặt bụng', 'Bước đi những bước ngắn đều vững chắc'],
  ARRAY['Nghiêng ngả người hoặc gù lưng', 'Bước chân quá dài mất thăng bằng'],
  ARRAY['plank', 'dumbbell-shrug'],
  ARRAY['Hai tay xách hai tạ nặng', 'Giữ thân người thẳng tắp', 'Bước đi cự ly quy định']
),

-- ==============================================================================
-- 8. CARDIO (6 Exercises)
-- ==============================================================================
(
  'jumping-jack', 'Jumping Jack', 'Nhảy Bật Tách Tay Chân (Jumping Jack)', 'Jumping Jack',
  'Cardio', 'Bodyweight', 'Push', 'Compound', 'push', 'beginner',
  ARRAY['Calves', 'Shoulders', 'Cardio'],
  ARRAY['Đứng thẳng khép chân', 'Bật nhảy tách hai chân sang hai bên đồng thời vỗ tay qua đầu', 'Bật khép về vị trí ban đầu nhịp nhàng'],
  ARRAY['Tiếp đất bằng gót chân', 'Không thẳng tay'],
  ARRAY['jump-rope', 'burpee'],
  ARRAY['Đứng thẳng khép chân tay xuôi', 'Bật nhảy tách chân vỗ tay trên đầu', 'Bật về vị trí ban đầu']
),
(
  'treadmill-running', 'Treadmill Running', 'Chạy Bộ Trên Máy Chạy', 'Treadmill Running',
  'Cardio', 'Machine', 'Push', 'Compound', 'carry', 'beginner',
  ARRAY['Cardiovascular System', 'Legs', 'Calves'],
  ARRAY['Giữ tư thế chạy thẳng người hơi đổ nhẹ về trước', 'Tiếp đất bằng giữa bàn chân', 'Đánh tay nhịp nhàng'],
  ARRAY['Nhìn xuống chân gây mất thăng bằng', 'Tiếp đất nặng nề bằng gót'],
  ARRAY['stationary-bike', 'rowing-machine'],
  ARRAY['Khởi động máy chạy bộ', 'Chạy với tốc độ đều đặn', 'Hạ nhiệt dần trước khi dừng']
),
(
  'stationary-bike', 'Stationary Bike Cycling', 'Đạp Xe Đạp Tại Chỗ', 'Stationary Bike Cycling',
  'Cardio', 'Machine', 'Push', 'Compound', 'squat', 'beginner',
  ARRAY['Quadriceps', 'Calves', 'Cardio'],
  ARRAY['Chỉnh yên xe ngang tầm xương hông', 'Đạp đều tròn vòng chân', 'Giữ lưng thoải mái'],
  ARRAY['Yên xe quá thấp làm đau đầu gối', 'Gồng cứng vai'],
  ARRAY['treadmill-running', 'rowing-machine'],
  ARRAY['Ngồi lên xe đạp điều chỉnh yên', 'Đạp đều chân với kháng lực phù hợp', 'Duy trì nhịp thở']
),
(
  'rowing-machine', 'Rowing Machine (Ergometer)', 'Chèo Thuyền Trên Máy (Rowing Machine)', 'Rowing Machine',
  'Cardio', 'Machine', 'Pull', 'Compound', 'pull', 'intermediate',
  ARRAY['Back', 'Legs', 'Biceps', 'Cardio'],
  ARRAY['Thực hiện đúng thứ tự: Đạp chân -> Ngả lưng -> Kéo tay', 'Thu về theo thứ tự ngược lại: Duỗi tay -> Gập lưng -> Thu chân', 'Giữ nhịp thở đều'],
  ARRAY['Kéo tay trước khi đạp chân', 'Gù cong lưng'],
  ARRAY['cable-lat-pulldown', 'stationary-bike'],
  ARRAY['Cố định chân vào bàn đạp máy chèo', 'Đạp mạnh chân ngả lưng kéo tay cầm về ngực', 'Trả tay về trước và co chân lại']
),
(
  'jump-rope', 'Jump Rope', 'Nhảy Dây Đơn (Jump Rope)', 'Jump Rope',
  'Cardio', 'Bodyweight', 'Push', 'Compound', 'carry', 'beginner',
  ARRAY['Calves', 'Forearms', 'Cardio'],
  ARRAY['Khuỷu tay sát sườn xoay bằng cổ tay', 'Bật nhảy nhẹ nhàng 2-3cm bằng mũi chân', 'Tiếp đất êm ái'],
  ARRAY['Vung cả cánh tay để xoay dây', 'Bật nhảy quá cao làm mất sức'],
  ARRAY['jumping-jack', 'treadmill-running'],
  ARRAY['Cầm hai đầu dây nhảy', 'Xoay cổ tay quăng dây qua chân', 'Bật nhảy nhẹ nhàng liên tục']
),
(
  'battle-ropes', 'Battle Ropes', 'Đập Dây Thừng Chiến Thuật (Battle Ropes)', 'Battle Ropes',
  'Cardio', 'Bodyweight', 'Pull', 'Compound', 'push', 'intermediate',
  ARRAY['Shoulders', 'Arms', 'Core', 'Cardio'],
  ARRAY['Đứng tư thế nửa squat vững chắc', 'Hai tay cầm hai đầu dây thừng đập sóng luân phiên hoặc đồng thời', 'Gồng chặt cơ bụng'],
  ARRAY['Đứng thẳng lưng mất trọng tâm', 'Nín thở'],
  ARRAY['burpee', 'kettlebell-swing'],
  ARRAY['Cầm hai đầu dây thừng lớn', 'Đập dây tạo sóng liên tục', 'Duy trì nhịp đập tốc độ cao']
)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_vi = EXCLUDED.name_vi,
  name_en = EXCLUDED.name_en,
  category = EXCLUDED.category,
  equipment = EXCLUDED.equipment,
  force_type = EXCLUDED.force_type,
  mechanic = EXCLUDED.mechanic,
  movement_pattern = EXCLUDED.movement_pattern,
  difficulty = EXCLUDED.difficulty,
  secondary_muscles = EXCLUDED.secondary_muscles,
  form_cues = EXCLUDED.form_cues,
  common_mistakes = EXCLUDED.common_mistakes,
  alternative_exercise_slugs = EXCLUDED.alternative_exercise_slugs,
  instructions = EXCLUDED.instructions;

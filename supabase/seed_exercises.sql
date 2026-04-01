-- ==============================================================================
-- SEED DATA CHO BẢNG PUBLIC.EXERCISES
-- ==============================================================================

TRUNCATE public.exercises;

INSERT INTO public.exercises (name, category, equipment, force_type, mechanic, instructions)
VALUES
-- Chest
('Bench Press (Barbell)', 'Chest', 'Barbell', 'Push', 'Compound', ARRAY['Nằm ngửa trên ghế tập trung', 'Hạ thanh đòn xuống ngực', 'Đẩy thanh đòn lên cao']),
('Incline Bench Press (Dumbbell)', 'Chest', 'Dumbbell', 'Push', 'Compound', ARRAY['Nằm trên ghế dốc lên 30-45 độ', 'Đẩy tạ đôi lên cao', 'Hạ tạ xuống phía trên ngực']),
('Chest Fly (Machine)', 'Chest', 'Machine', 'Push', 'Isolation', ARRAY['Ngồi vào máy ép ngực', 'Mở rộng hai tay sang ngang', 'Ép hai tay lại gần nhau ở phía trước']),
('Push-up', 'Chest', 'Bodyweight', 'Push', 'Compound', ARRAY['Tư thế plank cao', 'Hạ người xuống gần mặt đất', 'Đẩy người lên vị trí cũ']),

-- Back
('Deadlift (Barbell)', 'Back', 'Barbell', 'Pull', 'Compound', ARRAY['Đứng chân rộng bằng vai', 'Nắm thanh đòn dưới sàn', 'Kéo thanh đòn lên cao theo thân người']),
('Pull-up', 'Back', 'Bodyweight', 'Pull', 'Compound', ARRAY['Bám vào thanh xà ngang', 'Kéo thân người lên cao cho đến khi cằm qua xà', 'Hạ người xuống chậm rãi']),
('Lat Pulldown (Cable)', 'Back', 'Cables', 'Pull', 'Compound', ARRAY['Ngồi vào máy kéo xô', 'Kéo thanh bar xuống phía trên ngực', 'Để thanh bar đi lên chậm rãi']),
('Seated Cable Row', 'Back', 'Cables', 'Pull', 'Compound', ARRAY['Ngồi vào máy chèo cáp', 'Kéo tay cầm về phía sát bụng', 'Giữ lưng thẳng trong suốt quá trình']),

-- Legs
('Squat (Barbell)', 'Legs', 'Barbell', 'Push', 'Compound', ARRAY['Đặt thanh đòn trên vai sau', 'Hạ mông xuống cho đến khi đùi song song sàn', 'Đẩy người lên lại']),
('Leg Press', 'Legs', 'Machine', 'Push', 'Compound', ARRAY['Ngồi vào máy đạp đùi', 'Đẩy bàn đạp ra xa', 'Hạ bàn đạp xuống gần ngực']),
('Leg Extension', 'Legs', 'Machine', 'Push', 'Isolation', ARRAY['Ngồi vào máy đá đùi', 'Đá thẳng chân lên cao', 'Hạ chân xuống chậm rãi']),
('Lying Leg Curl', 'Legs', 'Machine', 'Pull', 'Isolation', ARRAY['Nằm sấp vào máy cuốn đùi', 'Cuộn chân về phía mông', 'Duỗi chân ra chậm rãi']),

-- Shoulders
('Overhead Press (Barbell)', 'Shoulders', 'Barbell', 'Push', 'Compound', ARRAY['Đứng thẳng, thanh đòn trước vai', 'Đẩy thanh đòn lên quá đầu', 'Hạ thanh đòn xuống trước vai']),
('Lateral Raise (Dumbbell)', 'Shoulders', 'Dumbbell', 'Push', 'Isolation', ARRAY['Đứng thẳng, tạ đôi hai bên hông', 'Nâng hai tay sang ngang cao bằng vai', 'Hạ tạ xuống hai bên hông']),
('Face Pull (Cable)', 'Shoulders', 'Cables', 'Pull', 'Compound', ARRAY['Đứng trước máy cáp cao', 'Kéo dây về phía mặt, khuỷu tay sang hai bên', 'Để dây đi ra chậm rãi']),

-- Arms
('Bicep Curl (Barbell)', 'Arms', 'Barbell', 'Pull', 'Isolation', ARRAY['Đứng thẳng, nắm thanh đòn lòng bàn tay hướng lên', 'Cuộn thanh đòn lên phía vai', 'Hạ thanh đòn xuống chậm rãi']),
('Hammer Curl (Dumbbell)', 'Arms', 'Dumbbell', 'Pull', 'Isolation', ARRAY['Đứng thẳng, nắm tạ đôi lòng bàn tay hướng vào nhau', 'Cuộn tạ lên giống như cầm búa', 'Hạ tạ xuống chậm rãi']),
('Tricep Pushdown (Cable)', 'Arms', 'Cables', 'Push', 'Isolation', ARRAY['Đứng trước máy cáp', 'Đẩy thanh cầm xuống dưới cho đến khi thẳng tay', 'Để thanh cầm đi lên chậm rãi']),
('Skull Crusher (Barbell)', 'Arms', 'Barbell', 'Push', 'Isolation', ARRAY['Nằm ngửa trên ghế', 'Hạ thanh đòn xuống phía trán', 'Đẩy thanh đòn lên vị trí ban đầu']),

-- Core
('Plank', 'Core', 'Bodyweight', 'Static', 'Compound', ARRAY['Chống khuỷu tay và mũi chân xuống sàn', 'Giữ thân người thẳng', 'Giữ nguyên tư thế lâu nhất có thể']),
('Crunch', 'Core', 'Bodyweight', 'Push', 'Isolation', ARRAY['Nằm ngửa, chân gập', 'Nhấc vai lên khỏi mặt đất', 'Hạ vai xuống chậm rãi']),
('Leg Raise', 'Core', 'Bodyweight', 'Pull', 'Isolation', ARRAY['Nằm ngửa, hai tay ép sát hông', 'Nâng hai chân lên cao cho đến khi vuông góc sàn', 'Hạ chân xuống nhưng không chạm đất']);

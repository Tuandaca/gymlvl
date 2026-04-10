-- ==============================================================================
-- SEED DATA FOR QUESTS (ROUTINE TEMPLATES)
-- ==============================================================================

INSERT INTO public.quests (title, description, type, difficulty, category, base_xp)
VALUES 
('NGÀY ĐẨY (PUSH DAY)', 'Tập trung vào Ngực, Vai và Tay sau để xây dựng khung thân trên vững chắc.', 'daily_routine', 'beginner', 'push', 350),
('NGÀY KÉO (PULL DAY)', 'Tập trung vào Lưng xô và Tay trước giúp cải thiện tư thế và sức kéo.', 'daily_routine', 'beginner', 'pull', 350),
('NGÀY TẬP CHÂN (LEGS DAY)', 'Tập trung vào nền móng sức mạnh từ Đùi trước, Đùi sau và Mông.', 'daily_routine', 'beginner', 'legs', 400),
('TOÀN THÂN (FULL BODY)', 'Kích hoạt toàn bộ các nhóm cơ chính trong một buổi tập hiệu quả.', 'daily_routine', 'beginner', 'full_body', 450);

# 📈 Hệ thống Thăng Cấp (Level System) & Đột Phá (Breakthrough)

Ý tưởng của bạn cực kỳ xuất sắc và mang đậm chất **RPG Gamification**. Việc chặn giới hạn cấp độ (Level Cap) và yêu cầu thực hiện "Nhiệm vụ Chuyển Cấp" (Breakthrough Quest) không chỉ tạo động lực cực lớn mà còn giúp User nhận thức rõ ràng sự tiến bộ của bản thân qua từng giai đoạn.

Dưới đây là một bản phác thảo chi tiết (Draft 1.0) để bạn xét duyệt trước khi AI đúc nó thành Code cho Backend.

## 1. Phân Bậc Thể Lực (Titles & Tiers)
Ứng dụng sẽ có 5 Tiers (Bậc) lớn hiện hành, mỗi Bậc tương ứng với 10 Cấp (Levels), với tổng mốc MAX LEVEL hiện tại có thể là 50 (dễ dàng mở khóa thêm Tier 6, 7 trong tương lai).

| Bậc (Tier) | Level Range | Danh Hiệu (Title) VI | Danh Hiệu (Title) EN | Yêu cầu EXP mỗi cấp | Thử Thách Cốt Lõi (Đột Phá) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **I** | 1 - 10 | **Tân Sinh Phấn Tạ** | Chalk Novice | Thấp (Dễ thăng cấp) | Đạt Lv 10 + Vượt qua khóa nền tảng |
| **II** | 11 - 20 | **Kẻ Săn Cơ** | Pump Seeker | Trung Bình | Đạt Lv 20 + Tập luyện kỷ luật 7 ngày |
| **III** | 21 - 30 | **Tay Tạ Sắt** | Iron Lifter | Khá (Tích lũy đều) | Đạt Lv 30 + Bứt phá sức mạnh tạ |
| **IV** | 31 - 40 | **Vóc Dáng Alpha** | Alpha Physique | Gắt gao | Đạt Lv 40 + Hoàn thành lộ trình Elite |
| **V** | 41 - 50 | **Chúa Tể Phòng Gym** | Gym Lord | Cực Hạn | (Chưa mở Giới Hạn) |
| *VI (Tương lai)* | *51 - 60* | *Kẻ Dị Biến Đỉnh Cao* | *Peak Mutant* | *Thần Thoại* | *N/A* |

## 2. Cơ chế Đột Phá (Breakthrough Mechanics)
Khi người dùng đạt Max của một Bậc (Ví dụ: Level 10), THANH EXP của họ sẽ **Bị Khóa (Capped)** ở mức `100/100` và họ sẽ nhận được trạng thái: `"Đang chờ Đột Phá"`.

**Luồng sự kiện (Flow):**
1. Hệ thống tự động phát cho User một Nhiệm vụ đặc biệt (Breakthrough Quest) màu Đỏ/Vàng. Tiêu đề: `"Thử thách Chuyển Cấp: Vượt qua giới hạn Tân Binh"`.
2. Nội dung của thử thách sẽ khó hơn bình thường. Ví dụ: *Tập luyện 5 ngày liên tiếp*, hoặc *hoàn thành chuỗi bài tập mức tạ nặng*.
3. Bất kỳ Exp nào kiếm được trong thời gian "Chờ đột phá" này sẽ được tích lũy vào một kho lưu trữ ẩn (`overflow_xp`), tránh bị uổng phí công sức người tập.
4. Khi User bấm **"Hoàn thành Thử Thách Đột Phá"**, Server:
   - Thăng họ lên Level 11 ngay lập tức.
   - Thăng danh hiệu mới: **Môn Đồ (Apprentice)**.
   - Bơm cục `overflow_xp` trả lại vào thanh kinh nghiệm mới.
   - Phát hiệu ứng pháo hoa, huy hiệu (Badge) trên màn hình app.

## 3. Khởi điểm Đầu Vào (Onboarding Leveling)
Như vậy, dựa trên khảo sát trình độ ở bước Onboarding:

- **Beginner (Mới tập)**: Khởi đầu ở **Level 1** (Tân Binh). Thanh Exp chạy từ số 0. Cần tập làm quen dần để lên Lv 10.
- **Intermediate (Từng tập)**: Khởi đầu thẳng ở **Level 11** (Môn Đồ). Được bỏ qua mốc Tân Binh để phù hợp với trình độ, không bị chán khi phải làm các bài quá rễ.
- **Advanced (Chuyên nghiệp)**: Khởi đầu thẳng ở **Level 21** (Chiến Binh). Sẵn sàng đón nhận các lịch tập hạng nặng.

## 4. Cấu trúc Database (Minh họa cho Edge Function)

Nếu bạn chốt phương án này, ở Bảng `users`, chúng ta sẽ cần thêm một vài trường mới:
```sql
level INTEGER DEFAULT 1,
current_title TEXT DEFAULT 'Tân Sinh Phấn Tạ',
is_capped BOOLEAN DEFAULT FALSE, -- Cờ báo hiệu đang bị kẹt ở mốc x0
overflow_xp INTEGER DEFAULT 0,   -- Điểm dư thừa đang tích lũy
last_workout_date TIMESTAMP WITH TIME ZONE -- Theo dõi thời gian tập gần nhất để tính Decay
```

## 5. Hệ thống Nhiệm vụ Hằng ngày (Daily Quests) & Bonus
Để đảm bảo "Tập đúng, Tập đủ" chứ không phải là "Cày cuốc" (Grinding) đến mức kiệt sức, lượng Kinh nghiệm (EXP) trong ngày **CÓ GIỚI HẠN (Daily Cap)**.
- **Nhiệm vụ cốt lõi (Core Daily)**: Mỗi ngày User sẽ nhận được 3-5 bài tập hoặc hoạt động (VD: Khởi động 5 phút, Số set kéo xà...). Làm xong sẽ nhận 100% EXP.
- **Thử thách phụ (Bonus Challenges)**: Nếu User đã xong Daily Quest mà vẫn "ngứa tay", hệ thống cho phép cuộn ngẫu nhiên ra các Thử Thách Phụ. Khớp với mục tiêu (Giảm cân sẽ là Cardio/Burpee, Tăng cơ sẽ là Hypertrophy...).
- **Giới hạn EXP (Hard Cap)**: Tổng lượng Bonus EXP mỗi ngày không bao giờ được phép vượt quá một mức trần (VD: Tối đa kiếm thêm +50 EXP phụ). Điều này ngăn chặn người dùng cố tình tập kiệt sức (Overtraining) chỉ để được lên level, đồng thời hạn chế tình trạng "Fake data" (khai khống là đang tập).

## 6. Suy Giảm Cơ Bắp - Cơ Chế Kỷ Luật (Muscle/Level Decay)
Quy luật của Gym: *Dùng nó, hoặc mất nó (Use it or lose it)*.
- **Sau 3 ngày không tập (Inactive)**: Hệ thống sẽ gửi cảnh báo: *"Cơ bắp đang rệu rã. Bạn đang mất dần động lực!"*
- **Sau 5 ngày không tập**: Bắt đầu trừ dồn dập EXP mỗi ngày (Penalty).
- **Trừ quá mốc 0 EXP**: Người dùng sẽ bị **Rớt Cấp (Level Down)**.
> **Ngoại lệ (Chế độ Phục hồi / Rest Day)**: Để app công bằng, người dùng có quyền mua (hoặc nhận) các vật phẩm/cờ "Rest Ticket" để báo cho hệ thống biết họ đang nghỉ do ốm/thương tích, qua đó bảo vệ Level của họ trong 1-2 tuần không bị tụt.

## 7. Dynamic Quests (Cập nhật Thuộc tính Động)
Người dùng có thể vào Menu **Hồ Sơ (Profile)** để cập nhật số đo (Cân nặng mới, Chiều cao, Tỷ lệ Mỡ).
- Khi họ vừa cập nhật dữ liệu, thuật toán (Edge Function) trên hệ thống sẽ tự động quét qua và gán lại Thể loại Nhiệm Vụ cho ngày tiếp theo.
- **Ví dụ**: Khi họ cập nhật "Đã có thêm cục Tạ Đơn (Dumbbell) ở nhà", danh sách Nhiệm vụ Hằng ngày cho ngày mai sẽ lập tức xuất hiện các bài tập liên quan tới tạ đơn thay vì chỉ là hít đất chay. Thử thách Đột Phá chuyển cấp cũng tự động scale độ khó dựa theo cân nặng mới nhất của họ!

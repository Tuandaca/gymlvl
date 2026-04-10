# GymLevel Progression & Reward System v1.0

Tài liệu đặc tả hệ thống tính điểm kinh nghiệm (XP) và thăng cấp, đảm bảo tính công bằng và khuyến khích tập luyện thực chất.

## 1. Triết lý thiết kế (Design Philosophy)
- 🚫 **Anti-AFK**: Không cộng điểm dựa trên thời gian trôi qua (Loại bỏ Duration XP) để tránh việc người dùng treo app để "farm" điểm.
- 💪 **Performance-First**: Điểm số tập trung vào khối lượng tập luyện thực tế (Volume) và sự đa dạng (Variety).
- 🎯 **Quest-Centric**: Hoàn thành nhiệm vụ hàng ngày là nguồn XP lớn nhất để tạo thói quen.

---
## 2. Công thức tính XP chuẩn (Standard Workout)

Điểm XP nhận được sau một buổi tập tự do:
`Total XP = (Volume XP + Variety XP) * Streak Multiplier`

### A. Volume XP (Điểm khối lượng)
- **Mỗi hiệp (Set) hoàn thành**: `+10 XP`.
- *Điều kiện*: Phải tích vào dấu check hoàn thành set.

### B. Variety XP (Điểm đa dạng)
- Thưởng cho việc tập nhiều nhóm cơ khác nhau trong cùng buổi.
- **Công thức**: `(Số nhóm cơ - 1) * 15 XP`.
- *Ví dụ*: 
    - Tập 1 nhóm cơ -> `0 XP` bonus.
    - Tập 2 nhóm cơ -> `+15 XP`.
    - Tập 3 nhóm cơ -> `+30 XP`.

### C. Streak Multiplier (Hệ số chuỗi)
- Khuyến khích tập luyện liên tục hàng ngày.
- **Công thức**: `1.0 + (Streak * 0.05)`.
- *Giới hạn*: Tối đa `2.0x` (tương đương chuỗi 20 ngày).

---

## 3. Hệ thống Nhiệm vụ (Daily Quest Reward)

Nếu buổi tập được xác nhận là hoàn thành theo Quest của hệ thống:
`Total XP = (Quest Base XP + Perfect Bonus) * Streak Multiplier`

### A. Quest Base XP
- **Thưởng cố định**: `+300 XP` cho việc hoàn thành tối thiểu 80% lộ trình Quest.

### B. Perfect Session Bonus (Thưởng tuyệt đối)
- Thưởng thêm `+50 XP` nếu người dùng hoàn thành **100% số hiệp** và đạt **đúng hoặc vượt số Reps** yêu cầu trong Quest.

---

## 4. Hệ thống Cấp độ (Leveling)

### A. Công thức tích lũy
- XP cần để đạt Level `N`: `100 * (Level ^ 1.5)`.

### B. Danh hiệu (Titles)
- **Level 5**: Tập Sự
- **Level 10**: Chiến Binh
- **Level 20**: Dũng Sĩ
- **Level 50**: Huyền Thoại
- **Level 100**: Bất Tử

---

## 5. Quy tắc Chống gian lận (Anti-Cheat)
- **Tối đa XP/Buổi**: `500 XP` (ngoại trừ các Quest đặc biệt).
- **Tốc độ bất thường**: Nếu hoàn thành > 4 hiệp/phút, buổi tập đó sẽ bị đánh dấu "Nghi vấn" và chỉ nhận `10 XP` cố định.

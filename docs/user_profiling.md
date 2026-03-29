# 👤 Hệ Thống Phân Loại (User Profiling) & Nhập Môn

Bạn vô cùng tinh tế khi nhận ra không nên nhồi nhét mọi thứ vào `level_system.md`. Chúng ta sẽ tách riêng phần **Thông Số Người Dùng (User Profiling)** thành tài liệu này. Việc thu thập chuẩn xác dữ liệu ở bước Onboarding sẽ là nguồn nhiên liệu để thuật toán A.I (Edge Function) phân phát Nhiệm vụ Hằng Ngày mượt mà nhất.

Dưới đây là đặc tả chi tiết cho luồng 6 Bước Nhập Môn (Onboarding), kết hợp thêm **Ý TƯỞNG MỚI (Hệ Phái - Class System)** mang đậm chất nhập vai mà tôi nghĩ bạn sẽ rất thích!

---

## 1. Môi Trường Tập Luyện (Training Environment)
Xác định vị trí và "vũ khí" của người tập. Bắt buộc phải chọn **1** môi trường chính.
1. 🏛️ **Phòng Gym (Full Equipment)**: Truy cập đầy đủ máy móc, tạ đòn, cáp kéo.
2. 🏠 **Home Gym (Tạ Đơn / Dây Kháng Lực)**: Có trang bị tối giản ở nhà.
3. 🌳 **Tập Chay (Bodyweight / Công viên)**: Chỉ dùng trọng lượng cơ thể (Hít đất, Xà đơn).

*Lưu ý: Nếu họ chọn "Tập Chay", hệ thống tuyệt đối không bao giờ phát nhiệm vụ "Cuốn tạ đơn (Dumbbell Curls)".*

## 2. Mục Tiêu Khắc Kỷ (Core Goals)
Người tập muốn đạt được điều gì? Cho phép chọn **Tối đa 3 mục tiêu** để tập trung.
1. 🛡️ **Giảm Mỡ / Cắt Nét (Fat Loss)**: Ưu tiên nhịp tim, HIIT, Cardio.
2. ⚔️ **Tăng Cơ Bắp (Hypertrophy)**: Ưu tiên tập tạ nặng, số Reps từ 8-12.
3. 🧘 **Calisthenics (Thần Kinh Vận Động)**: Ưu tiên sức mạnh cốt lõi (Core), giữ thăng bằng.
4. ⚡ **Tăng Khung Sức Mạnh (Strength/Powerlifting)**: Tập trung số Reps thấp (1-5), tạ cực nặng.
5. 🏃 **Độ Bền (Endurance/Workout)**: Đạp xe, chạy bộ, tăng thể lực chung.

---

## 💡 Ý Tưởng Thêm: HỆ PHÁI (Class System)
Để app thực sự giống một tựa game RPG, ngay khi người dùng chọn xong *Môi trường* và *Mục tiêu* ở trên, hệ thống sẽ tự động gán cho họ một **Hệ Phái (Class)** hoặc cho họ tự phong tước hiệu. 

Việc chia Class giúp giao diện hồ sơ cực kỳ ngầu, và hệ thống sẽ phong màu sắc riêng biệt:
- **Chiến Binh Sắt (Iron Warrior)**: Sinh ra cho những ai chọn *Tăng cơ + Phòng Gym*. (Biểu tượng: Cây rìu tạ đôi).
- **Lãng Khách Thể Hình (Calisthenic Monk)**: Sinh ra cho những ai chọn *Calisthenic + Tập Chay*. (Biểu tượng: Nắm đấm khí công).
- **Sát Thủ Diệt Mỡ (Fat Slayer)**: Sinh ra cho những ai chọn *Giảm mỡ + Bất kỳ*. (Biểu tượng: Song đao tốc độ).
- **Vệ Binh Sức Bền (Ranger)**: Dành cho môn phái *Endurance / Chạy bộ / Đạp xe*.

## 4. Trình Độ Hiện Tại (Experience Level)
Như đã thiết kế ở `level_system.md`, lựa chọn này quyết định trực tiếp việc người dùng khởi đầu ở Bậc nào.
- 🐣 **Người Mới (Beginner)** 👉 Vào thẳng **Level 1 (Tân Sinh Phấn Tạ)**.
- 🦅 **Nắm Rõ Kỹ Thuật (Intermediate)** 👉 Vào thẳng **Level 11 (Kẻ Săn Cơ)**.
- 🐉 **Chuyên Gia (Advanced)** 👉 Vào thẳng **Level 21 (Tay Tạ Sắt)**.

## 5. Sinh Trắc Học (Biometrics)
Những con số thô để theo dõi tiến độ:
- Tuổi (Age).
- Giới tính (Gender).
- Chiều cao (Height - cm/ft).
- Cân nặng (Weight - kg/lbs).

> [!NOTE]
> Quy tắc thu thập: Ở giao diện App (UI Onboarding), việc chọn Môi trường (Environment) và Mục tiêu (Goals) sẽ sử dụng giao diện thẻ hộp (Card) có icon to rõ rệt để người dùng "chạm là thích". Phần Sinh trắc học sẽ dùng thao tác cuộn số (Wheel Picker) để tránh phải gõ phím quá nhiều.

# 🛡️ Đặc Tả Hệ Thống Đa Phân Lớp (Multi-Class Specification)

Tài liệu này chi tiết hóa cách thức vận hành của hệ thống Phân Lớp trong GymLevel, từ giai đoạn Onboarding đến khi đạt ngưỡng Master.

---

## 1. Hệ Thống Phân Lớp (Class Archetypes)

Người dùng chọn tối đa **2 Lớp** hoạt động song song. Lớp thứ nhất là mục tiêu chính, lớp thứ hai là mục tiêu bổ trợ.

### A. Chi Tiết Các Lớp Căn Bản
| ID | Lớp (Class) | Nhóm Độ Khó | Trọng Tâm (Focus) | Graduation (Lv 20) |
| :--- | :--- | :--- | :--- | :--- |
| **A** | **Fat Slayer** (Fat Loss) | Dễ | Đa dạng, Cardio, Pace | ~6,000 XP |
| **B** | **Recomp Ghost** (Body Recomposition) | Trung Bình | Variety + Volume | ~8,500 XP |
| **C** | **Mass Architect** (Hypertrophy) | Khó | Volume, Reps (8-12) | ~11,000 XP |
| **D** | **Titan Strength** (Strength) | Khó | Trọng lượng (Weight) | ~12,000 XP |
| **E** | **Nitro Athlete** (Functional) | Trung Bình | Tốc độ, Bộc phát | ~9,000 XP |
| **F** | **Enduro Guard** (Endurance) | Dễ | Số hiệp cao, Nghỉ ngắn | ~7,000 XP |
| **G** | **Gravity Defier** (Calisthenics) | Trung Bình | Kỹ thuật Bodyweight | ~9,000 XP |
| **H** | **Apex Competitor** (Bodybuilding) | Cực Khó | Tỉ lệ, Đối xứng, Khắt khe | ~15,000 XP |

---

## 2. Ma Trận Tương Thích & Gợi Ý (Synergy Matrix)

Hệ thống sẽ gợi ý Lớp thứ 2 dựa trên Lớp thứ 1 để đảm bảo lộ trình khoa học.

### A. Quy Tắc Gợi Ý
- **Nếu chọn A (Fat Loss)**: Gợi ý **B (Recomp)** hoặc **C (Hypertrophy)** để giữ cơ khi giảm mỡ.
- **Nếu chọn D (Strength)**: Gợi ý **C (Hypertrophy)** - Lộ trình Power-building.
- **Nếu chọn G (Calisthenics)**: Gợi ý **D (Strength)** - Lộ trìnhWeighted Calisthenics.
- **Nếu chọn C (Hypertrophy)**: Gợi ý **F (Endurance)** hoặc **B (Recomp)**.

### B. Cặp Đôi Hoàn Hảo (Perfect Synergy)
| Cặp Lớp | Tên Lộ Trình | Hiệu Ứng |
| :--- | :--- | :--- |
| **A + B** | **The Shredder** | Tối ưu hóa việc giảm mỡ mà không mất form dáng. |
| **C + D** | **Juggernaut** | Xây dựng khối lượng cơ bắp đi kèm sức mạnh thô. |
| **G + D** | **Cyber Monk** | Làm chủ trọng lượng cơ thể và tạ sắt đồng thời. |
| **E + F** | **First Responder** | Sẵn sàng cho mọi tình huống đòi hỏi thể lực bền bỉ. |

---

## 3. Bảng Yêu Cầu Kinh Nghiệm Chi Tiết (Detailed XP Tables)

Lượng XP cần để thăng cấp được chia thành 2 loại:
- **Interval XP**: Lượng XP cần để đi từ cấp hiện tại lên cấp kế tiếp.
- **Total XP**: Tổng lượng XP tích lũy từ Level 1.

### 🔴 Nhóm Khó & Cực Khó (C, D, H)
*Dành cho mục tiêu xây dựng sức mạnh và thi đấu chuyên nghiệp.*

| Level | Next (Hard) | Total (Hard) | Next (Hardcore) | Total (H-core) | TIER (Bậc) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1-2** | 250 | 380 | 342 | 502 | **TIER I** |
| **2-3** | 333 | 713 | 478 | 980 | (Novice) |
| **3-4** | 401 | 1,114 | 595 | 1,575 | |
| **4-5** | 461 | 1,575 | 702 | 2,277 | |
| **5-6** | 514 | 2,089 | 799 | 3,076 | |
| **6-7** | 564 | 2,653 | 891 | 3,967 | |
| **7-8** | 610 | 3,263 | 978 | 4,945 | |
| **8-9** | 654 | 3,917 | 1,061 | 6,006 | |
| **9-10**| 695 | 4,612 | 1,140 | 7,146 | **BREAKTHROUGH** |
| **10-11**| 734 | 5,346 | 1,218 | 8,364 | **TIER II** |
| **11-12**| 772 | 6,118 | 1,291 | 9,655 | (Pump Seeker)|
| **15-16**| 910 | 9,557 | 1,567 | 15,520 | |
| **19-20**| 1,032 | 13,506 | 1,820 | 22,429 | **GRADUATION** |
| **29-30**| 1,297 | 25,321 | 2,382 | 43,789 | **TIER III** |
| **49-50**| 1,723 | 55,891 | 3,335 | 101,723 | **CHÚA TỂ** |

---

### 🟢 Nhóm Dễ & Trung Bình (A, F, B, E, G)
*Dành cho mục tiêu giảm mỡ, thể lực và Calisthenics.*

| Level | Next (Easy) | Total (Easy) | Next (Medium) | Total (Medium) | TIER (Bậc) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1-2** | 131 | 211 | 173 | 273 | **TIER I** |
| **2-3** | 161 | 372 | 218 | 491 | (Novice) |
| **3-4** | 185 | 557 | 255 | 746 | |
| **4-5** | 204 | 761 | 285 | 1,031 | |
| **9-10** | 276 | 2,009 | 399 | 2,818 | **BREAKTHROUGH** |
| **10-11**| 287 | 2,296 | 418 | 3,236 | **TIER II** |
| **19-20**| 368 | 5,303 | 552 | 7,700 | **GRADUATION** |
| **29-30**| 434 | 9,355 | 664 | 13,861 | **TIER III** |
| **49-50**| 534 | 19,127 | 840 | 29,074 | **CHÚA TỂ** |

> [!NOTE]
> Bảng trên hiển thị các mốc quan trọng. Công thức tính chính xác cho mọi level là:
> **Total_XP = Base * (Level ^ Slope)**
> Trong đó:
> - **Easy**: Base 80, Slope 1.40
> - **Medium**: Base 100, Slope 1.45
> - **Hard**: Base 130, Slope 1.55
> - **Hardcore**: Base 160, Slope 1.65

---

## 4. Cơ Chế Chuyển Lớp & Tốt Nghiệp (Graduation)

- **Mốc Tốt Nghiệp (Graduation)**: Khi một lớp đạt **Level 20**, người dùng được coi là đạt "Nền tảng vững chắc".
- **Switching**: Tại thời điểm này, Slot chứa lớp đó có thể được giải phóng để chọn một lớp mới.
- **Legacy Bonus**: Lớp đã tốt nghiệp sẽ để lại một "Passive Skill" (VD: Master Fat Slayer sẽ tăng vĩnh viễn 2% tốc độ đốt calo).

---

## 5. Đặc Tả Lịch Tập (Onboarding Schedule)

Hệ thống thu thập lịch tập chi tiết để cá nhân hóa thông báo:
- **Số ngày tập/tuần**: 1 -> 7 ngày.
- **Phân loại**: Ngày tập Gym, Ngày tập Home/Calis.
- **Thời gian cụ thể**: Chọn các thứ (Thứ 2 - CN).
- **Logic Nhắc Nhở**: Nếu thứ 2 là ngày tập nhưng đến 20:00 chưa có dữ liệu -> Gửi thông báo hối thúc.

---

## 6. Logic Phân Bổ XP Cho Đa Lớp (XP Allocation)

Khi tập trung 2 lớp (Lớp X và Lớp Y):
1. **Focus Match**: Nếu bài tập trong Workout thuộc mục tiêu của Lớp X -> Lớp X nhận 100% XP.
2. **Focus Mismatch**: Nếu bài tập không liên quan -> Lớp X chỉ nhận 40% XP (XP nền).
3. **Double Focus**: Nếu bài tập thuộc cả 2 (VD: Squat cho cả Strength và Muscle Build) -> Cả 2 nhận 100% XP.

---
*Tài liệu này là chuẩn mực để triển khai Module Progression v2.*

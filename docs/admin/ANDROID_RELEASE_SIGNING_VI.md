# Hướng dẫn ký bản phát hành Android (Release Signing)

**Đối tượng:** chủ dự án / người vận hành có quyền giữ khóa ký.
**Phạm vi:** cấu hình keystore release cho `com.gymlvl.app`, build APK/AAB và kiểm tra chữ ký.
**Trạng thái hiện tại:** chưa có keystore trên máy này, nên `:app:assembleRelease` **cố tình thất bại**
(fail-closed) và chưa có APK/AAB nào được tạo. Tài liệu này mô tả các bước bạn cần tự làm.

> Không có bước nào trong tài liệu này được agent thực hiện tự động. Không commit khóa, mật khẩu, hay
> nội dung `.env`. Không sửa `app/android/app/build.gradle.kts` để bỏ qua cổng kiểm tra.

---

## 0. Điều kiện cần có

| Thành phần | Yêu cầu | Cách kiểm tra |
|---|---|---|
| JDK | 21 (Gradle/AGP hiện tại), đặt qua `JAVA_HOME` | `java -version` phải là 21.x khi `JAVA_HOME` đã trỏ đúng |
| Android SDK | platform `android-36`, build-tools `36.1.0` | `Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\platforms"` |
| `apksigner` | có trong build-tools | `Test-Path "$env:LOCALAPPDATA\Android\Sdk\build-tools\36.1.0\apksigner.bat"` |
| Flutter | đã `flutter doctor` sạch cho Android | `flutter doctor -v` |
| `bundletool` | **tùy chọn**, chỉ cần nếu muốn verify AAB | `bundletool version` (hiện chưa cài trên máy này) |

Trên máy hiện tại, `JAVA_HOME` đang là `C:\Program Files\Android\Android Studio\jbr` (JDK 21) trong khi
`java` trần là 1.8 — luôn build qua `gradlew.bat` hoặc `flutter build`, không gọi `java` trần.

---

## 1. Tạo keystore (chỉ làm một lần, giữ vĩnh viễn)

Chọn một thư mục **ngoài repository**, ví dụ `D:\keys\gymlvl`. Không đặt file `.jks` trong `D:\Projects\gymlvl`.

```powershell
$keyDir = "D:\keys\gymlvl"
New-Item -ItemType Directory -Force -Path $keyDir | Out-Null
& "$env:JAVA_HOME\bin\keytool.exe" -genkeypair -v `
  -keystore "$keyDir\gymlvl-release.jks" `
  -alias gymlvl-release `
  -keyalg RSA -keysize 4096 -validity 10000 `
  -storetype JKS
```

`keytool` sẽ hỏi mật khẩu store, mật khẩu key và thông tin định danh (CN, O, L, ST, C). Ghi lại:

- đường dẫn file keystore,
- **alias** (ví dụ `gymlvl-release`),
- mật khẩu store và mật khẩu key.

**Sao lưu ngay** ít nhất 2 bản ở 2 nơi khác nhau (ví dụ ổ ngoài + trình quản lý mật khẩu). Nếu mất
keystore hoặc mật khẩu, bạn **không thể** phát hành bản cập nhật cho ứng dụng đã cài trên Google Play;
bạn sẽ phải tạo ứng dụng mới với application id mới.

---

## 2. Nạp biến môi trường cho phiên build

Cổng kiểm tra trong `app/android/app/build.gradle.kts` đọc **đúng 4 biến** sau và không có giá trị mặc định:

| Biến | Nội dung |
|---|---|
| `GYMLVL_RELEASE_STORE_FILE` | đường dẫn tuyệt đối tới file `.jks` |
| `GYMLVL_RELEASE_STORE_PASSWORD` | mật khẩu keystore |
| `GYMLVL_RELEASE_KEY_ALIAS` | alias của key |
| `GYMLVL_RELEASE_KEY_PASSWORD` | mật khẩu của key |

Đặt trong **phiên PowerShell hiện tại** (không ghi vào file trong repo):

```powershell
$env:GYMLVL_RELEASE_STORE_FILE     = "D:\keys\gymlvl\gymlvl-release.jks"
$env:GYMLVL_RELEASE_STORE_PASSWORD = "<mật khẩu store>"
$env:GYMLVL_RELEASE_KEY_ALIAS      = "gymlvl-release"
$env:GYMLVL_RELEASE_KEY_PASSWORD   = "<mật khẩu key>"
```

Kiểm tra đã nạp (chỉ in tên biến, không in giá trị):

```powershell
"GYMLVL_RELEASE_STORE_FILE", "GYMLVL_RELEASE_STORE_PASSWORD", "GYMLVL_RELEASE_KEY_ALIAS", "GYMLVL_RELEASE_KEY_PASSWORD" |
  ForEach-Object { "$_ = " + [bool](Get-Item "env:$_" -ErrorAction SilentlyContinue) }
```

Cả 4 dòng phải là `True`. Đóng cửa sổ PowerShell khi xong việc để biến không tồn tại ở phiên khác.

---

## 3. Kiểm tra cổng fail-closed (nên chạy trước)

Trong một cửa sổ **chưa** nạp biến, lệnh sau phải **thất bại** (exit code 1) và liệt kê đủ 4 biến thiếu:

```powershell
cd D:\Projects\gymlvl\app\android
.\gradlew.bat :app:validateReleaseSigningInputs
```

Đây là hành vi đúng: thiếu khóa thì không thể tạo bản release. Không "sửa" lỗi này bằng cách thêm giá trị
giả hay bật lại debug signing.

---

## 4. Build bản release

APK (dùng để cài thử trên máy thật):

```powershell
cd D:\Projects\gymlvl\app
flutter build apk --release
```

AAB (dùng để tải lên Google Play):

```powershell
cd D:\Projects\gymlvl\app
flutter build appbundle --release
```

Đầu ra mong đợi:

- `app\build\app\outputs\flutter-apk\app-release.apk`
- `app\build\app\outputs\bundle\release\app-release.aab`

Nếu cổng kiểm tra báo thiếu biến, quay lại bước 2 — cổng này chạy trước mọi tác vụ đóng gói.

---

## 5. Kiểm tra chữ ký của artifact

APK:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\36.1.0\apksigner.bat" verify --verbose --print-certs `
  "D:\Projects\gymlvl\app\build\app\outputs\flutter-apk\app-release.apk"
```

Kết quả phải có `Verifies` và `Verified using v2 scheme (APK Signature Scheme v2): true`.

AAB (chỉ khi đã cài `bundletool`):

```powershell
bundletool validate --bundle "D:\Projects\gymlvl\app\build\app\outputs\bundle\release\app-release.aab"
```

Máy hiện tại **chưa có `bundletool`**, nên bước verify AAB chưa thực hiện được; nếu bạn chỉ cần APK thì
có thể bỏ qua bước này và ghi rõ là chưa verify AAB.

---

## 6. Lỗi thường gặp

| Thông báo | Nguyên nhân | Cách xử lý |
|---|---|---|
| `Missing inputs: GYMLVL_RELEASE_STORE_FILE, ...` | chưa nạp biến trong đúng phiên shell | lặp lại bước 2, kiểm tra bằng lệnh chẩn đoán ở bước 2 |
| `Keystore was tampered with, or password was incorrect` | sai mật khẩu store | kiểm tra lại mật khẩu, không tạo keystore mới |
| `Alias <...> does not exist` | sai alias | `keytool -list -v -keystore <file>` để xem alias thật |
| `Failed to read key from keystore` | sai mật khẩu key | phân biệt mật khẩu store và mật khẩu key |
| `SDK location not found` | thiếu `local.properties` / `ANDROID_HOME` | mở project bằng Android Studio một lần, hoặc đặt `ANDROID_HOME` |
| Build lỗi license | chưa chấp nhận license SDK | `flutter doctor --android-licenses` |

---

## 7. Khi đưa lên CI (chỉ sau khi chủ dự án đồng ý)

- Lưu keystore dưới dạng secret (base64) và 4 giá trị `GYMLVL_RELEASE_*` dưới dạng secret của CI.
- Giải mã keystore vào thư mục tạm trong job, đặt biến môi trường cho job đó, xóa file ở bước cuối.
- Không đưa khóa vào log, không `echo` giá trị, không đưa vào artifact.
- Không bao giờ bật lại debug signing cho nhánh release, và không gắn cổng kiểm tra vào `preReleaseBuild`
  (sẽ làm hỏng job `android-release-manifest` vốn chạy không cần khóa).

---

## 8. Sau khi build xong, cần ghi lại

Ghi vào `docs/planning/SESSION_HANDOFF.md` và `CHANGELOG_AI.md`: phiên bản build, đường dẫn artifact,
kết quả `apksigner verify`, và việc verify AAB đã làm hay chưa. Không ghi mật khẩu, không ghi nội dung
chứng chỉ riêng tư.

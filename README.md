# Demo — Flutter tutorial app

Ứng dụng Flutter minh họa **Clean Architecture** theo từng feature, kết hợp luồng **đăng nhập / đăng ký**, **danh sách sản phẩm** (xem, thêm, sửa, tìm kiếm), **giỏ hàng** và gọi **REST API** qua Dio. State và điều hướng dùng **GetX**; dữ liệu cục bộ dùng **Hive** (hộp được mã hóa AES, khóa lưu bằng **flutter_secure_storage**).

## Yêu cầu

- Flutter SDK tương thích `pubspec.yaml` (hiện tại: `sdk: ^3.10.7`)
- Backend API chạy và khớp với `baseUrl` (xem bên dưới)

## Chạy project

```bash
flutter pub get
flutter run
```

## Cấu hình API

Base URL mặc định nằm trong `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

- **Android Emulator:** `10.0.2.2` trỏ về máy host (thường dùng khi API chạy trên `localhost:8000` của máy dev).
- **Thiết bị thật / iOS Simulator:** đổi `baseUrl` sang IP LAN của máy chạy API (ví dụ `http://192.168.1.x:8000`) hoặc URL phù hợp môi trường của bạn.

Ở chế độ debug, log HTTP có thể bật qua **dio_log** (xem `app_routes.dart` / cấu hình Dio trong binding).

## Cấu trúc `lib/`

| Thư mục | Nội dung |
|--------|----------|
| `auth/` | Đăng nhập, đăng ký, session, middleware bảo vệ route |
| `products/` | Sản phẩm: remote data source, repository, use case, UI |
| `cart/` | Giỏ hàng: Hive + remote, controller, trang giỏ |
| `core/` | `api_config`, xử lý lỗi, logger |
| `app_binding.dart` | Đăng ký dependency GetX |
| `app_routes.dart` | `GetMaterialApp` pages + splash |
| `hive_encryption.dart` | Mở hộp Hive mã hóa (AES) |

**Clean Architecture (theo feature):** tách **domain** (entity, interface repository, use case — không phụ thuộc Flutter/API) → **data** (DTO, remote/local data source, repository implementation) → **presentation** (controller GetX, widget, page). Luồng phụ thuộc hướng vào trong: UI gọi use case, use case gọi repository abstract, implementation nối API/Hive.

Luồng hoạt động chi tiết (theo chức năng, màn hình, load more / pull-to-refresh): [docs/APP_FLOWS.md](docs/APP_FLOWS.md).

## Tính năng chính

- Splash → kiểm tra session → điều hướng login hoặc danh sách sản phẩm
- Đăng ký / đăng nhập; route cần auth dùng `AuthMiddleware`
- Danh sách sản phẩm, chi tiết, thêm/sửa, tìm kiếm
- Giỏ hàng (lưu cục bộ đã mã hóa; đồng bộ với API khi có)

## Dependencies chính

Xem `pubspec.yaml`: `get`, `dio`, `dio_log`, `hive` / `hive_flutter`, `flutter_secure_storage`, `cached_network_image`.

---

Dự án dùng cho mục đích học và demo; điều chỉnh URL API và backend cho đúng contract trước khi chạy end-to-end.

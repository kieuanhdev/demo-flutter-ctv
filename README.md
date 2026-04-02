# Demo Flutter (Clean Architecture)

Ứng dụng Flutter demo theo **Clean Architecture (feature-based)**: `auth` (đăng nhập/đăng ký/session), `products` (danh sách/tìm kiếm/chi tiết/thêm-sửa-xóa), `cart` (giỏ hàng) và `profile` (tài khoản). State & điều hướng dùng **GetX**; dữ liệu cục bộ dùng **Hive** và được **mã hóa AES**.

## Yêu cầu

- Flutter SDK tương thích `pubspec.yaml` (hiện tại: `sdk: ^3.10.7`)
- Backend API chạy và khớp với `baseUrl` (xem bên dưới)

## Chạy project

```bash
flutter pub get
flutter run
```

## Cấu hình API

`baseUrl` mặc định nằm trong `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://api.kieuanhdev.id.vn/';
}
```

- **Android Emulator:** nếu backend chạy trên `localhost` của máy dev, thường dùng `10.0.2.2`.
- **Thiết bị thật / iOS Simulator:** dùng IP LAN của máy chạy backend (ví dụ `http://192.168.1.x:8000`) hoặc URL phù hợp môi trường của bạn.

Ở chế độ debug, log HTTP có thể bật qua **dio_log** (tuỳ cấu hình trong project).

## Cấu trúc thư mục (tóm tắt)

- `auth/`: đăng nhập, đăng ký, session, middleware bảo vệ route
- `products/`: sản phẩm (UI + controller + use case + repository)
- `cart/`: giỏ hàng (Hive cache + controller + UI)
- `core/`: cấu hình API, logger, error mapper
- `app_routes.dart`: khai báo route (GetX) + splash
- `hive_encryption.dart`: mã hóa AES cho Hive boxes

**Clean Architecture (theo feature):** domain (không phụ thuộc Flutter/API) → data (remote/local + repository impl) → presentation (controller/widget/page). UI gọi use case; use case gọi repository abstract; implementation nối API/Hive.

Xem `docs/APP_FLOWS.md` để xem luồng theo code hiện tại (có sơ đồ).

## Tính năng

- Splash: kiểm tra session → điều hướng login hoặc danh sách sản phẩm
- Auth: đăng ký/đăng nhập; route bảo vệ bằng `AuthMiddleware`; đăng xuất xoá session
- Sản phẩm: danh sách, tìm kiếm, chi tiết, thêm/sửa/xoá
- Giỏ hàng: thêm và chỉnh số lượng; lưu local đã mã hóa AES; đồng bộ khi có API

## Dependency chính

Xem `pubspec.yaml`: `get`, `dio`, `hive` (`hive_flutter`), `flutter_secure_storage`, `cached_network_image` (và `dio_log` nếu bật).

## Lưu ý

Dự án dùng cho mục đích học và demo; cần chỉnh `baseUrl` và backend cho khớp contract trước khi chạy end-to-end.

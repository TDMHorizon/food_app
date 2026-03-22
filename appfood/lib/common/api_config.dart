/// Base URL cho API backend.
/// - Android Emulator: dùng `10.0.2.2` để trỏ tới máy host (localhost của máy tính).
/// - iOS Simulator / Web / thiết bị thật (cùng WiFi): đổi thành IP LAN hoặc `localhost` tương ứng.
/// - Đảm bảo PORT khớp với backend (mặc định 3000 trong README).
class ApiConfig {
  ApiConfig._();

  static const String host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '10.0.2.2',
  );

  static const int port = int.fromEnvironment('API_PORT', defaultValue: 3000);

  static String get baseUrl => 'http://$host:$port';
}

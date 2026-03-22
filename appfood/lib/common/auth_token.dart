import 'package:shared_preferences/shared_preferences.dart';

const _kJwtKey = 'appfood_jwt';

class AuthToken {
  AuthToken._();

  static Future<void> save(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kJwtKey, token);
  }

  static Future<String?> get() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kJwtKey);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kJwtKey);
  }
}

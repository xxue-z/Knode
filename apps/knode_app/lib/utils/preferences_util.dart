import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences工具类，用于存储和应用配置
class PreferencesUtil {
  static SharedPreferences? _prefs;

  static const String _keyBallX = 'chat_ball_x';
  static const String _keyBallY = 'chat_ball_y';
  static const String _keyBallStyle = 'chat_ball_style';
  static const String _keyAvatarPath = 'chat_avatar_path';
  static const String _keyInputMode = 'chat_input_mode';
  static const String _keyThemeMode = 'theme_mode';

  static Future<SharedPreferences> _getInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static void clearCache() {
    _prefs = null;
  }

  static Future<void> savePosition(double x, double y) async {
    final prefs = await _getInstance();
    await prefs.setDouble(_keyBallX, x);
    await prefs.setDouble(_keyBallY, y);
  }

  static Future<Map<String, double>> loadPosition() async {
    final prefs = await _getInstance();
    final screenWidth = 360.0;
    final screenHeight = 640.0;
    return {
      'x': prefs.getDouble(_keyBallX) ?? screenWidth - 60,
      'y': prefs.getDouble(_keyBallY) ?? screenHeight - 200,
    };
  }

  static Future<void> saveStyle(String style) async {
    final prefs = await _getInstance();
    await prefs.setString(_keyBallStyle, style);
  }

  static Future<String> loadStyle() async {
    final prefs = await _getInstance();
    return prefs.getString(_keyBallStyle) ?? 'gradient';
  }

  static Future<void> saveAvatarPath(String path) async {
    final prefs = await _getInstance();
    await prefs.setString(_keyAvatarPath, path);
  }

  static Future<String?> loadAvatarPath() async {
    final prefs = await _getInstance();
    return prefs.getString(_keyAvatarPath);
  }

  static Future<void> saveInputMode(String mode) async {
    final prefs = await _getInstance();
    await prefs.setString(_keyInputMode, mode);
  }

  static Future<String> loadInputMode() async {
    final prefs = await _getInstance();
    return prefs.getString(_keyInputMode) ?? 'text';
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await _getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  static Future<String> loadThemeMode() async {
    final prefs = await _getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }
}

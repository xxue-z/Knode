import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences工具类，用于存储和读取应用配置
class PreferencesUtil {
  // 悬浮球位置
  static const String _keyBallX = 'chat_ball_x';
  static const String _keyBallY = 'chat_ball_y';

  // 悬浮球样式
  static const String _keyBallStyle = 'chat_ball_style';

  // 自定义头像路径
  static const String _keyAvatarPath = 'chat_avatar_path';

  // 输入模式
  static const String _keyInputMode = 'chat_input_mode';

  // 主题模式
  static const String _keyThemeMode = 'theme_mode';

  /// 保存悬浮球位置
  static Future<void> savePosition(double x, double y) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBallX, x);
    await prefs.setDouble(_keyBallY, y);
  }

  /// 加载悬浮球位置
  static Future<Map<String, double>> loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final screenWidth = 360.0; // 默认值，实际使用时应从MediaQuery获取
    final screenHeight = 640.0;

    return {
      'x': prefs.getDouble(_keyBallX) ?? screenWidth - 60,
      'y': prefs.getDouble(_keyBallY) ?? screenHeight - 200,
    };
  }

  /// 保存悬浮球样式
  static Future<void> saveStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBallStyle, style);
  }

  /// 加载悬浮球样式
  static Future<String> loadStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBallStyle) ?? 'icon';
  }

  /// 保存自定义头像路径
  static Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarPath, path);
  }

  /// 加载自定义头像路径
  static Future<String?> loadAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAvatarPath);
  }

  /// 保存输入模式
  static Future<void> saveInputMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInputMode, mode);
  }

  /// 加载输入模式
  static Future<String> loadInputMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyInputMode) ?? 'text';
  }

  /// 保存主题模式
  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  /// 加载主题模式
  static Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }
}

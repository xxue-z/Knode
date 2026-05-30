import 'dart:convert';

/// JSON 编解码工具类。
class JsonUtils {
  JsonUtils._();

  /// 安全解析 JSON 字符串。
  ///
  /// 解析失败返回 null，不抛异常。
  static dynamic tryDecode(String jsonStr) {
    try {
      return jsonDecode(jsonStr);
    } catch (_) {
      return null;
    }
  }

  /// 安全解析 JSON 字符串为 Map。
  static Map<String, dynamic>? tryDecodeMap(String jsonStr) {
    final result = tryDecode(jsonStr);
    if (result is Map<String, dynamic>) return result;
    return null;
  }

  /// 安全解析 JSON 字符串为 List。
  static List<dynamic>? tryDecodeList(String jsonStr) {
    final result = tryDecode(jsonStr);
    if (result is List) return result;
    return null;
  }

  /// 编码为 JSON 字符串。
  static String encode(Object? object) {
    return jsonEncode(object);
  }

  /// 编码为格式化的 JSON 字符串（便于阅读）。
  static String encodePretty(Object? object) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(object);
  }

  /// 将 JSON 字符串列表解析为 Dart 字符串列表。
  static List<String> decodeStringList(String jsonStr) {
    final list = tryDecodeList(jsonStr);
    if (list == null) return [];
    return list.map((e) => e.toString()).toList();
  }

  /// 将字符串列表编码为 JSON 字符串。
  static String encodeStringList(List<String> list) {
    return jsonEncode(list);
  }

  /// 将 JSON 字符串 Map 解析为 Dart 字符串 Map。
  static Map<String, String> decodeStringMap(String jsonStr) {
    final map = tryDecodeMap(jsonStr);
    if (map == null) return {};
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  /// 将字符串 Map 编码为 JSON 字符串。
  static String encodeStringMap(Map<String, String> map) {
    return jsonEncode(map);
  }
}

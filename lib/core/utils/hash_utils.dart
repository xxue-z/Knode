import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

/// 哈希工具类，用于文本去重和校验。
class HashUtils {
  HashUtils._();

  /// 计算文本的 MD5 哈希值。
  ///
  /// 用于题目去重等场景。
  static String md5(String text) {
    final bytes = utf8.encode(text);
    return crypto.md5.convert(bytes).toString();
  }

  /// 计算文本的 SHA256 哈希值。
  ///
  /// 用于文件校验等安全性要求更高的场景。
  static String sha256(String text) {
    final bytes = utf8.encode(text);
    return crypto.sha256.convert(bytes).toString();
  }

  /// 计算文件的 SHA256 哈希值。
  ///
  /// [bytes] 文件的字节内容。
  static String sha256Bytes(List<int> bytes) {
    return crypto.sha256.convert(bytes).toString();
  }
}

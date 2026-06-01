import 'dart:convert';
import 'package:flutter/material.dart';

/// 高亮类型。
enum HighlightType { background, underline }

/// 高亮样式。
class HighlightStyle {
  final HighlightType type;
  final Color color;
  final double opacity;

  const HighlightStyle({
    this.type = HighlightType.background,
    required this.color,
    this.opacity = 0.3,
  });

  /// 序列化为 JSON 字符串（存入数据库）。
  String toJson() => jsonEncode({
    'type': type == HighlightType.background ? 'bg' : 'underline',
    'color': color.value,
    'opacity': opacity,
  });

  /// 从 JSON 字符串反序列化。
  static HighlightStyle fromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return HighlightStyle(
        type: map['type'] == 'bg' ? HighlightType.background : HighlightType.underline,
        color: Color(map['color'] as int),
        opacity: (map['opacity'] as num).toDouble(),
      );
    } catch (e) {
      return const HighlightStyle(color: Color(0xFFFFF59D));
    }
  }

  /// 预设样式列表。
  static const List<HighlightStyle> presets = [
    HighlightStyle(type: HighlightType.background, color: Color(0xFFFFF59D)), // 黄色
    HighlightStyle(type: HighlightType.background, color: Color(0xFF81C784)), // 绿色
    HighlightStyle(type: HighlightType.background, color: Color(0xFF64B5F6)), // 蓝色
    HighlightStyle(type: HighlightType.underline, color: Color(0xFFE57373)),  // 红色下划线
    HighlightStyle(type: HighlightType.underline, color: Color(0xFFFFB74D)),  // 橙色下划线
  ];
}

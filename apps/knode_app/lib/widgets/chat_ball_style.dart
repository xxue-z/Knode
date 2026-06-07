import 'package:flutter/material.dart';

/// 悬浮球样式配置
class ChatBallStyle {
  final double size;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color iconColor;
  final IconData icon;
  final double elevation;
  final BoxShadow? boxShadow;

  const ChatBallStyle({
    required this.size,
    required this.backgroundColor,
    this.gradient,
    required this.iconColor,
    required this.icon,
    this.elevation = 4.0,
    this.boxShadow,
  });

  /// 简约图标球样式
  factory ChatBallStyle.icon({Color? primaryColor}) {
    final color = primaryColor ?? Colors.blue;
    return ChatBallStyle(
      size: 56.0,
      backgroundColor: color,
      iconColor: Colors.white,
      icon: Icons.chat,
      boxShadow: BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    );
  }

  /// 渐变彩色球样式
  factory ChatBallStyle.gradient({Gradient? gradient}) {
    return ChatBallStyle(
      size: 56.0,
      backgroundColor: const Color(0xFF667eea),
      gradient: gradient ??
          const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      iconColor: Colors.white,
      icon: Icons.chat,
      boxShadow: const BoxShadow(
        color: Color(0x33667eea),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    );
  }

  /// 头像球样式
  factory ChatBallStyle.avatar({String? avatarPath, Color? primaryColor}) {
    final color = primaryColor ?? Colors.blue;
    return ChatBallStyle(
      size: 56.0,
      backgroundColor: color,
      iconColor: Colors.white,
      icon: Icons.person,
      boxShadow: BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    );
  }

  /// 根据样式名称获取对应的样式
  factory ChatBallStyle.fromName(String name, {String? avatarPath}) {
    switch (name) {
      case 'gradient':
        return ChatBallStyle.gradient();
      case 'avatar':
        return ChatBallStyle.avatar(avatarPath: avatarPath);
      case 'icon':
      default:
        return ChatBallStyle.icon();
    }
  }
}

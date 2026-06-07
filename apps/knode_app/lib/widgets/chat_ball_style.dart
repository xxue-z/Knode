import 'package:flutter/material.dart';

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

  factory ChatBallStyle.gradient({Gradient? gradient}) {
    return const ChatBallStyle(
      size: 56.0,
      backgroundColor: Colors.red,
      iconColor: Colors.white,
      icon: Icons.chat,
      boxShadow: BoxShadow(
        color: Color(0x4DFF0000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    );
  }

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

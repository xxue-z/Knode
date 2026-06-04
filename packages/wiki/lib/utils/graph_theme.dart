import 'package:flutter/material.dart';

/// Graph theme configuration for the knowledge graph UI.
///
/// Supports light/dark mode with category-specific gradient colors
/// and galaxy-style background rendering.
class GraphTheme {
  GraphTheme._();

  /// Category color gradients mapping.
  ///
  /// Each category has a list of 3 colors for gradient rendering:
  /// [light, medium, dark]
  static const Map<int, List<Color>> categoryGradients = {
    // Notes: Blue
    1: [Color(0xFF64B5F6), Color(0xFF1E88E5), Color(0xFF0D47A1)],
    // Study: Green
    2: [Color(0xFF81C784), Color(0xFF43A047), Color(0xFF1B5E20)],
    // Work: Purple
    3: [Color(0xFFCE93D8), Color(0xFF8E24AA), Color(0xFF4A148C)],
    // Ideas: Orange
    4: [Color(0xFFFFB74D), Color(0xFFFB8C00), Color(0xFFE65100)],
    // Archive: Gray
    5: [Color(0xFFB0BEC5), Color(0xFF78909C), Color(0xFF37474F)],
  };

  /// Light mode background gradient colors.
  static const lightBackground = [
    Color(0xFFF5F7FA),
    Color(0xFFE8EDF2),
    Color(0xFFDFE6ED),
  ];

  /// Dark mode background gradient colors.
  static const darkBackground = [
    Color(0xFF0f0c29),
    Color(0xFF302b63),
    Color(0xFF24243e),
  ];

  /// Light mode star color (rgba(180,190,200,0.7)).
  static const lightStarColor = Color(0xB3B4BEC8);

  /// Dark mode star color (rgba(255,255,255,0.5)).
  static const darkStarColor = Color(0x80FFFFFF);

  /// Get gradient colors for a category.
  ///
  /// Returns the category-specific gradient if found,
  /// otherwise returns the default blue gradient (category 1).
  static List<Color> getGradientForCategory(int categoryId) {
    return categoryGradients[categoryId] ?? categoryGradients[1]!;
  }

  /// Get background gradient colors based on brightness.
  static List<Color> getBackground(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  /// Get star color based on brightness.
  static Color getStarColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkStarColor : lightStarColor;
  }

  /// Node text color based on brightness.
  static Color getTextColor(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.white : Colors.white;
  }

  /// Node border color based on brightness.
  static Color getBorderColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.15);
  }

  /// Node label text shadow color based on brightness.
  static Color getLabelShadowColor(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.black54 : Colors.black26;
  }

  /// Default node fill color based on brightness.
  static Color getDefaultNodeColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF37474F)
        : const Color(0xFF546E7A);
  }

  /// Default node text color (for node fill on gradient).
  static Color get_nodeTextColor(Brightness brightness) {
    return Colors.white;
  }

  /// Edge color based on brightness.
  static Color getEdgeColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF78909C)
        : const Color(0xFF546E7A);
  }

  /// Tag text color based on brightness.
  static Color getTagColor(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.white70 : Colors.white70;
  }
}

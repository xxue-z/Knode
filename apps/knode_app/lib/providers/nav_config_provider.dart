import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 导航栏项目
class NavItem {
  final String id;
  final String label;
  final IconData icon;
  final bool isVisible;

  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.isVisible = true,
  });

  NavItem copyWith({
    String? id,
    String? label,
    IconData? icon,
    bool? isVisible,
  }) {
    return NavItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// 导航栏配置
class NavConfig {
  final List<NavItem> items;

  const NavConfig({required this.items});

  List<NavItem> getVisibleTabs() {
    return items.where((item) => item.isVisible).toList();
  }
}

/// 导航栏配置Notifier
class NavConfigNotifier extends Notifier<NavConfig> {
  @override
  NavConfig build() => const NavConfig(
          items: [
            NavItem(id: 'home', label: 'Home', icon: Icons.home),
            NavItem(id: 'wiki', label: 'Wiki', icon: Icons.menu_book),
            NavItem(id: 'chat', label: 'Chat', icon: Icons.chat, isVisible: false),
            NavItem(id: 'quiz', label: 'Quiz', icon: Icons.quiz),
          ],
        );

  void toggleVisibility(String tabId) {
    state = NavConfig(
      items: state.items.map((item) {
        if (item.id == tabId) {
          return item.copyWith(isVisible: !item.isVisible);
        }
        return item;
      }).toList(),
    );
  }

  void reorder(int oldIndex, int newIndex) {
    final items = List<NavItem>.from(state.items);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = NavConfig(items: items);
  }
}

/// 导航栏配置Provider
final navConfigProvider = NotifierProvider<NavConfigNotifier, NavConfig>(
  NavConfigNotifier.new,
);

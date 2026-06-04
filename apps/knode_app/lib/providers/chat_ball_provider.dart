import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/utils/preferences_util.dart';

/// 悬浮球状态
class ChatBallState {
  final Offset position;
  final bool isExpanded;
  final bool hasUnread;
  final String inputMode;
  final String style;

  const ChatBallState({
    required this.position,
    required this.isExpanded,
    required this.hasUnread,
    required this.inputMode,
    required this.style,
  });

  ChatBallState copyWith({
    Offset? position,
    bool? isExpanded,
    bool? hasUnread,
    String? inputMode,
    String? style,
  }) {
    return ChatBallState(
      position: position ?? this.position,
      isExpanded: isExpanded ?? this.isExpanded,
      hasUnread: hasUnread ?? this.hasUnread,
      inputMode: inputMode ?? this.inputMode,
      style: style ?? this.style,
    );
  }

  factory ChatBallState.initial() => const ChatBallState(
        position: Offset(300, 440),
        isExpanded: false,
        hasUnread: false,
        inputMode: 'text',
        style: 'icon',
      );
}

/// 悬浮球状态Notifier
class ChatBallNotifier extends Notifier<ChatBallState> {
  @override
  ChatBallState build() => ChatBallState.initial();

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void setHasUnread(bool hasUnread) {
    state = state.copyWith(hasUnread: hasUnread);
  }

  void setInputMode(String mode) {
    state = state.copyWith(inputMode: mode);
    PreferencesUtil.saveInputMode(mode);
  }

  void setStyle(String style) {
    state = state.copyWith(style: style);
    PreferencesUtil.saveStyle(style);
  }

  void updatePosition(Offset position) {
    state = state.copyWith(position: position);
    PreferencesUtil.savePosition(position.dx, position.dy);
  }

  Future<void> restoreState() async {
    final position = await PreferencesUtil.loadPosition();
    final style = await PreferencesUtil.loadStyle();
    final inputMode = await PreferencesUtil.loadInputMode();

    state = ChatBallState(
      position: Offset(position['x']!, position['y']!),
      isExpanded: false,
      hasUnread: false,
      inputMode: inputMode,
      style: style,
    );
  }
}

/// 悬浮球状态Provider
final chatBallNotifierProvider = NotifierProvider<ChatBallNotifier, ChatBallState>(
  ChatBallNotifier.new,
);

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knode_app/providers/chat_ball_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatBallNotifier', () {
    test('initial state has correct default values', () {
      final container = ProviderContainer();
      final state = container.read(chatBallNotifierProvider);

      expect(state.isExpanded, false);
      expect(state.hasUnread, false);
      expect(state.inputMode, 'text');
      expect(state.style, 'icon');
    });

    test('toggleExpanded toggles expanded state', () {
      final container = ProviderContainer();
      final notifier = container.read(chatBallNotifierProvider.notifier);

      expect(container.read(chatBallNotifierProvider).isExpanded, false);

      notifier.toggleExpanded();
      expect(container.read(chatBallNotifierProvider).isExpanded, true);

      notifier.toggleExpanded();
      expect(container.read(chatBallNotifierProvider).isExpanded, false);
    });

    test('setHasUnread updates unread state', () {
      final container = ProviderContainer();
      final notifier = container.read(chatBallNotifierProvider.notifier);

      notifier.setHasUnread(true);
      expect(container.read(chatBallNotifierProvider).hasUnread, true);

      notifier.setHasUnread(false);
      expect(container.read(chatBallNotifierProvider).hasUnread, false);
    });

    test('setInputMode updates input mode', () {
      final container = ProviderContainer();
      final notifier = container.read(chatBallNotifierProvider.notifier);

      notifier.setInputMode('voice');
      expect(container.read(chatBallNotifierProvider).inputMode, 'voice');

      notifier.setInputMode('text');
      expect(container.read(chatBallNotifierProvider).inputMode, 'text');
    });

    test('setStyle updates style', () {
      final container = ProviderContainer();
      final notifier = container.read(chatBallNotifierProvider.notifier);

      notifier.setStyle('gradient');
      expect(container.read(chatBallNotifierProvider).style, 'gradient');
    });

    test('updatePosition updates position', () {
      final container = ProviderContainer();
      final notifier = container.read(chatBallNotifierProvider.notifier);

      notifier.updatePosition(const Offset(100, 200));
      expect(container.read(chatBallNotifierProvider).position, const Offset(100, 200));
    });
  });
}

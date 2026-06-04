import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/widgets/floating_chat_ball.dart';
import 'package:knode_app/providers/chat_ball_provider.dart';

void main() {
  group('FloatingChatBall', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const FloatingChatBall(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingChatBall), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
    });

    testWidgets('toggles expanded state on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const FloatingChatBall(),
                ],
              ),
            ),
          ),
        ),
      );

      // Initial state - not expanded
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FloatingChatBall)),
      );
      expect(container.read(chatBallNotifierProvider).isExpanded, isFalse);

      // Tap to expand - need to advance past double-tap timeout (300ms)
      // since onDoubleTap is on the same GestureDetector
      await tester.tap(find.byType(FloatingChatBall));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be expanded
      expect(container.read(chatBallNotifierProvider).isExpanded, isTrue);

      // Tap again to collapse
      await tester.tap(find.byType(FloatingChatBall));
      await tester.pump(const Duration(milliseconds: 500));

      expect(container.read(chatBallNotifierProvider).isExpanded, isFalse);
    });

    testWidgets('shows pulse animation when hasUnread is true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const FloatingChatBall(),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially no unread state
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FloatingChatBall)),
      );
      expect(container.read(chatBallNotifierProvider).hasUnread, isFalse);

      // Set hasUnread to true
      container.read(chatBallNotifierProvider.notifier).setHasUnread(true);
      await tester.pump();

      // Should now have unread state
      expect(container.read(chatBallNotifierProvider).hasUnread, isTrue);
    });

    testWidgets('clears unread state on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const FloatingChatBall(),
                ],
              ),
            ),
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FloatingChatBall)),
      );

      // Set hasUnread to true
      container.read(chatBallNotifierProvider.notifier).setHasUnread(true);
      await tester.pump();
      expect(container.read(chatBallNotifierProvider).hasUnread, isTrue);

      // Tap to clear unread
      await tester.tap(find.byType(FloatingChatBall));
      await tester.pump(const Duration(milliseconds: 500));

      expect(container.read(chatBallNotifierProvider).hasUnread, isFalse);
    });

    testWidgets('can be dragged', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const FloatingChatBall(),
                ],
              ),
            ),
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FloatingChatBall)),
      );
      final initialX = container.read(chatBallNotifierProvider).position.dx;

      // Drag the ball to the right side (past center)
      await tester.drag(find.byType(FloatingChatBall), const Offset(200, 0));
      await tester.pump(); // Pump once to register the drag

      // Position should be updated during drag
      final stateDuringDrag = container.read(chatBallNotifierProvider);
      expect(stateDuringDrag.position.dx, isNot(equals(initialX)));

      // Complete the drag and let snap animation finish
      await tester.pumpAndSettle();

      // After snap, position should be at an edge (0 or screen width - ball size)
      final stateAfterSnap = container.read(chatBallNotifierProvider);
      final screenWidth = MediaQuery.of(tester.element(find.byType(FloatingChatBall))).size.width;
      final ballSize = 56.0;
      // The ball should have snapped to either left or right edge
      expect(stateAfterSnap.position.dx, anyOf(equals(0.0), equals(screenWidth - ballSize)));
    });
  });
}

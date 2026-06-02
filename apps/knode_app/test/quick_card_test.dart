import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/screens/quick_card.dart';

void main() {
  group('QuickCard Widget Tests', () {
    testWidgets('QuickCard should render correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: QuickCard(),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
    });

    testWidgets('QuickCard should have InkWell for tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: QuickCard(),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('QuickCard should display icon and title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: QuickCard(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flash_on), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('QuickCard should handle custom onTap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuickCard(
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}

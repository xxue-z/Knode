import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/quiz_provider.dart';
import 'package:core/models/daily_task_config.dart';
import 'package:knode_app/screens/daily_card.dart';


class _FakeDailyConfigNotifier extends DailyConfigNotifier {
  @override
  Future<DailyTaskConfig?> build() async => null;
}

void main() {
  group('DailyCard Widget Tests', () {
    testWidgets('DailyCard should render correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [dailyConfigProvider.overrideWith(() => _FakeDailyConfigNotifier())],
          child: const MaterialApp(
            home: Scaffold(
              body: DailyCard(),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byIcon(Icons.today), findsOneWidget);
    });

    testWidgets('DailyCard should have InkWell for tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [dailyConfigProvider.overrideWith(() => _FakeDailyConfigNotifier())],
          child: const MaterialApp(
            home: Scaffold(
              body: DailyCard(),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsAtLeast(1));
    });

    testWidgets('DailyCard should display icon and title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [dailyConfigProvider.overrideWith(() => _FakeDailyConfigNotifier())],
          child: const MaterialApp(
            home: Scaffold(
              body: DailyCard(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.today), findsOneWidget);
    });

    testWidgets('DailyCard should handle onNavigateToTab callback', (tester) async {
      int? navigatedPage;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [dailyConfigProvider.overrideWith(() => _FakeDailyConfigNotifier())],
          child: MaterialApp(
            home: Scaffold(
              body: DailyCard(
                onNavigateToTab: (pageIndex) {
                  navigatedPage = pageIndex;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(navigatedPage, equals(3));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiki/graph/widgets/galaxy_graph.dart';

void main() {
  testWidgets('GalaxyGraph can be created', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: GalaxyGraph(),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(GalaxyGraph), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiki/graph/providers/selection_provider.dart';

void main() {
  group('selectedNodeIdProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(selectedNodeIdProvider);
      expect(state, isNull);
    });

    test('updating state via notifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedNodeIdProvider.notifier).state = 'node_1';
      expect(container.read(selectedNodeIdProvider), 'node_1');

      container.read(selectedNodeIdProvider.notifier).state = null;
      expect(container.read(selectedNodeIdProvider), isNull);
    });
  });
}

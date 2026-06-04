import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/providers/nav_config_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NavConfigNotifier', () {
    test('initial state has correct default config', () {
      final container = ProviderContainer();
      final config = container.read(navConfigProvider);

      expect(config.items.length, 4);
      expect(config.items[0].id, 'wiki');
      expect(config.items[1].id, 'home');
      expect(config.items[2].id, 'chat');
      expect(config.items[3].id, 'quiz');
    });

    test('toggleVisibility hides visible tab', () {
      final container = ProviderContainer();
      final notifier = container.read(navConfigProvider.notifier);

      // wiki starts visible, toggle to hidden
      notifier.toggleVisibility('wiki');
      final config = container.read(navConfigProvider);

      expect(config.items[0].isVisible, false);
    });

    test('toggleVisibility shows hidden tab', () {
      final container = ProviderContainer();
      final notifier = container.read(navConfigProvider.notifier);

      // chat starts hidden, toggle to visible
      notifier.toggleVisibility('chat');
      final config = container.read(navConfigProvider);

      expect(config.items[2].isVisible, true);
    });

    test('reorder changes tab order', () {
      final container = ProviderContainer();
      final notifier = container.read(navConfigProvider.notifier);

      notifier.reorder(3, 1);
      final config = container.read(navConfigProvider);

      expect(config.items[0].id, 'wiki');
      expect(config.items[1].id, 'quiz');
      expect(config.items[2].id, 'home');
      expect(config.items[3].id, 'chat');
    });

    test('getVisibleTabs returns only visible tabs', () {
      final container = ProviderContainer();
      final notifier = container.read(navConfigProvider.notifier);

      // quiz starts visible, toggle to hidden
      notifier.toggleVisibility('quiz');
      final config = container.read(navConfigProvider);
      final visibleTabs = config.getVisibleTabs();

      // wiki, home visible; chat hidden by default; quiz now hidden
      expect(visibleTabs.length, 2);
      expect(visibleTabs[0].id, 'wiki');
      expect(visibleTabs[1].id, 'home');
    });
  });
}

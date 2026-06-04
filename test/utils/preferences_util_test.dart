import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knode_app/utils/preferences_util.dart';

void main() {
  group('PreferencesUtil', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveAndLoadPosition saves and retrieves position correctly', () async {
      const double testX = 100.0;
      const double testY = 200.0;

      await PreferencesUtil.savePosition(testX, testY);
      final result = await PreferencesUtil.loadPosition();

      expect(result['x'], testX);
      expect(result['y'], testY);
    });

    test('loadPosition returns default values when no data exists', () async {
      final result = await PreferencesUtil.loadPosition();

      expect(result['x'], isNotNull);
      expect(result['y'], isNotNull);
    });

    test('saveAndLoadStyle saves and retrieves style correctly', () async {
      const String testStyle = 'gradient';

      await PreferencesUtil.saveStyle(testStyle);
      final result = await PreferencesUtil.loadStyle();

      expect(result, testStyle);
    });

    test('loadStyle returns default icon when no data exists', () async {
      final result = await PreferencesUtil.loadStyle();

      expect(result, 'icon');
    });

    test('saveAndLoadAvatarPath saves and retrieves path correctly', () async {
      const String testPath = '/path/to/avatar.jpg';

      await PreferencesUtil.saveAvatarPath(testPath);
      final result = await PreferencesUtil.loadAvatarPath();

      expect(result, testPath);
    });

    test('loadAvatarPath returns null when no data exists', () async {
      final result = await PreferencesUtil.loadAvatarPath();

      expect(result, isNull);
    });

    test('saveAndLoadInputMode saves and retrieves mode correctly', () async {
      const String testMode = 'voice';

      await PreferencesUtil.saveInputMode(testMode);
      final result = await PreferencesUtil.loadInputMode();

      expect(result, testMode);
    });

    test('loadInputMode returns default text when no data exists', () async {
      final result = await PreferencesUtil.loadInputMode();

      expect(result, 'text');
    });

    test('saveAndLoadThemeMode saves and retrieves mode correctly', () async {
      const String testMode = 'dark';

      await PreferencesUtil.saveThemeMode(testMode);
      final result = await PreferencesUtil.loadThemeMode();

      expect(result, testMode);
    });

    test('loadThemeMode returns default system when no data exists', () async {
      final result = await PreferencesUtil.loadThemeMode();

      expect(result, 'system');
    });
  });
}

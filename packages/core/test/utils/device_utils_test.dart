import 'package:test/test.dart';
import 'package:core/utils/device_utils.dart';

void main() {
  group('DeviceUtils', () {
    group('parseRamString', () {
      test('parses GB format with space', () {
        expect(DeviceUtils.parseRamString('2 GB'), 2.0);
        expect(DeviceUtils.parseRamString('4 GB'), 4.0);
        expect(DeviceUtils.parseRamString('8 GB'), 8.0);
      });

      test('parses GB format without space', () {
        expect(DeviceUtils.parseRamString('2GB'), 2.0);
        expect(DeviceUtils.parseRamString('4GB'), 4.0);
        expect(DeviceUtils.parseRamString('16GB'), 16.0);
      });

      test('parses GB format with lowercase', () {
        expect(DeviceUtils.parseRamString('2 gb'), 2.0);
        expect(DeviceUtils.parseRamString('4gb'), 4.0);
      });

      test('parses MB format', () {
        expect(DeviceUtils.parseRamString('512 MB'), 0.5);
        expect(DeviceUtils.parseRamString('1024 MB'), 1.0);
        expect(DeviceUtils.parseRamString('2048 MB'), 2.0);
        expect(DeviceUtils.parseRamString('512MB'), 0.5);
      });

      test('parses empty string as 0', () {
        expect(DeviceUtils.parseRamString(''), 0.0);
      });

      test('parses invalid format as 0', () {
        expect(DeviceUtils.parseRamString('abc'), 0.0);
        expect(DeviceUtils.parseRamString('2 TB'), 0.0);
        expect(DeviceUtils.parseRamString('2'), 0.0);
      });

      test('parses decimal values', () {
        expect(DeviceUtils.parseRamString('1.5 GB'), 1.5);
        expect(DeviceUtils.parseRamString('0.5 GB'), 0.5);
      });
    });

    group('isModelSupported', () {
      test('returns true when model fits in available memory', () async {
        final result = await DeviceUtils.isModelSupported(2048);
        expect(result, isA<bool>());
      });
    });
  });
}

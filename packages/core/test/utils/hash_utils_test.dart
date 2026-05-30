import 'package:test/test.dart';
import 'package:core/utils/hash_utils.dart';

void main() {
  group('HashUtils', () {
    test('md5 returns consistent hash', () {
      final hash1 = HashUtils.md5('hello world');
      final hash2 = HashUtils.md5('hello world');
      expect(hash1, hash2);
      expect(hash1.length, 32); // MD5 hex is 32 chars
    });

    test('md5 returns different hash for different input', () {
      final hash1 = HashUtils.md5('hello');
      final hash2 = HashUtils.md5('world');
      expect(hash1, isNot(hash2));
    });

    test('md5 returns known value', () {
      // MD5("hello") = 5d41402abc4b2a76b9719d911017c592
      expect(HashUtils.md5('hello'), '5d41402abc4b2a76b9719d911017c592');
    });

    test('sha256 returns consistent hash', () {
      final hash1 = HashUtils.sha256('test input');
      final hash2 = HashUtils.sha256('test input');
      expect(hash1, hash2);
      expect(hash1.length, 64); // SHA256 hex is 64 chars
    });

    test('sha256 returns different hash for different input', () {
      final hash1 = HashUtils.sha256('abc');
      final hash2 = HashUtils.sha256('def');
      expect(hash1, isNot(hash2));
    });

    test('sha256Bytes returns consistent hash', () {
      final bytes = [0x48, 0x65, 0x6C, 0x6C, 0x6F]; // "Hello"
      final hash1 = HashUtils.sha256Bytes(bytes);
      final hash2 = HashUtils.sha256Bytes(bytes);
      expect(hash1, hash2);
      expect(hash1.length, 64);
    });

    test('sha256 and sha256Bytes produce same result for same content', () {
      final text = 'Hello';
      final bytes = text.codeUnits;
      expect(HashUtils.sha256(text), HashUtils.sha256Bytes(bytes));
    });

    test('md5 handles empty string', () {
      final hash = HashUtils.md5('');
      expect(hash, isNotEmpty);
      expect(hash.length, 32);
    });

    test('md5 handles unicode', () {
      final hash = HashUtils.md5('你好世界');
      expect(hash, isNotEmpty);
      expect(hash.length, 32);
    });
  });
}

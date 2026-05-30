import 'package:test/test.dart';
import 'package:core/utils/json_utils.dart';

void main() {
  group('JsonUtils', () {
    group('tryDecode', () {
      test('parses valid JSON', () {
        expect(JsonUtils.tryDecode('{"a":1}'), isA<Map>());
        expect(JsonUtils.tryDecode('[1,2,3]'), isA<List>());
        expect(JsonUtils.tryDecode('"hello"'), 'hello');
        expect(JsonUtils.tryDecode('42'), 42);
        expect(JsonUtils.tryDecode('true'), true);
        expect(JsonUtils.tryDecode('null'), isNull);
      });

      test('returns null for invalid JSON', () {
        expect(JsonUtils.tryDecode('not json'), isNull);
        expect(JsonUtils.tryDecode('{broken'), isNull);
        expect(JsonUtils.tryDecode(''), isNull);
      });
    });

    group('tryDecodeMap', () {
      test('parses valid JSON map', () {
        final result = JsonUtils.tryDecodeMap('{"name":"test","value":42}');
        expect(result, isNotNull);
        expect(result!['name'], 'test');
        expect(result['value'], 42);
      });

      test('returns null for non-map JSON', () {
        expect(JsonUtils.tryDecodeMap('[1,2,3]'), isNull);
        expect(JsonUtils.tryDecodeMap('"string"'), isNull);
        expect(JsonUtils.tryDecodeMap('invalid'), isNull);
      });
    });

    group('tryDecodeList', () {
      test('parses valid JSON list', () {
        final result = JsonUtils.tryDecodeList('[1,"two",true]');
        expect(result, isNotNull);
        expect(result!.length, 3);
        expect(result[0], 1);
        expect(result[1], 'two');
      });

      test('returns null for non-list JSON', () {
        expect(JsonUtils.tryDecodeList('{"a":1}'), isNull);
        expect(JsonUtils.tryDecodeList('42'), isNull);
      });
    });

    group('encode', () {
      test('encodes map to JSON string', () {
        final result = JsonUtils.encode({'a': 1, 'b': 'two'});
        expect(result, contains('"a":1'));
        expect(result, contains('"b":"two"'));
      });

      test('encodes list to JSON string', () {
        expect(JsonUtils.encode([1, 2, 3]), '[1,2,3]');
      });
    });

    group('encodePretty', () {
      test('produces indented output', () {
        final result = JsonUtils.encodePretty({'a': 1});
        expect(result, contains('\n'));
        expect(result, contains('  '));
      });
    });

    group('decodeStringList', () {
      test('parses JSON string array', () {
        final result = JsonUtils.decodeStringList('["a","b","c"]');
        expect(result, ['a', 'b', 'c']);
      });

      test('converts non-string elements to strings', () {
        final result = JsonUtils.decodeStringList('[1,2,3]');
        expect(result, ['1', '2', '3']);
      });

      test('returns empty list for invalid input', () {
        expect(JsonUtils.decodeStringList('invalid'), []);
        expect(JsonUtils.decodeStringList('{"a":1}'), []);
      });
    });

    group('decodeStringMap', () {
      test('parses JSON string map', () {
        final result = JsonUtils.decodeStringMap('{"k1":"v1","k2":"v2"}');
        expect(result, {'k1': 'v1', 'k2': 'v2'});
      });

      test('converts non-string values to strings', () {
        final result = JsonUtils.decodeStringMap('{"count":42}');
        expect(result, {'count': '42'});
      });

      test('returns empty map for invalid input', () {
        expect(JsonUtils.decodeStringMap('invalid'), {});
        expect(JsonUtils.decodeStringMap('[1,2]'), {});
      });
    });

    group('encodeStringList / encodeStringMap', () {
      test('roundtrip string list', () {
        final original = ['hello', 'world', '你好'];
        final encoded = JsonUtils.encodeStringList(original);
        final decoded = JsonUtils.decodeStringList(encoded);
        expect(decoded, original);
      });

      test('roundtrip string map', () {
        final original = {'key': 'value', '键': '值'};
        final encoded = JsonUtils.encodeStringMap(original);
        final decoded = JsonUtils.decodeStringMap(encoded);
        expect(decoded, original);
      });
    });
  });
}

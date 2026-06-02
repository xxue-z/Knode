import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:micro_server/services/server.dart';

void main() {
  group('MicroServer Tests', () {
    test('MicroServer should not be running initially', () {
      final server = MicroServer(
        port: 8080,
        handler: (request) async => shelf.Response.ok('test'),
      );

      expect(server.isRunning, isFalse);
    });

    test('MicroServer should be running after start', () async {
      final server = MicroServer(
        port: 8081,
        handler: (request) async => shelf.Response.ok('test'),
      );

      await server.start();

      expect(server.isRunning, isTrue);

      await server.stop();
    });

    test('MicroServer should not be running after stop', () async {
      final server = MicroServer(
        port: 8082,
        handler: (request) async => shelf.Response.ok('test'),
      );

      await server.start();
      await server.stop();

      expect(server.isRunning, isFalse);
    });

    test('MicroServer should handle multiple start calls', () async {
      final server = MicroServer(
        port: 8083,
        handler: (request) async => shelf.Response.ok('test'),
      );

      await server.start();
      await server.start();

      expect(server.isRunning, isTrue);

      await server.stop();
    });

    test('MicroServer should add pending upload', () {
      final server = MicroServer(
        port: 8084,
        handler: (request) async => shelf.Response.ok('test'),
      );

      final requestId = server.addPendingUpload('test.txt', 1024);

      expect(requestId, isNotEmpty);
    });

    test('MicroServer should confirm upload', () async {
      final server = MicroServer(
        port: 8085,
        handler: (request) async => shelf.Response.ok('test'),
      );

      final requestId = server.addPendingUpload('test.txt', 1024);
      server.confirmUpload(requestId);

      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('MicroServer should reject upload', () async {
      final server = MicroServer(
        port: 8086,
        handler: (request) async => shelf.Response.ok('test'),
      );

      final requestId = server.addPendingUpload('test.txt', 1024);
      server.rejectUpload(requestId);

      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('MicroServer should expose upload requests stream', () {
      final server = MicroServer(
        port: 8087,
        handler: (request) async => shelf.Response.ok('test'),
      );

      expect(server.uploadRequests, isNotNull);
    });
  });
}

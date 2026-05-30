import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import '../gen/strings.dart';
import '../services/server.dart';

const _strings = L10nStringsMixin();

class FileHandler {
  final MicroServer _server;
  final String _rootPath;
  FileHandler(this._server, this._rootPath);

  Future<Map<String, dynamic>> listFiles() async {
    final dir = Directory(_rootPath);
    if (!await dir.exists()) return {'files': []};
    final files = <Map<String, dynamic>>[];
    await for (final entity in dir.list()) {
      if (entity is File) {
        files.add({'name': entity.path.split(Platform.pathSeparator).last, 'size': await entity.length()});
      }
    }
    return {'files': files};
  }

  Future<Map<String, dynamic>> upload(shelf.Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final fileName = data['fileName'] as String;
    final fileSize = data['fileSize'] as int;
    final requestId = _server.addPendingUpload(fileName, fileSize);
    return {'requestId': requestId, 'status': 'pending', 'message': _strings.micro_server_waiting_for_device_confirmation};
  }

  Future<shelf.Response> download(String fileName) async {
    final file = File('$_rootPath/$fileName');
    if (!await file.exists()) return shelf.Response.notFound('File not found');
    final content = await file.readAsBytes();
    return shelf.Response.ok(content, headers: {'content-type': 'application/octet-stream', 'content-disposition': 'attachment; filename="$fileName"'});
  }
}
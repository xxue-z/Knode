import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class BackupService {
  String? _url;
  String? _user;
  String? _pass;

  void configure({required String url, required String user, required String pass}) {
    _url = url;
    _user = user;
    _pass = pass;
  }

  bool get isConfigured => _url != null && _user != null;

  Future<void> backup({required String dbPath, required String wikiRoot}) async {
    if (!isConfigured) throw StateError('WebDAV 未配置');
    final client = http.Client();
    try {
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        final bytes = await dbFile.readAsBytes();
        final uri = Uri.parse('$_url/knode_backup/knode.db');
        await client.put(uri, body: bytes, headers: {'authorization': 'Basic ${base64Encode(utf8.encode('$_user:$_pass'))}'});
      }
      final wikiDir = Directory(wikiRoot);
      if (await wikiDir.exists()) {
        await for (final entity in wikiDir.list(recursive: true)) {
          if (entity is File) {
            final rel = p.relative(entity.path, from: wikiRoot);
            final bytes = await entity.readAsBytes();
            final uri = Uri.parse('$_url/knode_backup/wiki/$rel');
            await client.put(uri, body: bytes, headers: {'authorization': 'Basic ${base64Encode(utf8.encode('$_user:$_pass'))}'});
          }
        }
      }
    } finally {
      client.close();
    }
  }

  Future<void> restore({required String dbPath, required String wikiRoot}) async {
    if (!isConfigured) throw StateError('WebDAV 未配置');
    final client = http.Client();
    try {
      final dbUri = Uri.parse('$_url/knode_backup/knode.db');
      final resp = await client.get(dbUri, headers: {'authorization': 'Basic ${base64Encode(utf8.encode('$_user:$_pass'))}'});
      if (resp.statusCode == 200) {
        await File(dbPath).writeAsBytes(resp.bodyBytes);
      }
    } finally {
      client.close();
    }
  }

  Future<bool> testConnection() async {
    if (!isConfigured) return false;
    try {
      final uri = Uri.parse(_url!);
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      return resp.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}
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
      // 恢复数据库文件
      final dbUri = Uri.parse('$_url/knode_backup/knode.db');
      final dbResp = await client.get(dbUri, headers: _authHeaders());
      if (dbResp.statusCode == 200) {
        await File(dbPath).writeAsBytes(dbResp.bodyBytes);
      }

      // 恢复 wiki 文件目录
      final wikiUri = Uri.parse('$_url/knode_backup/wiki/');
      final wikiResp = await client.get(wikiUri, headers: _authHeaders());
      if (wikiResp.statusCode == 200) {
        // 解析 WebDAV PROPFIND 响应获取文件列表
        final files = _parseWebDavFileList(wikiResp.body);
        for (final filePath in files) {
          final fileUri = Uri.parse('$_url/knode_backup/wiki/$filePath');
          final fileResp = await client.get(fileUri, headers: _authHeaders());
          if (fileResp.statusCode == 200) {
            final localFile = File('$wikiRoot/$filePath');
            await localFile.parent.create(recursive: true);
            await localFile.writeAsBytes(fileResp.bodyBytes);
          }
        }
      }
    } finally {
      client.close();
    }
  }

  Map<String, String> _authHeaders() => {
    'authorization': 'Basic ${base64Encode(utf8.encode('$_user:$_pass'))}',
  };

  List<String> _parseWebDavFileList(String xmlBody) {
    // 简单解析 WebDAV PROPFIND 响应中的文件路径
    final pattern = RegExp(r'<D:href>([^<]+)</D:href>', caseSensitive: false);
    final matches = pattern.allMatches(xmlBody);
    return matches
        .map((m) => m.group(1) ?? '')
        .where((p) => p.endsWith('.md') || p.endsWith('.txt'))
        .map((p) => p.split('/').last)
        .where((name) => name.isNotEmpty)
        .toList();
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

  void dispose() {
    _url = null;
    _user = null;
    _pass = null;
  }
}
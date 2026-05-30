import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import '../handlers/file_handler.dart';
import '../handlers/doc_handler.dart';
import '../handlers/quiz_handler.dart';
import '../handlers/ai_handler.dart';

/// 创建 REST API 路由，包含 CORS 中间件和静态资源路由。
Router createRouter({
  required FileHandler fileHandler,
  required DocHandler docHandler,
  required QuizHandler quizHandler,
  required AiHandler aiHandler,
}) {
  final router = Router();

  // 文件 API
  router.get('/api/files', (shelf.Request req) async {
    final result = await fileHandler.listFiles();
    return _jsonResponse(result);
  });

  router.post('/api/files/upload', (shelf.Request req) async {
    final result = await fileHandler.upload(req);
    return _jsonResponse(result);
  });

  router.get('/api/files/<id>/download', (shelf.Request req) async {
    final id = req.params['id']!;
    final result = await fileHandler.download(id);
    return result;
  });

  // 文档 API
  router.get('/api/docs', (shelf.Request req) async {
    final result = await docHandler.listDocs();
    return _jsonResponse(result);
  });

  router.get('/api/docs/<id>', (shelf.Request req) async {
    final id = req.params['id']!;
    final result = await docHandler.getDoc(id);
    return _jsonResponse(result);
  });

  // 答题 API
  router.get('/api/quiz', (shelf.Request req) async {
    final result = await quizHandler.getQuestions(req);
    return _jsonResponse(result);
  });

  router.post('/api/quiz/submit', (shelf.Request req) async {
    final result = await quizHandler.submitAnswer(req);
    return _jsonResponse(result);
  });

  // AI 问答 API
  router.post('/api/ai/ask', (shelf.Request req) async {
    final result = await aiHandler.ask(req);
    return _jsonResponse(result);
  });

  // 404
  router.all('/<path|.*>', (shelf.Request req) {
    return shelf.Response.notFound(
      jsonEncode({'error': 'Not found'}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

/// CORS 中间件，允许跨域请求。
shelf.Middleware corsMiddleware() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) async {
      if (request.method == 'OPTIONS') {
        return shelf.Response.ok('', headers: _corsHeaders());
      }
      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders());
    };
  };
}

/// 日志中间件，记录请求路径和状态码。
shelf.Middleware logMiddleware() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) async {
      final stopwatch = Stopwatch()..start();
      final response = await innerHandler(request);
      stopwatch.stop();
      // ignore: avoid_print
      print('[${request.method}] ${request.requestedUri.path} → ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
      return response;
    };
  };
}

Map<String, String> _corsHeaders() => {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };

shelf.Response _jsonResponse(Map<String, dynamic> data) {
  return shelf.Response.ok(
    jsonEncode(data),
    headers: {'content-type': 'application/json'},
  );
}

import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'handlers/file_handler.dart';
import 'handlers/doc_handler.dart';
import 'handlers/quiz_handler.dart';
import 'handlers/ai_handler.dart';

shelf.Router createRouter({
  required FileHandler fileHandler,
  required DocHandler docHandler,
  required QuizHandler quizHandler,
  required AiHandler aiHandler,
}) {
  final router = shelf.Router();

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

  router.get('/api/docs', (shelf.Request req) async {
    final result = await docHandler.listDocs();
    return _jsonResponse(result);
  });

  router.get('/api/docs/<id>', (shelf.Request req) async {
    final id = req.params['id']!;
    final result = await docHandler.getDoc(id);
    return _jsonResponse(result);
  });

  router.get('/api/quiz', (shelf.Request req) async {
    final result = await quizHandler.getQuestions(req);
    return _jsonResponse(result);
  });

  router.post('/api/quiz/submit', (shelf.Request req) async {
    final result = await quizHandler.submitAnswer(req);
    return _jsonResponse(result);
  });

  router.post('/api/ai/ask', (shelf.Request req) async {
    final result = await aiHandler.ask(req);
    return _jsonResponse(result);
  });

  router.all('/<path|.*>', (shelf.Request req) {
    return shelf.Response.notFound(jsonEncode({'error': 'Not found'}), headers: {'content-type': 'application/json'});
  });

  return router;
}

shelf.Response _jsonResponse(dynamic data) {
  return shelf.Response.ok(jsonEncode(data), headers: {'content-type': 'application/json'});
}
import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;

class AiHandler {
  final dynamic _ragService;
  AiHandler(this._ragService);

  Future<Map<String, dynamic>> ask(shelf.Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);
      final query = data['query'] as String;
      final response = await _ragService.answer(query: query, conversationId: 0);
      return {'answer': response.answer, 'citations': response.citations.map((c) => {'docId': c.docId, 'title': c.title, 'snippet': c.snippet}).toList()};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
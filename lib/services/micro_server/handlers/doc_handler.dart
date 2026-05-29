import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;

class DocHandler {
  final dynamic _documentRepository;
  DocHandler(this._documentRepository);

  Future<Map<String, dynamic>> listDocs() async {
    try {
      final docs = await _documentRepository.getByCategory(0);
      return {'docs': docs.map((d) => {'id': d.id, 'title': d.title, 'updatedAt': d.updatedAt}).toList()};
    } catch (e) {
      return {'error': e.toString(), 'docs': []};
    }
  }

  Future<Map<String, dynamic>> getDoc(String id) async {
    try {
      final doc = await _documentRepository.getByCategory(0);
      final found = doc.firstWhere((d) => d.id.toString() == id, orElse: () => null);
      if (found == null) return {'error': 'Document not found'};
      return {'id': found.id, 'title': found.title, 'contentText': found.contentText, 'wordCount': found.wordCount};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:core/database/repositories/document_repository.dart';
import 'package:core/database/dao/document_dao.dart';

/// 文档 API Handler，提供文档列表和内容阅读接口。
class DocHandler {
  final DocumentDao _documentDao;
  final DocumentRepository _documentRepository;

  DocHandler({
    required DocumentDao documentDao,
    required DocumentRepository documentRepository,
  })  : _documentDao = documentDao,
        _documentRepository = documentRepository;

  /// 获取文档列表，支持按类目过滤和分页。
  Future<Map<String, dynamic>> listDocs({String? categoryId, int limit = 50}) async {
    try {
      final catId = categoryId != null ? int.tryParse(categoryId) : null;
      final docs = catId != null
          ? await _documentDao.getByCategory(catId)
          : await _documentDao.getByCategory(0, includeDeleted: false);
      return {
        'docs': docs.take(limit).map((d) => {
              'id': d.id,
              'title': d.title,
              'categoryId': d.categoryId,
              'wordCount': d.wordCount,
              'updatedAt': d.updatedAt,
            }).toList(),
      };
    } catch (e) {
      return {'error': '获取文档列表失败: $e', 'docs': []};
    }
  }

  /// 获取单个文档详情（通过 ID 直接查询）。
  Future<Map<String, dynamic>> getDoc(String id) async {
    try {
      final docId = int.tryParse(id);
      if (docId == null) return {'error': '无效的文档 ID'};

      final doc = await _documentDao.getById(docId);
      if (doc == null) return {'error': '文档不存在'};

      return {
        'id': doc.id,
        'title': doc.title,
        'contentText': doc.contentText,
        'summary': doc.summary,
        'wordCount': doc.wordCount,
        'readingTime': doc.readingTime,
        'categoryId': doc.categoryId,
        'createdAt': doc.createdAt,
        'updatedAt': doc.updatedAt,
      };
    } catch (e) {
      return {'error': '获取文档失败: $e'};
    }
  }
}

import '../dao/document_dao.dart';
import '../dao/reading_log_dao.dart';
import '../models/document.dart';
import '../models/reading_log.dart';
import '../../services/file_service.dart';
import '../../services/import_service.dart';

/// 文档业务异常。
class DocumentBusinessException implements Exception {
  final String message;
  const DocumentBusinessException(this.message);

  @override
  String toString() => 'DocumentBusinessException: $message';
}

/// 文档业务仓库，组合 [DocumentDao]、[FileService] 和 [ImportService]。
class DocumentRepository {
  final DocumentDao _documentDao;
  final ReadingLogDao _readingLogDao;
  final FileService _fileService;
  final ImportService _importService;

  DocumentRepository({
    required DocumentDao documentDao,
    required ReadingLogDao readingLogDao,
    required FileService fileService,
    required ImportService importService,
  })  : _documentDao = documentDao,
        _readingLogDao = readingLogDao,
        _fileService = fileService,
        _importService = importService;

  /// 创建新文档：写入 DB 记录 + 创建 .md 文件。
  Future<Document> createDocument({
    required int categoryId,
    required String title,
    String? initialContent,
  }) async {
    final content = initialContent ?? '';
    final fileName = _fileService.generateFileName(title);

    // 写入文件系统。
    await _fileService.writeContent(fileName, content);

    // 写入数据库。
    final doc = Document(
      id: 0,
      title: title,
      fileName: fileName,
      filePath: fileName,
      categoryId: categoryId,
      contentText: content,
      wordCount: content.length,
      readingTime: 0,
      readCount: 0,
      isDeleted: 0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final id = await _documentDao.insert(doc);

    return doc.copyWith(id: id);
  }

  /// 导入外部文件并创建文档。
  Future<Document> importFile({
    required int categoryId,
    required String filePath,
  }) async {
    final result = await _importService.importFile(filePath);

    final title = result['title'] ?? '未命名文档';
    final content = result['content'] ?? '';
    final format = result['format'] ?? 'unknown';

    final fileName = _fileService.generateFileName(title);
    await _fileService.writeContent(fileName, content);

    final doc = Document(
      id: 0,
      title: title,
      fileName: fileName,
      filePath: fileName,
      categoryId: categoryId,
      originalFormat: format,
      originalFilePath: filePath,
      contentText: content,
      wordCount: content.length,
      readingTime: 0,
      readCount: 0,
      isDeleted: 0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final id = await _documentDao.insert(doc);
    return doc.copyWith(id: id);
  }

  /// 读取文档内容。
  Future<String> readContent(int docId) async {
    final doc = await _documentDao.getById(docId);
    if (doc == null) {
      throw DocumentBusinessException('文档不存在: id=$docId');
    }
    if (doc.filePath == null) {
      throw DocumentBusinessException('文档无关联文件: id=$docId');
    }
    return await _fileService.readContent(doc.filePath!);
  }

  /// 保存文档内容。
  Future<void> saveContent(int docId, String content) async {
    final doc = await _documentDao.getById(docId);
    if (doc == null) {
      throw DocumentBusinessException('文档不存在: id=$docId');
    }
    if (doc.filePath == null) {
      throw DocumentBusinessException('文档无关联文件: id=$docId');
    }
    await _fileService.writeContent(doc.filePath!, content);
    await _documentDao.update(doc.copyWith(
      contentText: content,
      wordCount: content.length,
    ));
  }

  /// 删除文档（软删除 + 删除文件）。
  Future<void> deleteDocument(int docId) async {
    final doc = await _documentDao.getById(docId);
    if (doc == null) {
      throw DocumentBusinessException('文档不存在: id=$docId');
    }
    await _documentDao.softDelete(docId);
  }

  /// 开始阅读日志。
  Future<void> startReadingLog(int docId) async {
    final log = ReadingLog(
      id: 0,
      docId: docId,
      startTime: DateTime.now().toIso8601String(),
    );
    await _readingLogDao.insert(log);
  }

  /// 结束阅读日志并更新阅读统计。
  Future<void> endReadingLog(int docId, int durationSeconds) async {
    await _documentDao.updateReadingStats(docId, durationSeconds);
  }

  /// 按类目获取文档列表。
  Future<List<Document>> getByCategory(
    int categoryId, {
    bool includeDeleted = false,
  }) =>
      _documentDao.getByCategory(categoryId, includeDeleted: includeDeleted);

  /// 搜索文档。
  Future<List<Document>> search(String query) =>
      _documentDao.search(query);

  /// 获取最近阅读的文档。
  Future<List<Document>> getRecentlyRead({int days = 7, int limit = 20}) =>
      _documentDao.getRecentlyRead(days: days, limit: limit);

  /// 获取阅读 Top/Bottom 文档。
  Future<List<Document>> getTopRead({int limit = 5, bool ascending = false}) =>
      _documentDao.getTopRead(limit: limit, ascending: ascending);
}

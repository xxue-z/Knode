import 'dart:async';

import '../dao/document_dao.dart';
import '../dao/reading_log_dao.dart';
import '../dao/settings_dao.dart';
import '../../models/document.dart';
import '../../models/reading_log.dart';
import '../../services/file_service.dart';

import '../../gen/strings.dart';

const _strings = L10nStringsMixin();

/// 文档业务异常。
class DocumentBusinessException implements Exception {
  final String message;
  const DocumentBusinessException(this.message);

  @override
  String toString() => 'DocumentBusinessException: $message';
}

/// 文件导入函数类型，由外部注入。
typedef ImportFileFunction = Future<Map<String, dynamic>> Function(String filePath);

/// 标签生成函数类型，由外部注入。
typedef GenerateTagsFunction = Future<List<String>> Function(String content);

/// 链接解析函数类型，由外部注入。
typedef ParseLinksFunction = List<String> Function(String content);

/// 文档业务仓库，组合 [DocumentDao]、[FileService] 和导入函数。
class DocumentRepository {
  final DocumentDao _documentDao;
  final ReadingLogDao _readingLogDao;
  final FileService _fileService;
  final ImportFileFunction? _importFn;
  final GenerateTagsFunction? _generateTagsFn;
  final ParseLinksFunction? _parseLinksFn;
  final SettingsDao? _settingsDao;

  DocumentRepository({
    required DocumentDao documentDao,
    required ReadingLogDao readingLogDao,
    required FileService fileService,
    ImportFileFunction? importFn,
    GenerateTagsFunction? generateTagsFn,
    ParseLinksFunction? parseLinksFn,
    SettingsDao? settingsDao,
  })  : _documentDao = documentDao,
        _readingLogDao = readingLogDao,
        _fileService = fileService,
        _importFn = importFn,
        _generateTagsFn = generateTagsFn,
        _parseLinksFn = parseLinksFn,
        _settingsDao = settingsDao;

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
    if (_importFn == null) {
      throw DocumentBusinessException('导入功能未配置');
    }

    final result = await _importFn(filePath);

    final title = (result['title'] as String?) ?? _strings.core_unnamed_document;
    final content = (result['content'] as String?) ?? '';
    final format = (result['format'] as String?) ?? 'unknown';

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

    // 异步触发标签生成和链接解析（仅在内容实际发生变化时）。
    if (doc.contentText != content) {
      _triggerTagGeneration(docId, doc);
      _triggerLinksParsing(docId, content);
    }
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

  /// 手动更新文档标签。
  Future<void> updateTags(int docId, List<String> tags) async {
    await _documentDao.updateTags(docId, tags);
    await _documentDao.update(
      (await _documentDao.getById(docId))!.copyWith(manualTags: 1),
    );
  }

  /// 获取文档模型。
  Future<Document?> getDocument(int docId) async {
    return await _documentDao.getById(docId);
  }

  /// 检查自动标签生成功能是否开启。
  Future<bool> _isAutoTagGenerationEnabled() async {
    if (_settingsDao == null) return true;
    final value = await _settingsDao!.get('auto_generate_tags');
    // 默认开启；显式设为 'false' 时关闭。
    return value != 'false';
  }

  /// 异步触发标签生成。
  void _triggerTagGeneration(int docId, Document doc) {
    if (_generateTagsFn == null) return;
    // 未手动编辑过标签时才自动生成。
    if (doc.manualTags == 1) return;
    final content = doc.contentText ?? '';
    if (content.isEmpty) return;

    Future.microtask(() async {
      try {
        if (!await _isAutoTagGenerationEnabled()) return;
        final tags = await _generateTagsFn!(content);
        await _documentDao.updateTags(docId, tags);
      } catch (_) {
        // 标签生成失败不阻塞文档保存。
      }
    });
  }

  /// 异步解析 Markdown 引用链接。
  void _triggerLinksParsing(int docId, String content) {
    if (_parseLinksFn == null) return;
    Future.microtask(() async {
      try {
        final refTitles = _parseLinksFn!(content);
        final linksTo = <int>[];

        for (final title in refTitles) {
          final results = await _documentDao.search(title);
          for (final r in results) {
            if (r.id != docId && !linksTo.contains(r.id)) {
              linksTo.add(r.id);
            }
          }
        }

        await _documentDao.updateLinksTo(docId, linksTo);
      } catch (_) {
        // 链接解析失败不阻塞文档保存。
      }
    });
  }
}

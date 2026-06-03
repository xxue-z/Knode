import 'dart:io';
import 'package:doc_text_extractor/doc_text_extractor.dart';
import 'package:core/utils/file_picker_util.dart';
import 'package:path/path.dart' as p;

/// 文件导入服务，将 PDF/DOCX/MD/TXT 转换为 Markdown 存入知识库。
///
/// 使用 `doc_text_extractor` 包统一处理各格式的文本提取。
class ImportService {
  final TextExtractor _extractor = TextExtractor();

  /// 将 PDF 文件转换为 Markdown。
  ///
  /// 使用 `doc_text_extractor` 提取全文，按页分隔。
  Future<Map<String, String>> importPdf(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('文件不存在', filePath);
    }

    try {
      final result = await _extractor.extractText(filePath);
      final content = result.text.trim();

      return {
        'content': content.isEmpty ? '（PDF 文件无文本内容，可能为扫描件）' : content,
        'title': result.filename ?? _extractTitle(filePath),
        'format': 'pdf',
        'original_file_path': filePath,
      };
    } catch (e) {
      throw Exception('PDF 导入失败: $e');
    }
  }

  /// 将 DOCX 文件转换为 Markdown。
  ///
  /// 使用 `doc_text_extractor` 解析 Word 文档，保留段落结构。
  Future<Map<String, String>> importDocx(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('文件不存在', filePath);
    }

    try {
      final result = await _extractor.extractText(filePath);
      final content = result.text.trim();

      return {
        'content': content.isEmpty ? '（DOCX 文件无文本内容）' : content,
        'title': result.filename ?? _extractTitle(filePath),
        'format': 'docx',
        'original_file_path': filePath,
      };
    } catch (e) {
      throw Exception('DOCX 导入失败: $e');
    }
  }

  /// 读取 Markdown 文件内容。
  Future<Map<String, String>> importMarkdown(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('文件不存在', filePath);
    }

    try {
      final content = await file.readAsString();
      return {
        'content': content,
        'title': _extractTitle(filePath),
        'format': 'markdown',
        'original_file_path': filePath,
      };
    } catch (e) {
      throw Exception('Markdown 导入失败: $e');
    }
  }

  /// 读取纯文本文件，按空行分段转为 Markdown。
  Future<Map<String, String>> importText(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('文件不存在', filePath);
    }

    try {
      final raw = await file.readAsString();
      final paragraphs = raw
          .split(RegExp(r'\n\s*\n'))
          .where((p) => p.trim().isNotEmpty)
          .map((p) => p.trim())
          .join('\n\n');
      return {
        'content': paragraphs,
        'title': _extractTitle(filePath),
        'format': 'text',
        'original_file_path': filePath,
      };
    } catch (e) {
      throw Exception('文本文件导入失败: $e');
    }
  }

  /// 使用 file_picker 选择文件并导入。
  Future<Map<String, String>?> pickAndImport() async {
    final filePath = await FilePickerUtil.pickSingleFile(
      type: FileType.custom,
      allowedExtensions: ['md', 'txt', 'pdf', 'docx'],
    );

    if (filePath == null) {
      throw Exception('无法获取文件路径');
    }

    return importFile(filePath);
  }

  /// 根据文件扩展名路由到对应的导入方法。
  Future<Map<String, String>> importFile(String filePath) async {
    final ext = _getExtension(filePath);
    switch (ext) {
      case 'md':
      case 'markdown':
        return importMarkdown(filePath);
      case 'txt':
        return importText(filePath);
      case 'pdf':
        return importPdf(filePath);
      case 'docx':
        return importDocx(filePath);
      default:
        throw UnsupportedError('不支持的文件格式: .$ext');
    }
  }

  void dispose() {}

  // ── 私有方法 ─────────────────────────────────────────────────────

  String _getExtension(String filePath) {
    return p.extension(filePath).replaceFirst('.', '').toLowerCase();
  }

  String _extractTitle(String filePath) {
    final base = p.basenameWithoutExtension(filePath);
    return base
        .replaceAll(RegExp(r'[_-]'), ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .trim();
  }
}

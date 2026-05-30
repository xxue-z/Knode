import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// 数据导出服务，支持将 Markdown 内容导出为多种格式并分享。
class ExportService {
  /// 将 Markdown 内容导出为 PDF 文件并分享。
  ///
  /// 使用 `pdf` 包生成真正的 PDF 文档，支持标题、段落、列表、引用等基本排版。
  Future<File> exportToPdf(String markdownContent, String fileName) async {
    try {
      final sanitized = _sanitizeFileName(fileName);
      final directory = await _getExportDirectory();
      final filePath = p.join(directory.path, '$sanitized.pdf');
      final file = File(filePath);

      final pdf = pw.Document();
      final lines = markdownContent.split('\n');
      final widgets = <pw.Widget>[];

      for (final line in lines) {
        widgets.add(_markdownLineToPdfWidget(line));
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Knode',
              style: pw.TextStyle(
                color: PdfColors.grey400,
                fontSize: 8,
              ),
            ),
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(
                color: PdfColors.grey400,
                fontSize: 8,
              ),
            ),
          ),
          build: (context) => widgets,
        ),
      );

      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      await shareFile(filePath);
      return file;
    } catch (e) {
      throw ExportException('导出 PDF 失败: $e');
    }
  }

  /// 将 Markdown 内容导出为 DOCX 文件并分享。
  ///
  /// 手动构造合法的 DOCX 文件（ZIP 格式，包含 word/document.xml 等必要文件）。
  Future<File> exportToDocx(String markdownContent, String fileName) async {
    try {
      final sanitized = _sanitizeFileName(fileName);
      final directory = await _getExportDirectory();
      final filePath = p.join(directory.path, '$sanitized.docx');
      final file = File(filePath);

      final archive = Archive();

      // [Content_Types].xml
      archive.addFile(ArchiveFile(
        '[Content_Types].xml',
        _contentTypesXml.codeUnits.length,
        _contentTypesXml.codeUnits,
      ));

      // _rels/.rels
      archive.addFile(ArchiveFile(
        '_rels/.rels',
        _relsXml.codeUnits.length,
        _relsXml.codeUnits,
      ));

      // word/_rels/document.xml.rels
      archive.addFile(ArchiveFile(
        'word/_rels/document.xml.rels',
        _documentRelsXml.codeUnits.length,
        _documentRelsXml.codeUnits,
      ));

      // word/document.xml
      final documentXml = _markdownToDocxXml(markdownContent);
      archive.addFile(ArchiveFile(
        'word/document.xml',
        documentXml.codeUnits.length,
        documentXml.codeUnits,
      ));

      final zipBytes = ZipEncoder().encode(archive);
      await file.writeAsBytes(zipBytes as Uint8List);

      await shareFile(filePath);
      return file;
    } catch (e) {
      throw ExportException('导出 DOCX 失败: $e');
    }
  }

  /// 将 Markdown 内容导出为纯文本文件并分享。
  Future<File> exportToText(String markdownContent, String fileName) async {
    try {
      final sanitized = _sanitizeFileName(fileName);
      final directory = await _getExportDirectory();
      final filePath = p.join(directory.path, '$sanitized.txt');
      final file = File(filePath);

      final plainText = _stripMarkdown(markdownContent);
      await file.writeAsString(plainText);

      await shareFile(filePath);
      return file;
    } catch (e) {
      throw ExportException('导出纯文本失败: $e');
    }
  }

  /// 将 Markdown 内容导出为 Markdown 文件。
  Future<File> exportToMarkdown(String markdownContent, String fileName) async {
    try {
      final sanitized = _sanitizeFileName(fileName);
      final directory = await _getExportDirectory();
      final filePath = p.join(directory.path, '$sanitized.md');
      final file = File(filePath);
      await file.writeAsString(markdownContent);
      return file;
    } catch (e) {
      throw ExportException('导出 Markdown 失败: $e');
    }
  }

  /// 导出指定文档为 Markdown 文件。
  Future<File> exportDocument({
    required String content,
    required String title,
    required String outputPath,
  }) async {
    try {
      final dir = Directory(outputPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final sanitizedTitle = _sanitizeFileName(title);
      final file = File(p.join(outputPath, '$sanitizedTitle.md'));
      await file.writeAsString(content);
      return file;
    } catch (e) {
      throw ExportException('导出文档失败: $e');
    }
  }

  /// 导出多个文档到指定目录。
  Future<int> exportMultiple({
    required Map<String, String> documents,
    required String outputPath,
  }) async {
    try {
      final dir = Directory(outputPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      int count = 0;
      for (final entry in documents.entries) {
        final file = File(p.join(outputPath, entry.key));
        await file.writeAsString(entry.value);
        count++;
      }
      return count;
    } catch (e) {
      throw ExportException('批量导出失败: $e');
    }
  }

  /// 通过系统分享面板分享文件。
  Future<void> shareFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ExportException('要分享的文件不存在: $filePath');
    }

    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      throw ExportException('分享文件失败: $e');
    }
  }

  /// 释放资源，清理临时文件。
  Future<void> dispose() async {
    try {
      final tempDir = await _getExportDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      // ignore: avoid_print
      print('ExportService dispose 清理失败: $e');
    }
  }

  // ── PDF 辅助方法 ─────────────────────────────────────────────────

  /// 将单行 Markdown 转换为 PDF Widget。
  pw.Widget _markdownLineToPdfWidget(String line) {
    final trimmed = line.trimRight();

    // 空行
    if (trimmed.isEmpty) {
      return pw.SizedBox(height: 8);
    }

    // 标题
    if (trimmed.startsWith('### ')) {
      return pw.Header(
        level: 2,
        child: pw.Text(
          trimmed.substring(4),
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      );
    }
    if (trimmed.startsWith('## ')) {
      return pw.Header(
        level: 1,
        child: pw.Text(
          trimmed.substring(3),
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      );
    }
    if (trimmed.startsWith('# ')) {
      return pw.Header(
        level: 0,
        child: pw.Text(
          trimmed.substring(2),
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
      );
    }

    // 分隔线
    if (RegExp(r'^---+$').hasMatch(trimmed)) {
      return pw.Divider(thickness: 0.5);
    }

    // 引用块
    if (trimmed.startsWith('> ')) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(left: 16, top: 4, bottom: 4),
        padding: const pw.EdgeInsets.only(left: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: PdfColors.grey400, width: 2),
          ),
        ),
        child: pw.Text(
          trimmed.substring(2),
          style: pw.TextStyle(
            color: PdfColors.grey700,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      );
    }

    // 无序列表
    if (RegExp(r'^[-*+]\s+').hasMatch(trimmed)) {
      final text = trimmed.replaceFirst(RegExp(r'^[-*+]\s+'), '');
      return pw.Bullet(text: _stripInlineMarkdown(text));
    }

    // 有序列表
    if (RegExp(r'^\d+\.\s+').hasMatch(trimmed)) {
      final text = trimmed.replaceFirst(RegExp(r'^\d+\.\s+'), '');
      return pw.Bullet(text: _stripInlineMarkdown(text));
    }

    // 普通段落
    return pw.Paragraph(
      text: _stripInlineMarkdown(trimmed),
      style: const pw.TextStyle(fontSize: 11),
    );
  }

  /// 移除行内 Markdown 标记（粗体、斜体、代码、链接等）。
  String _stripInlineMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')
        .replaceAll(RegExp(r'__(.+?)__'), r'$1')
        .replaceAll(RegExp(r'_(.+?)_'), r'$1')
        .replaceAll(RegExp(r'~~(.+?)~~'), r'$1')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]+\)'), r'$1');
  }

  // ── DOCX 辅助方法 ────────────────────────────────────────────────

  /// 将 Markdown 文本转换为 DOCX 的 document.xml 内容。
  String _markdownToDocxXml(String markdown) {
    final buffer = StringBuffer();
    buffer.write(_docxXmlHeader);

    final lines = markdown.split('\n');
    for (final line in lines) {
      final trimmed = line.trimRight();

      if (trimmed.isEmpty) {
        buffer.write('<w:p/>');
        continue;
      }

      // 标题
      final headingMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(trimmed);
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final text = headingMatch.group(2)!;
        buffer.write(
          '<w:p><w:pPr><w:pStyle w:val="Heading$level"/></w:pPr>'
          '<w:r><w:rPr><w:b/><w:sz w:val="${32 - level * 4}"/></w:rPr>'
          '<w:t xml:space="preserve">${_escapeXml(text)}</w:t></w:r></w:p>',
        );
        continue;
      }

      // 分隔线
      if (RegExp(r'^---+$').hasMatch(trimmed)) {
        buffer.write(
          '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="CCCCCC"/></w:pBdr></w:pPr></w:p>',
        );
        continue;
      }

      // 引用块
      if (trimmed.startsWith('> ')) {
        final text = trimmed.substring(2);
        buffer.write(
          '<w:p><w:pPr><w:ind w:left="720"/><w:pBdr>'
          '<w:left w:val="single" w:sz="12" w:space="8" w:color="CCCCCC"/>'
          '</w:pBdr></w:pPr>'
          '<w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr>'
          '<w:t xml:space="preserve">${_escapeXml(text)}</w:t></w:r></w:p>',
        );
        continue;
      }

      // 无序列表
      if (RegExp(r'^[-*+]\s+').hasMatch(trimmed)) {
        final text = trimmed.replaceFirst(RegExp(r'^[-*+]\s+'), '');
        buffer.write(
          '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr>'
          '${_inlineTextToRuns(text)}</w:p>',
        );
        continue;
      }

      // 有序列表
      if (RegExp(r'^\d+\.\s+').hasMatch(trimmed)) {
        final text = trimmed.replaceFirst(RegExp(r'^\d+\.\s+'), '');
        buffer.write(
          '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="2"/></w:numPr></w:pPr>'
          '${_inlineTextToRuns(text)}</w:p>',
        );
        continue;
      }

      // 普通段落
      buffer.write('<w:p>${_inlineTextToRuns(trimmed)}</w:p>');
    }

    buffer.write(_docxXmlFooter);
    return buffer.toString();
  }

  /// 将包含行内 Markdown 标记的文本转换为 DOCX 的 <w:r> 元素。
  ///
  /// 支持 **粗体**、*斜体*、`代码`、[链接](url) 的转换。
  String _inlineTextToRuns(String text) {
    final buffer = StringBuffer();
    // 用正则拆分行内格式
    final pattern = RegExp(
      r'\*\*(.+?)\*\*'       // 粗体
      r'|\*(.+?)\*'          // 斜体
      r'|`([^`]+)`'          // 代码
      r'|\[([^\]]+)\]\(([^)]+)\)' // 链接
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // 匹配前的普通文本
      if (match.start > lastEnd) {
        final plain = text.substring(lastEnd, match.start);
        buffer.write('<w:r><w:t xml:space="preserve">${_escapeXml(plain)}</w:t></w:r>');
      }

      if (match.group(1) != null) {
        // 粗体
        buffer.write(
          '<w:r><w:rPr><w:b/></w:rPr>'
          '<w:t xml:space="preserve">${_escapeXml(match.group(1)!)}</w:t></w:r>',
        );
      } else if (match.group(2) != null) {
        // 斜体
        buffer.write(
          '<w:r><w:rPr><w:i/></w:rPr>'
          '<w:t xml:space="preserve">${_escapeXml(match.group(2)!)}</w:t></w:r>',
        );
      } else if (match.group(3) != null) {
        // 代码
        buffer.write(
          '<w:r><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/>'
          '<w:shd w:val="clear" w:fill="F0F0F0"/></w:rPr>'
          '<w:t xml:space="preserve">${_escapeXml(match.group(3)!)}</w:t></w:r>',
        );
      } else if (match.group(4) != null && match.group(5) != null) {
        // 链接 — 作为蓝色带下划线文本输出
        buffer.write(
          '<w:r><w:rPr><w:color w:val="0563C1"/><w:u w:val="single"/></w:rPr>'
          '<w:t xml:space="preserve">${_escapeXml(match.group(4)!)}</w:t></w:r>',
        );
      }

      lastEnd = match.end;
    }

    // 匹配后的剩余文本
    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd);
      buffer.write('<w:r><w:t xml:space="preserve">${_escapeXml(remaining)}</w:t></w:r>');
    }

    return buffer.toString();
  }

  /// XML 实体转义。
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  // ── DOCX XML 模板 ────────────────────────────────────────────────

  static const _docxXmlHeader = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<w:body>''';

  static const _docxXmlFooter = '''</w:body></w:document>''';

  static const _contentTypesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';

  static const _relsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

  static const _documentRelsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
</Relationships>''';

  // ── 通用辅助方法 ─────────────────────────────────────────────────

  Future<Directory> _getExportDirectory() async {
    final tempDir = Directory.systemTemp;
    final exportDir = Directory(p.join(tempDir.path, 'knode_export'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  String _stripMarkdown(String markdown) {
    return markdown
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')
        .replaceAll(RegExp(r'__(.+?)__'), r'$1')
        .replaceAll(RegExp(r'_(.+?)_'), r'$1')
        .replaceAll(RegExp(r'~~(.+?)~~'), r'$1')
        .replaceAll(RegExp(r'`{1,3}[^`]*`{1,3}'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^>\s+', multiLine: true), '')
        .replaceAll(RegExp(r'---+'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

/// 导出操作异常。
class ExportException implements Exception {
  ExportException(this.message);

  final String message;

  @override
  String toString() => 'ExportException: $message';
}

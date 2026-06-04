import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum AppLogLevel { verbose, debug, info, warning, error, fatal }

class LogEntry {
  final DateTime timestamp;
  final AppLogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  String toFormattedString() {
    final timeStr = timestamp.toString().substring(0, 23);
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag] ' : '';
    final errorStr = error != null ? '\n  ERROR: $error' : '';
    final stackStr = stackTrace != null ? '\n  STACK: $stackTrace' : '';
    return '$timeStr $levelStr $tagStr$message$errorStr$stackStr';
  }

  static LogEntry? parse(String line) {
    final pattern = RegExp(
      r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})\s+'
      r'(VERBOSE|DEBUG  |INFO   |WARNING|ERROR  |FATAL  )\s+'
      r'(?:\[([^\]]*)\]\s+)?'
      r'(.+)$',
    );
    final match = pattern.firstMatch(line);
    if (match == null) return null;

    final levelMap = {
      'VERBOSE': AppLogLevel.verbose,
      'DEBUG  ': AppLogLevel.debug,
      'INFO   ': AppLogLevel.info,
      'WARNING': AppLogLevel.warning,
      'ERROR  ': AppLogLevel.error,
      'FATAL  ': AppLogLevel.fatal,
    };

    return LogEntry(
      timestamp: DateTime.tryParse(match.group(1)!) ?? DateTime.now(),
      level: levelMap[match.group(2)!] ?? AppLogLevel.info,
      message: match.group(4) ?? '',
      tag: match.group(3),
    );
  }
}

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  late final Logger _logger;
  late final FileOutput _fileOutput;
  String? _logDirPath;

  AppLogLevel _minLevel = AppLogLevel.debug;

  static const int _maxFileCount = 3;

  Future<void> init({AppLogLevel minLevel = AppLogLevel.debug}) async {
    _minLevel = minLevel;

    final appDir = await getApplicationDocumentsDirectory();
    _logDirPath = p.join(appDir.path, 'logs');
    final logDir = Directory(_logDirPath!);
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    _fileOutput = FileOutput(logDirPath: _logDirPath!);

    _logger = Logger(
      filter: _AppLogFilter(minLevel: _minLevel),
      printer: SimplePrinter(printTime: true, colors: false),
      output: MultiOutput([ConsoleOutput(), _fileOutput]),
    );

    // 全局拦截 debugPrint，统一走 AppLogger 输出到控制台+文件
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message == null || message.isEmpty) return;
      _logger.d(message);
    };

    await _rotateIfNeeded();
  }

  void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.t(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.d(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.i(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.w(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.e(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void f(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.f(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _formatMessage(String message, String? tag) {
    return tag != null ? '[$tag] $message' : message;
  }

  Future<List<LogEntry>> getLogs({
    AppLogLevel? level,
    String? keyword,
    int limit = 500,
  }) async {
    if (_logDirPath == null) return [];

    final entries = <LogEntry>[];
    final logDir = Directory(_logDirPath!);
    if (!await logDir.exists()) return [];

    final files = await logDir
        .list()
        .where((e) => e is File && e.path.endsWith('.log'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));

    for (final file in files) {
      final lines = await file.readAsLines();
      for (final line in lines.reversed) {
        final entry = LogEntry.parse(line);
        if (entry == null) continue;

        if (level != null && entry.level.index < level.index) continue;

        if (keyword != null && keyword.isNotEmpty) {
          final kw = keyword.toLowerCase();
          if (!entry.message.toLowerCase().contains(kw) &&
              !(entry.tag?.toLowerCase().contains(kw) ?? false)) {
            continue;
          }
        }

        entries.add(entry);
        if (entries.length >= limit) return entries;
      }
    }

    return entries;
  }

  Future<String> exportLogs({AppLogLevel? level}) async {
    final logs = await getLogs(level: level, limit: 10000);
    return logs.map((e) => e.toFormattedString()).join('\n');
  }

  Future<void> clearLogs() async {
    if (_logDirPath == null) return;
    final logDir = Directory(_logDirPath!);
    if (await logDir.exists()) {
      await for (final entity in logDir.list()) {
        if (entity is File && entity.path.endsWith('.log')) {
          await entity.delete();
        }
      }
    }
  }

  Future<int> getLogsSize() async {
    if (_logDirPath == null) return 0;
    final logDir = Directory(_logDirPath!);
    if (!await logDir.exists()) return 0;

    int total = 0;
    await for (final entity in logDir.list()) {
      if (entity is File && entity.path.endsWith('.log')) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<String> getLogsSizeFormatted() async {
    final size = await getLogsSize();
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _rotateIfNeeded() async {
    if (_logDirPath == null) return;
    final logDir = Directory(_logDirPath!);
    if (!await logDir.exists()) return;

    final files = await logDir
        .list()
        .where((e) => e is File && e.path.endsWith('.log'))
        .cast<File>()
        .toList();
    files.sort((a, b) => a.path.compareTo(b.path));

    while (files.length > _maxFileCount) {
      await files.removeAt(0).delete();
    }
  }
}

class _AppLogFilter extends LogFilter {
  final AppLogLevel minLevel;
  _AppLogFilter({required this.minLevel});

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >=
        Level.values
            .firstWhere(
              (l) => l.name == minLevel.name,
              orElse: () => Level.debug,
            )
            .index;
  }
}

class FileOutput extends LogOutput {
  final String logDirPath;
  IOSink? _sink;
  File? _currentFile;

  FileOutput({required this.logDirPath});

  @override
  void output(OutputEvent event) {
    final line = event.lines.join('\n');
    _writeToFile(line);
  }

  void _writeToFile(String line) {
    try {
      final now = DateTime.now();
      final fileName =
          'app_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.log';
      final file = File('$logDirPath/$fileName');

      if (_currentFile?.path != file.path) {
        _sink?.flush();
        _sink?.close();
        _currentFile = file;
        _sink = file.openWrite(mode: FileMode.append);
      }

      _sink?.writeln(line);
    } catch (_) {}
  }

  @override
  Future<void> destroy() async {
    _sink?.flush();
    _sink?.close();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/services/app_logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  List<LogEntry> _logs = [];
  bool _isLoading = true;
  AppLogLevel? _filterLevel;
  String _searchKeyword = '';
  String _logsSize = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await AppLogger.instance.getLogs(
      level: _filterLevel,
      keyword: _searchKeyword.isEmpty ? null : _searchKeyword,
      limit: 1000,
    );
    final size = await AppLogger.instance.getLogsSizeFormatted();
    if (mounted) {
      setState(() {
        _logs = logs;
        _logsSize = size;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchKeyword = value;
      _loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.knode_app_log_viewer),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: _strings.knode_app_log_export,
            onPressed: _exportLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: _strings.knode_app_log_clear,
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildStatsBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? Center(child: Text(_strings.knode_app_log_no_logs))
                    : _buildLogList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<AppLogLevel?>(
              value: _filterLevel,
              decoration: InputDecoration(
                labelText: _strings.knode_app_log_level,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(_strings.knode_app_log_all)),
                ...AppLogLevel.values.map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(level.name.toUpperCase()),
                )),
              ],
              onChanged: (value) {
                setState(() => _filterLevel = value);
                _loadLogs();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                hintText: _strings.knode_app_log_search_hint,
                border: const OutlineInputBorder(),
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '${_strings.knode_app_log_all}: ${_logs.length}  |  $_logsSize',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return ListView.builder(
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final entry = _logs[index];
        return _LogEntryTile(entry: entry);
      },
    );
  }

  Future<void> _exportLogs() async {
    final content = await AppLogger.instance.exportLogs(level: _filterLevel);
    await Share.share(content, subject: 'Knode App Logs');
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_log_clear),
        content: Text(_strings.knode_app_log_clear_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_strings.knode_app_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_strings.knode_app_log_clear),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AppLogger.instance.clearLogs();
      _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_log_clear_success)),
        );
      }
    }
  }
}

class _LogEntryTile extends StatefulWidget {
  final LogEntry entry;
  const _LogEntryTile({required this.entry});

  @override
  State<_LogEntryTile> createState() => _LogEntryTileState();
}

class _LogEntryTileState extends State<_LogEntryTile> {
  bool _expanded = false;

  Color _levelColor(AppLogLevel level) {
    switch (level) {
      case AppLogLevel.verbose:
        return Colors.grey;
      case AppLogLevel.debug:
        return Colors.blue;
      case AppLogLevel.info:
        return Colors.green;
      case AppLogLevel.warning:
        return Colors.orange;
      case AppLogLevel.error:
        return Colors.red;
      case AppLogLevel.fatal:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final color = _levelColor(entry.level);
    final hasDetails = entry.error != null || entry.stackTrace != null;

    return InkWell(
      onTap: hasDetails ? () => setState(() => _expanded = !_expanded) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.timestamp.toString().substring(11, 23),
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    entry.level.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.message,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (hasDetails)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
            if (_expanded && hasDetails) ...[
              const SizedBox(height: 8),
              if (entry.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${entry.error}',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              if (entry.stackTrace != null) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${entry.stackTrace}',
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.copy, size: 14),
                  label: Text(_strings.core_copy, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    final text = entry.toFormattedString();
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_strings.knode_app_log_copied)),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

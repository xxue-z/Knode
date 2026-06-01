import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';

/// 文档内全文搜索栏。
///
/// 显示匹配计数 + 上一个/下一个按钮。
class FullTextSearchBar extends StatefulWidget {
  final String documentText;
  final String? initialKeyword;
  final void Function(int offset) onNavigate;
  final VoidCallback onClose;

  const FullTextSearchBar({
    super.key,
    required this.documentText,
    this.initialKeyword,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  State<FullTextSearchBar> createState() => _FullTextSearchBarState();
}

class _FullTextSearchBarState extends State<FullTextSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  List<int> _matchOffsets = [];
  int _currentMatchIndex = -1;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
      _searchController.text = widget.initialKeyword!;
      _search(widget.initialKeyword!);
    }
  }

  void _search(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        _matchOffsets = [];
        _currentMatchIndex = -1;
      });
      return;
    }

    final offsets = <int>[];
    int startIndex = 0;
    final lowerText = widget.documentText.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();

    while (true) {
      final index = lowerText.indexOf(lowerKeyword, startIndex);
      if (index == -1) break;
      offsets.add(index);
      startIndex = index + 1;
    }

    setState(() {
      _matchOffsets = offsets;
      _currentMatchIndex = offsets.isEmpty ? -1 : 0;
    });

    AppLogger.instance.d('全文搜索: "$keyword", ${offsets.length} 个匹配', tag: 'FullTextSearch');

    if (offsets.isNotEmpty) {
      widget.onNavigate(offsets[0]);
    }
  }

  void _goToPrevious() {
    if (_matchOffsets.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1 + _matchOffsets.length) % _matchOffsets.length;
    });
    widget.onNavigate(_matchOffsets[_currentMatchIndex]);
  }

  void _goToNext() {
    if (_matchOffsets.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matchOffsets.length;
    });
    widget.onNavigate(_matchOffsets[_currentMatchIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索文档...',
                isDense: true,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _matchOffsets.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${_currentMatchIndex + 1}/${_matchOffsets.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    : null,
              ),
              onSubmitted: _search,
              onChanged: _search,
            ),
          ),
          if (_matchOffsets.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up, size: 20),
              onPressed: _goToPrevious,
              tooltip: '上一个匹配',
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              onPressed: _goToNext,
              tooltip: '下一个匹配',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _matchOffsets = [];
                _currentMatchIndex = -1;
              });
              widget.onClose();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

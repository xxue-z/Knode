import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/document_repository.dart';
import '../../../providers/document_provider.dart';
import 'quill_editor.dart';

/// 文档编辑页面。
///
/// 使用 flutter_quill 实现所见即所得 MD 编辑，
/// 支持源码模式切换，自动保存（防抖）。
class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({
    super.key,
    required this.docId,
    this.title,
  });

  final int docId;
  final String? title;

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  /// 编辑器模式：true = 富文本，false = 源码。
  bool _isRichTextMode = true;

  /// 自动保存防抖定时器。
  Timer? _debounceTimer;

  /// 是否有未保存的修改。
  bool _hasUnsavedChanges = false;

  /// 当前标题（可编辑）。
  late TextEditingController _titleController;

  /// 源码模式的文本控制器。
  final TextEditingController _sourceController = TextEditingController();

  /// 文档内容是否已加载。
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final repo = ref.read(documentRepositoryProvider);
      final content = await repo.readContent(widget.docId);
      _sourceController.text = content;
      setState(() => _isLoaded = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载内容失败: $e')),
        );
      }
    }
  }

  void _onContentChanged() {
    _hasUnsavedChanges = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), _autoSave);
  }

  Future<void> _autoSave() async {
    if (!_hasUnsavedChanges) return;
    await _saveContent();
  }

  Future<void> _saveContent() async {
    try {
      final repo = ref.read(documentRepositoryProvider);
      await repo.saveContent(widget.docId, _sourceController.text);
      _hasUnsavedChanges = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已自动保存'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  void _toggleMode() {
    setState(() => _isRichTextMode = !_isRichTextMode);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoaded
            ? SizedBox(
                width: 200,
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '文档标题',
                  ),
                  onChanged: (_) => _onContentChanged(),
                ),
              )
            : const Text('加载中...'),
        centerTitle: true,
        actions: [
          // 模式切换按钮。
          IconButton(
            icon: Icon(_isRichTextMode ? Icons.code : Icons.format_quote),
            tooltip: _isRichTextMode ? '切换到源码模式' : '切换到富文本模式',
            onPressed: _toggleMode,
          ),
          // 手动保存按钮。
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: '保存',
            onPressed: _saveContent,
          ),
        ],
      ),
      body: _isLoaded
          ? _isRichTextMode
              ? QuillEditorWidget(
                  content: _sourceController.text,
                  onChanged: (plainText) {
                    _sourceController.text = plainText;
                    _onContentChanged();
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _sourceController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Markdown 源码...',
                    ),
                    onChanged: (_) => _onContentChanged(),
                  ),
                )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

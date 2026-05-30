import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiki/gen/strings.dart';

import 'package:wiki/providers/document_provider.dart';
import 'package:core/services/tts_service.dart';
import 'package:core/providers/service_providers.dart';

final _strings = const L10nStringsMixin();

/// 沉浸式阅读页面。
///
/// 全屏无干扰阅读，点击屏幕中央弹出浮动工具栏，
/// 支持 TTS 朗读、选中文字弹出菜单（AI讲解/生成题目/复制）。
class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({
    super.key,
    required this.docId,
    this.title,
  });

  final int docId;
  final String? title;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final TtsService _ttsService = TtsService();

  /// 是否显示浮动工具栏。
  bool _showToolbar = false;

  /// TTS 朗读状态。
  bool _isSpeaking = false;

  /// 阅读设置参数。
  double _fontSize = 16.0;
  double _lineSpacing = 1.6;
  Color _backgroundColor = Colors.white;
  bool _isDarkMode = false;

  /// 文档内容。
  String _content = '';
  bool _isLoading = true;

  /// 上次触发菜单的选区，避免重复弹出。
  TextSelection? _lastMenuSelection;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadContent();
    _ttsService.onPlayStateChanged = (playing) {
      if (mounted) setState(() => _isSpeaking = playing);
    };
    _textController.addListener(_onSelectionChanged);
  }

  Future<void> _loadContent() async {
    try {
      final repo = ref.read(documentRepositoryProvider);
      final content = await repo.readContent(widget.docId);
      setState(() {
        _content = content;
        _textController.text = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.wiki_error}: $e')),
        );
      }
    }
  }

  /// 监听选区变化，当用户选中文字时弹出上下文菜单。
  void _onSelectionChanged() {
    final selection = _textController.selection;
    if (selection.isCollapsed) {
      _lastMenuSelection = null;
      return;
    }
    if (selection == _lastMenuSelection) return;
    if (selection.baseOffset < 0 || selection.extentOffset < 0) return;

    final selectedText = selection.textInside(_textController.text);
    if (selectedText.isEmpty) return;

    _lastMenuSelection = selection;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showSelectionContextMenu(selectedText);
    });
  }

  void _toggleToolbar() {
    setState(() => _showToolbar = !_showToolbar);
  }

  /// 真实上下文菜单 —— showModalBottomSheet 替代 SnackBar 占位符。
  void _showSelectionContextMenu(String selectedText) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('AI讲解'),
              subtitle: Text(
                '对"${_truncate(selectedText, 20)}"进行讲解',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.pop(context);
                _explainWithAI(selectedText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('生成题目'),
              subtitle: Text(
                '基于"${_truncate(selectedText, 20)}"生成题目',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.pop(context);
                _generateQuizFromText(selectedText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: selectedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _truncate(String text, int max) {
    return text.length > max ? '${text.substring(0, max)}...' : text;
  }

  Future<void> _explainWithAI(String selectedText) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在生成 AI 讲解...')),
    );
    try {
      final aiProvider = ref.read(aiProviderRef);
      final response = await aiProvider.generateAnswer(
        query: '请用简洁的中文讲解以下内容：\n\n$selectedText',
        contextDocs: [selectedText],
        systemPrompt: '你是一位专业的知识讲解助手，请用通俗易懂的语言解释用户选中的内容。',
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('AI 讲解'),
            content: SingleChildScrollView(child: Text(response.answer)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI 讲解失败: $e')),
        );
      }
    }
  }

  Future<void> _generateQuizFromText(String selectedText) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在生成题目...')),
    );
    try {
      final aiProvider = ref.read(aiProviderRef);
      final result = await aiProvider.generateQuiz(
        content: selectedText,
        minCount: 2,
        maxCount: 5,
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('生成的题目'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.questions.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('${e.key + 1}. ${e.value.stem}'),
                )).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('题目生成失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onSelectionChanged);
    _textController.dispose();
    _ttsService.dispose();
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF1E1E1E) : _backgroundColor;
    final textColor = _isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: _toggleToolbar,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // ── 主内容区（全屏沉浸式，无 AppBar / BottomNav） ──
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: _isDarkMode ? Colors.white54 : null,
                ),
              )
            else
              SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: TextField(
                    controller: _textController,
                    readOnly: true,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: _lineSpacing,
                      color: textColor,
                    ),
                  ),
                ),
              ),

            // ── 浮动工具栏（点击屏幕中央切换显隐） ──
            AnimatedOpacity(
              opacity: _showToolbar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showToolbar,
                child: GestureDetector(
                  onTap: _toggleToolbar,
                  child: Container(
                    color: Colors.black45,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 返回按钮
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),

                            // 标题
                            if (widget.title != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: Text(
                                  widget.title!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            // ── TTS 控制 ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  iconSize: 36,
                                  color: Colors.white,
                                  icon: Icon(
                                    _isSpeaking
                                        ? Icons.stop_circle
                                        : Icons.play_circle_outline,
                                  ),
                                  onPressed: () {
                                    if (_isSpeaking) {
                                      _ttsService.stop();
                                    } else {
                                      _ttsService.speak(_content);
                                    }
                                  },
                                ),
                                if (_isSpeaking) ...[
                                  const SizedBox(width: 16),
                                  IconButton(
                                    iconSize: 36,
                                    color: Colors.white,
                                    icon: const Icon(Icons.pause_circle_outline),
                                    onPressed: () => _ttsService.pause(),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 32),

                            // ── 字体大小控制 ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  color: Colors.white,
                                  icon: const Icon(Icons.text_decrease),
                                  onPressed: () {
                                    setState(() {
                                      _fontSize =
                                          (_fontSize - 1).clamp(12.0, 28.0);
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    '${_fontSize.round()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  color: Colors.white,
                                  icon: const Icon(Icons.text_increase),
                                  onPressed: () {
                                    setState(() {
                                      _fontSize =
                                          (_fontSize + 1).clamp(12.0, 28.0);
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── 行间距控制 ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.format_line_spacing,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: _lineSpacing,
                                    min: 1.0,
                                    max: 3.0,
                                    divisions: 10,
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white30,
                                    label: _lineSpacing.toStringAsFixed(1),
                                    onChanged: (v) =>
                                        setState(() => _lineSpacing = v),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    _lineSpacing.toStringAsFixed(1),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // ── 夜间模式切换 ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.light_mode,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                Switch(
                                  value: _isDarkMode,
                                  onChanged: (v) => setState(() {
                                    _isDarkMode = v;
                                    _backgroundColor =
                                        v ? const Color(0xFF1E1E1E) : Colors.white;
                                  }),
                                ),
                                const Icon(
                                  Icons.dark_mode,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
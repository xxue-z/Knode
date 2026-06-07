import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiki/gen/strings.dart';

import 'package:wiki/providers/document_provider.dart';
import 'package:wiki/providers/reader_provider.dart';
import 'package:wiki/widgets/tag_chip_list.dart';
import 'package:wiki/widgets/tag_editor_dialog.dart';
import 'package:core/models/document.dart';
import 'package:core/services/tts_service.dart';
import 'package:core/providers/service_providers.dart';

final _strings = const L10nStringsMixin();

/// Full-screen immersive reader page.
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

  bool _showBars = false;
  int _activeBottomPanel = -1;
  bool _isSpeaking = false;
  double _speechRate = 0.5;

  double _fontSize = 16.0;
  double _letterSpacing = 0.0;
  double _lineSpacing = 1.6;
  Color _backgroundColor = Colors.white;
  bool _isDarkMode = false;

  String _content = '';
  Document? _document;
  bool _isLoading = true;
  TextSelection? _lastMenuSelection;
  List<String> _paragraphs = [];
  int _currentParagraphIndex = 0;

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
      final docList = await repo.getByCategory(0, includeDeleted: true);
      final matches = docList.where((d) => d.id == widget.docId);
      final doc = matches.isNotEmpty ? matches.first : null;
      setState(() {
        _content = content;
        _document = doc;
        _textController.text = content;
        _isLoading = false;
        _paragraphs = content
            .split(RegExp(r'\n+'))
            .where((p) => p.trim().isNotEmpty)
            .toList();
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

  void _showSelectionContextMenu(String selectedText) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text(_strings.wiki_ai_explanation),
              subtitle: Text(
                '${_strings.wiki_explain_text}: "${_truncate(selectedText, 20)}"',
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
              title: Text(_strings.wiki_generate_question),
              onTap: () {
                Navigator.pop(context);
                _generateQuizFromText(selectedText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: Text(_strings.wiki_copy),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: selectedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(_strings.wiki_copied_to_clipboard)),
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
      SnackBar(
          content: Text(_strings.wiki_generating_ai_explanation)),
    );
    try {
      final aiProvider = ref.read(aiProviderRef);
      final response = await aiProvider.generateAnswer(
        query:
            '${_strings.wiki_please_explain}: \n\n$selectedText',
        contextDocs: [selectedText],
        systemPrompt: _strings.wiki_system_prompt_explain,
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(_strings.wiki_ai_explanation),
            content:
                SingleChildScrollView(child: Text(response.answer)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_strings.wiki_close),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${_strings.wiki_ai_explanation_failed}: $e')));
      }
    }
  }

  Future<void> _generateQuizFromText(String selectedText) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_strings.wiki_generating_questions)),
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
            title: Text(_strings.wiki_generated_questions),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.questions
                    .asMap()
                    .entries
                    .map(
                      (e) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: Text(
                            '${e.key + 1}. ${e.value.stem}'),
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_strings.wiki_close),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${_strings.wiki_question_generation_failed}: $e')));
      }
    }
  }

  void _toggleBars() {
    setState(() => _showBars = !_showBars);
    if (!_showBars) setState(() => _activeBottomPanel = -1);
  }

  void _onBottomNavTap(int index) {
    if (index == 2) {
      if (_activeBottomPanel == 2) {
        _stopTts();
        setState(() => _activeBottomPanel = -1);
      } else {
        _startTts();
        setState(() => _activeBottomPanel = 2);
      }
    } else {
      setState(() =>
          _activeBottomPanel = _activeBottomPanel == index ? -1 : index);
    }
  }

  // ── TTS ──
  void _startTts() {
    if (_content.isEmpty) return;
    _ttsService.setSpeechRate(_speechRate);
    _ttsService.speak(_content);
    setState(() {
      _isSpeaking = true;
      _currentParagraphIndex = 0;
    });
  }

  void _pauseTts() {
    _ttsService.pause();
    setState(() => _isSpeaking = false);
  }

  void _stopTts() {
    _ttsService.stop();
    setState(() {
      _isSpeaking = false;
      _currentParagraphIndex = 0;
    });
  }

  void _ttsPrevParagraph() {
    if (_currentParagraphIndex > 0) {
      setState(() => _currentParagraphIndex--);
      _stopTts();
      _startTts();
    }
  }

  void _ttsNextParagraph() {
    if (_currentParagraphIndex < _paragraphs.length - 1) {
      setState(() => _currentParagraphIndex++);
      _stopTts();
      _startTts();
    }
  }

  Future<void> _editTags() async {
    if (_document == null) return;
    final updatedTags =
        await TagEditorDialog.show(context, tags: _document!.tags);
    if (updatedTags != null && mounted) {
      final repo = ref.read(documentRepositoryProvider);
      await repo.updateTags(widget.docId, updatedTags);
      setState(() {
        _document =
            _document!.copyWith(tags: updatedTags, manualTags: 1);
      });
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
    final bgColor =
        _isDarkMode ? const Color(0xFF1E1E1E) : _backgroundColor;
    final textColor = _isDarkMode ? Colors.white70 : Colors.black87;
    final readerState = ref.watch(readerProvider(widget.docId));

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: _toggleBars,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: _buildContent(textColor)),
            _buildTopBar(),
            _buildBottomNav(),
            if (_activeBottomPanel == 0)
              _buildBookmarksPanel(readerState),
            if (_activeBottomPanel == 1)
              _buildNotesPanel(readerState),
            if (_activeBottomPanel == 2 && _isSpeaking)
              _buildTtsPanel(),
            if (_activeBottomPanel == 3) _buildInterfacePanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: _isDarkMode ? Colors.white54 : null,
        ),
      );
    }
    return SingleChildScrollView(
      controller: _scrollController,
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
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
              letterSpacing: _letterSpacing,
            ),
          ),
          const SizedBox(height: 16),
          if (_document != null && _document!.tags.isNotEmpty)
            TagChipList(
              tags: _document!.tags,
              isEditable: true,
              onEdit: () => _editTags(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final isDark = _isDarkMode;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      top: _showBars ? 0 : -60,
      left: 0,
      right: 0,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black87
              : Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color:
                        isDark ? Colors.white70 : Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.title ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit,
                    color:
                        isDark ? Colors.white70 : Colors.black87),
                onPressed: () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                        content:
                            Text('Edit mode coming soon'))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.bookmark, 'Bookmarks'),
      (Icons.note, 'Notes'),
      (Icons.volume_up, 'TTS'),
      (Icons.settings, 'Interface'),
    ];
    final isDark = _isDarkMode;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      bottom: _showBars ? 0 : -60,
      left: 0,
      right: 0,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black87
              : Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final (icon, label) = items[i];
              final active = _activeBottomPanel == i;
              return GestureDetector(
                onTap: () => _onBottomNavTap(i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          size: 22,
                          color: active
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                              : (isDark
                                  ? Colors.white70
                                  : Colors.black87)),
                      const SizedBox(height: 2),
                      Text(label,
                          style: TextStyle(
                              fontSize: 10,
                              color: active
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                  : (isDark
                                      ? Colors.white70
                                      : Colors.black87))),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksPanel(AsyncValue<ReaderState> rs) {
    final bookmarks = rs.value?.bookmarks ?? [];
    final isDark = _isDarkMode;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    return Positioned(
      top: 56,
      left: 0,
      bottom: 56,
      width: MediaQuery.of(context).size.width * 0.75,
      child: GestureDetector(
        onTap: () {},
        child: Material(
          elevation: 8,
          color: isDark ? Colors.grey[900] : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bookmarks',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    IconButton(
                        icon: Icon(Icons.close,
                            color: textColor, size: 20),
                        onPressed: () => setState(
                            () => _activeBottomPanel = -1)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: bookmarks.isEmpty
                    ? Center(
                        child: Text('No bookmarks yet',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey)))
                    : ListView.builder(
                        itemCount: bookmarks.length,
                        itemBuilder: (_, i) {
                          final b = bookmarks[i];
                          return ListTile(
                            leading:
                                const Icon(Icons.bookmark, size: 20),
                            title: Text(b.selectedText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    const TextStyle(fontSize: 14)),
                            subtitle: Text(b.label ?? '',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18),
                              onPressed: () => ref
                                  .read(readerProvider(
                                          widget.docId)
                                      .notifier)
                                  .removeBookmark(
                                      b.id!, widget.docId),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesPanel(AsyncValue<ReaderState> rs) {
    final highlights = rs.value?.highlights ?? [];
    final isDark = _isDarkMode;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    return Positioned(
      top: 56,
      left: 0,
      bottom: 56,
      width: MediaQuery.of(context).size.width * 0.75,
      child: GestureDetector(
        onTap: () {},
        child: Material(
          elevation: 8,
          color: isDark ? Colors.grey[900] : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notes & Highlights',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    IconButton(
                        icon: Icon(Icons.close,
                            color: textColor, size: 20),
                        onPressed: () => setState(
                            () => _activeBottomPanel = -1)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: highlights.isEmpty
                    ? Center(
                        child: Text('No highlights yet',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey)))
                    : ListView.builder(
                        itemCount: highlights.length,
                        itemBuilder: (_, i) {
                          final h = highlights[i];
                          return ListTile(
                            leading: Icon(Icons.highlight,
                                color: Colors.amber[400],
                                size: 20),
                            title: Text(h.selectedText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    const TextStyle(fontSize: 14)),
                            subtitle: h.noteText != null
                                ? Text(h.noteText!,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTtsPanel() {
    final isDark = _isDarkMode;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    return Positioned(
      bottom: 60,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {},
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.grey[850] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        icon: Icon(Icons.skip_previous,
                            color: textColor),
                        onPressed: _ttsPrevParagraph),
                    IconButton(
                      icon: Icon(
                        _isSpeaking
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        size: 44,
                      ),
                      onPressed:
                          _isSpeaking ? _pauseTts : _startTts,
                    ),
                    IconButton(
                        icon: Icon(Icons.stop_circle,
                            color: textColor),
                        onPressed: _stopTts),
                    IconButton(
                        icon: Icon(Icons.skip_next,
                            color: textColor),
                        onPressed: _ttsNextParagraph),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Speed',
                        style: TextStyle(
                            fontSize: 12, color: textColor)),
                    Expanded(
                      child: Slider(
                        value: _speechRate,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        activeColor: Theme.of(context)
                            .colorScheme
                            .primary,
                        onChanged: (v) {
                          setState(() => _speechRate = v);
                          _ttsService.setSpeechRate(v);
                        },
                      ),
                    ),
                    Text('${_speechRate.toStringAsFixed(1)}x',
                        style: TextStyle(
                            fontSize: 12, color: textColor)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterfacePanel() {
    final isDark = _isDarkMode;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.33,
      child: GestureDetector(
        onTap: () {},
        child: Material(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          elevation: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reading Settings',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    IconButton(
                        icon: Icon(Icons.close,
                            color: textColor, size: 20),
                        onPressed: () => setState(
                            () => _activeBottomPanel = -1)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _sliderRow(
                        'Font Size',
                        _fontSize,
                        12,
                        28,
                        16,
                        _fontSize.round().toString(),
                        (v) => setState(() => _fontSize = v),
                        textColor),
                    _sliderRow(
                        'Letter Spacing',
                        _letterSpacing,
                        -1.0,
                        5.0,
                        12,
                        _letterSpacing.toStringAsFixed(1),
                        (v) =>
                            setState(() => _letterSpacing = v),
                        textColor),
                    _sliderRow(
                        'Line Spacing',
                        _lineSpacing,
                        1.0,
                        3.0,
                        10,
                        _lineSpacing.toStringAsFixed(1),
                        (v) =>
                            setState(() => _lineSpacing = v),
                        textColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderRow(
      String label,
      double value,
      double min,
      double max,
      int divisions,
      String display,
      ValueChanged<double> onChanged,
      Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
              width: 90,
              child: Text(label,
                  style:
                      TextStyle(fontSize: 13, color: textColor))),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor:
                  Theme.of(context).colorScheme.primary,
              inactiveColor:
                  _isDarkMode ? Colors.white24 : Colors.grey[300],
              onChanged: onChanged,
            ),
          ),
          SizedBox(
              width: 36,
              child: Text(display,
                  textAlign: TextAlign.end,
                  style:
                      TextStyle(fontSize: 13, color: textColor))),
        ],
      ),
    );
  }
}
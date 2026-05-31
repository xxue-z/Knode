import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/ai/prompt_manager.dart';
import 'package:core/providers/service_providers.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// Maps agent names to i18n display name keys.
String _editorDisplayNameFor(String agentName) {
  const map = {
    'qa_with_rag': 'prompt_rag_qa',
    'quiz_generator': 'prompt_quiz_gen',
    'intent_analyzer': 'prompt_intent',
    'summarizer': 'prompt_summary',
    'grader': 'prompt_grader',
    'tag_generator': 'prompt_tag_gen',
    'question_variant': 'prompt_question_variant',
    'periodic_exam_generator': 'prompt_periodic_exam',
    'search_agent': 'prompt_search',
  };
  switch (map[agentName]) {
    case 'prompt_rag_qa': return _strings.knode_app_prompt_rag_qa;
    case 'prompt_quiz_gen': return _strings.knode_app_prompt_quiz_gen;
    case 'prompt_intent': return _strings.knode_app_prompt_intent;
    case 'prompt_summary': return _strings.knode_app_prompt_summary;
    case 'prompt_grader': return _strings.knode_app_prompt_grader;
    case 'prompt_tag_gen': return _strings.knode_app_prompt_tag_gen;
    case 'prompt_question_variant': return _strings.knode_app_prompt_question_variant;
    case 'prompt_periodic_exam': return _strings.knode_app_prompt_periodic_exam;
    case 'prompt_search': return _strings.knode_app_prompt_search;
    default: return agentName;
  }
}

class PromptEditorScreen extends ConsumerStatefulWidget {
  final String agentName;
  const PromptEditorScreen({super.key, required this.agentName});

  @override
  ConsumerState<PromptEditorScreen> createState() =>
      _PromptEditorScreenState();
}

class _PromptEditorScreenState extends ConsumerState<PromptEditorScreen> {
  late TextEditingController _controller;
  String? _original;
  bool _loading = true;
  bool _expanded = true;
  String? _error;

  String get _displayName => _editorDisplayNameFor(widget.agentName);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final manager = ref.read(promptManagerProvider);
      final original = await manager.getOriginalTemplate(widget.agentName);
      final custom = await manager.getCustomTemplate(widget.agentName);
      if (mounted) {
        setState(() {
          _original = original;
          _controller.text = custom ?? original;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<String> get _variables =>
      PromptManager.extractVariables(_controller.text);

  bool get _hasChanges =>
      _original != null && _controller.text != _original;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displayName),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetToDefault,
            child: Text(_strings.knode_app_reset_override),
          ),
          if (_hasChanges)
            TextButton(
              onPressed: _save,
              child: Text(_strings.knode_app_save),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildEditor(),
    );
  }

  Widget _buildEditor() {
    final theme = Theme.of(context);
    final vars = _variables;
    return Column(
      children: [
        // Variable hint bar
        if (vars.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Text(
                  '${_strings.knode_app_variables}: ',
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                ...vars.map((v) => Chip(
                      label: Text('{$v}', style: const TextStyle(fontSize: 12)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )),
              ],
            ),
          ),
        // Original template (collapsible)
        if (_original != null)
          ExpansionTile(
            initiallyExpanded: _expanded,
            onExpansionChanged: (v) => setState(() => _expanded = v),
            title: Text(
              _strings.knode_app_original_template,
              style: theme.textTheme.titleSmall,
            ),
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: SingleChildScrollView(
                  child: Text(_original!, style: theme.textTheme.bodySmall),
                ),
              ),
            ],
          ),
        // Editable area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _strings.knode_app_prompt_edit_hint,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    try {
      final manager = ref.read(promptManagerProvider);
      await manager.saveCustomTemplate(widget.agentName, _controller.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_save_success)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_error}: $e')),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_reset_override),
        content: Text(_strings.knode_app_reset_single_confirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_strings.knode_app_cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(_strings.knode_app_confirm)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final manager = ref.read(promptManagerProvider);
      await manager.resetOverride(widget.agentName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_reset_success)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_error}: $e')),
        );
      }
    }
  }
}

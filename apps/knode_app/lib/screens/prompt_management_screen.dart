import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:file_picker/file_picker.dart';
import 'package:core/ai/prompt_manager.dart';
import 'package:core/providers/service_providers.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/prompt_editor_screen.dart';

final _strings = const L10nStringsMixin();

/// Maps agent names to i18n display name keys.
String _displayNameFor(String agentName) {
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
  // Use i18n key if available, otherwise fall back to agent name
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

class PromptManagementScreen extends ConsumerStatefulWidget {
  const PromptManagementScreen({super.key});

  @override
  ConsumerState<PromptManagementScreen> createState() =>
      _PromptManagementScreenState();
}

class _PromptManagementScreenState
    extends ConsumerState<PromptManagementScreen> {
  List<PromptTemplateInfo>? _templates;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final manager = ref.read(promptManagerProvider);
      final list = await manager.getAllTemplates();
      if (mounted) setState(() { _templates = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.knode_app_prompt_management),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (_) => [
              PopupMenuItem(value: 'export', child: Text(_strings.knode_app_export_data)),
              PopupMenuItem(value: 'import', child: Text(_strings.knode_app_import_data)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'reset_all', child: Text(_strings.knode_app_reset_all)),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    final templates = _templates!;
    if (templates.isEmpty) {
      return Center(child: Text(_strings.knode_app_no_templates));
    }
    return RefreshIndicator(
      onRefresh: _loadTemplates,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _buildTile(templates[i]),
      ),
    );
  }

  Widget _buildTile(PromptTemplateInfo info) {
    return ListTile(
      leading: Icon(
        info.hasCustom ? Icons.edit_note : Icons.description_outlined,
        color: info.hasCustom
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
      title: Text(_displayNameFor(info.agentName)),
      subtitle: Text(
        info.contentPreview,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (info.hasCustom)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _strings.knode_app_custom,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _openEditor(info),
    );
  }

  Future<void> _openEditor(PromptTemplateInfo info) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PromptEditorScreen(agentName: info.agentName)),
    );
    if (changed == true) _loadTemplates();
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'export':
        await _exportTemplates();
        break;
      case 'import':
        await _importTemplates();
        break;
      case 'reset_all':
        await _resetAll();
        break;
    }
  }

  Future<void> _exportTemplates() async {
    try {
      final manager = ref.read(promptManagerProvider);
      final json = await manager.exportAll();

      // Check if there are any custom templates
      final templates = await manager.getAllTemplates();
      final hasAnyCustom = templates.any((t) => t.hasCustom);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasAnyCustom
                ? '${_strings.knode_app_export_success} (${_strings.knode_app_copied_to_clipboard})'
                : _strings.knode_app_no_custom_templates),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_error}: $e')),
        );
      }
    }
  }

  Future<void> _importTemplates() async {
    if (!mounted) return;

    // Show import source dialog
    final source = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(_strings.knode_app_import_data),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'file'),
            child: ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: Text(_strings.knode_app_import_file),
              dense: true,
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'paste'),
            child: ListTile(
              leading: const Icon(Icons.paste_outlined),
              title: Text(_strings.knode_app_import_json_hint),
              dense: true,
            ),
          ),
        ],
      ),
    );
    if (source == null || !mounted) return;

    String? jsonString;

    if (source == 'file') {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.first.path;
      if (filePath == null) return;
      try {
        jsonString = await File(filePath).readAsString();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_strings.knode_app_error}: $e')),
          );
        }
        return;
      }
    } else {
      // Paste from clipboard
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(_strings.knode_app_import_data),
          content: TextField(
            controller: controller,
            maxLines: 8,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: _strings.knode_app_import_json_hint,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_strings.knode_app_cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(_strings.knode_app_confirm)),
          ],
        ),
      );
      if (confirmed != true) return;
      jsonString = controller.text;
    }

    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final manager = ref.read(promptManagerProvider);
      final count = await manager.importFromJson(jsonString);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_import_count(count: '$count'))),
        );
        _loadTemplates();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_error}: $e')),
        );
      }
    }
  }

  Future<void> _resetAll() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_reset_all),
        content: Text(_strings.knode_app_reset_all_confirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_strings.knode_app_cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(_strings.knode_app_confirm)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final manager = ref.read(promptManagerProvider);
      await manager.resetAllOverrides();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_reset_success)),
        );
        _loadTemplates();
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

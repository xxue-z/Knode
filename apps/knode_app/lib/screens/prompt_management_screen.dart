
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/ai/prompt_manager.dart';
import 'package:core/providers/service_providers.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/prompt_editor_screen.dart';

final _strings = const L10nStringsMixin();

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
      title: Text(info.displayName),
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
      await manager.exportAll();
      // Use share or clipboard for now
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_export_success)),
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
    // For now, show a dialog with a text field for JSON input
    if (!mounted) return;
    final controller = TextEditingController();
    final result = await showDialog<bool>(
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
    if (result != true) return;
    try {
      final manager = ref.read(promptManagerProvider);
      final count = await manager.importFromJson(controller.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_import_success} ($count)')),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:core/utils/file_picker_util.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

class StorageSettingsPage extends ConsumerStatefulWidget {
  const StorageSettingsPage({super.key});

  @override
  ConsumerState<StorageSettingsPage> createState() =>
      _StorageSettingsPageState();
}

class _StorageSettingsPageState extends ConsumerState<StorageSettingsPage> {
  String _currentPath = '';
  bool _isLoading = true;
  bool _isClearingCache = false;
  bool _isClearingResources = false;

  double _totalSpaceGB = 128.0;
  double _appUsedGB = 1.0;
  double _otherAppsUsedGB = 60.0;
  double _knodeUsedMB = 200.0;
  double _cacheMB = 200.0;
  double _resourcesMB = 200.0;
  double _essentialMB = 200.0;

  double get _remainingGB => _totalSpaceGB - _appUsedGB - _otherAppsUsedGB;
  double get _appUsedPercent => (_appUsedGB / _totalSpaceGB * 100);

  @override
  void initState() {
    super.initState();
    _loadPath();
  }

  Future<void> _loadPath() async {
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    final savedPath = settings['wiki_storage_path'];
    if (savedPath != null && savedPath.isNotEmpty) {
      _currentPath = savedPath;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _currentPath = '${dir.path}/knode_wiki';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _clearCache() async {
    setState(() => _isClearingCache = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _cacheMB = 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_cache_cleared)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_strings.knode_app_clear_cache_failed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isClearingCache = false);
  }

  Future<void> _clearResources() async {
    setState(() => _isClearingResources = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _resourcesMB = 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_resources_cleared)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_strings.knode_app_clear_resources_failed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isClearingResources = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.knode_app_storage_settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTotalSpaceBar(colorScheme),
          const SizedBox(height: 16),
          _buildKnodeSpaceInfo(colorScheme),
          const SizedBox(height: 24),
          _buildStorageSection(
            colorScheme: colorScheme,
            icon: Icons.cleaning_services_outlined,
            title: _strings.knode_app_cache,
            sizeMB: _cacheMB,
            description: _strings.knode_app_cache_description,
            onClear: _cacheMB > 0 ? _clearCache : null,
            isClearing: _isClearingCache,
          ),
          _buildStorageSection(
            colorScheme: colorScheme,
            icon: Icons.folder_special_outlined,
            title: _strings.knode_app_resource_files,
            sizeMB: _resourcesMB,
            description: _strings.knode_app_resource_files_description,
            onClear: _resourcesMB > 0 ? _clearResources : null,
            isClearing: _isClearingResources,
          ),
          _buildStorageSection(
            colorScheme: colorScheme,
            icon: Icons.lock_outline,
            title: _strings.knode_app_essential_files,
            sizeMB: _essentialMB,
            description: _strings.knode_app_essential_files_description,
            onClear: null,
            isClearing: false,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTotalSpaceBar(ColorScheme colorScheme) {
    final appFraction = _appUsedGB / _totalSpaceGB;
    final otherFraction = _otherAppsUsedGB / _totalSpaceGB;
    final remainFraction = _remainingGB / _totalSpaceGB;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_strings.knode_app_storage_overview,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                Expanded(
                  flex: (appFraction * 1000).toInt().clamp(1, 1000),
                  child: Tooltip(
                    message: _strings.knode_app_this_app_used + ': ' + _appUsedGB.toStringAsFixed(1) + ' GB',
                    child: Container(
                      color: colorScheme.primary,
                      alignment: Alignment.center,
                      child: Text(_strings.knode_app_this_app_used,
                          style: TextStyle(color: colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                Expanded(
                  flex: (otherFraction * 1000).toInt().clamp(1, 1000),
                  child: Tooltip(
                    message: _strings.knode_app_other_apps_used + ': ' + _otherAppsUsedGB.toStringAsFixed(0) + ' GB',
                    child: Container(
                      color: colorScheme.secondary,
                      alignment: Alignment.center,
                      child: Text(_strings.knode_app_other_apps_used,
                          style: TextStyle(color: colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                Expanded(
                  flex: (remainFraction * 1000).toInt().clamp(1, 1000),
                  child: Tooltip(
                    message: _strings.knode_app_free_space + ': ' + _remainingGB.toStringAsFixed(1) + ' GB',
                    child: Container(
                      color: colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Text(_strings.knode_app_free_space,
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          _legendDot(colorScheme.primary), const SizedBox(width: 4),
          Text(_strings.knode_app_this_app_used, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 12),
          _legendDot(colorScheme.secondary), const SizedBox(width: 4),
          Text(_strings.knode_app_other_apps_used, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 12),
          _legendDot(colorScheme.surfaceContainerHighest), const SizedBox(width: 4),
          Text(_strings.knode_app_free_space, style: const TextStyle(fontSize: 11)),
        ]),
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget _buildKnodeSpaceInfo(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(Icons.storage_outlined, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(_strings.knode_app_knode_used + ': ', style: const TextStyle(fontSize: 14)),
          Text((_knodeUsedMB / 1024).toStringAsFixed(1) + ' GB',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Text(_strings.knode_app_storage_percentage(percent: _appUsedPercent.toStringAsFixed(0)),
                style: TextStyle(fontSize: 11, color: colorScheme.onPrimaryContainer)),
          ),
        ]),
      ),
    );
  }

  Widget _buildStorageSection({
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required double sizeMB,
    required String description,
    VoidCallback? onClear,
    required bool isClearing,
  }) {
    final sizeText = sizeMB >= 1024
        ? (sizeMB / 1024).toStringAsFixed(1) + ' GB'
        : sizeMB.toStringAsFixed(0) + ' MB';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
              Text(sizeText, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
              if (onClear != null) ...[
                const SizedBox(width: 12),
                isClearing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(
                        onPressed: onClear,
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(_strings.knode_app_clean),
                      ),
              ],
            ]),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
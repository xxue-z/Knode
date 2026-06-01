import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart' as core;
import 'package:wiki/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 阅读器设置面板
class ReaderSettingsPanel extends ConsumerStatefulWidget {
  final core.ReaderSettings settings;
  final ValueChanged<core.ReaderSettings> onSettingsChanged;

  const ReaderSettingsPanel({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  ConsumerState<ReaderSettingsPanel> createState() =>
      _ReaderSettingsPanelState();
}

class _ReaderSettingsPanelState extends ConsumerState<ReaderSettingsPanel> {
  late core.ReaderSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _update(core.ReaderSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部
              Row(
                children: [
                  Icon(Icons.settings, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '阅读设置',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 字体大小
              _buildSectionHeader(_strings.font_size),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.text_decrease),
                    onPressed: () {
                      _update(
                        _settings.copyWith(
                          fontSize: (_settings.fontSize - 1).clamp(12.0, 28.0),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Slider(
                      value: _settings.fontSize,
                      min: 12.0,
                      max: 28.0,
                      divisions: 16,
                      label: _settings.fontSize.round().toString(),
                      onChanged: (value) {
                        _update(_settings.copyWith(fontSize: value));
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_increase),
                    onPressed: () {
                      _update(
                        _settings.copyWith(
                          fontSize: (_settings.fontSize + 1).clamp(12.0, 28.0),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${_settings.fontSize.round()}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 行间距
              _buildSectionHeader(_strings.line_spacing),
              Row(
                children: [
                  const Icon(Icons.format_line_spacing, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _settings.lineSpacing,
                      min: 1.0,
                      max: 3.0,
                      divisions: 10,
                      label: _settings.lineSpacing.toStringAsFixed(1),
                      onChanged: (value) {
                        _update(_settings.copyWith(lineSpacing: value));
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      _settings.lineSpacing.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 页边距
              _buildSectionHeader('页边距'),
              Row(
                children: [
                  const Icon(Icons.space_dashboard, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _settings.pageMargin,
                      min: 8.0,
                      max: 48.0,
                      divisions: 10,
                      label: _settings.pageMargin.round().toString(),
                      onChanged: (value) {
                        _update(_settings.copyWith(pageMargin: value));
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${_settings.pageMargin.round()}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 主题选择
              _buildSectionHeader('主题'),
              Wrap(
                spacing: 8,
                children: [
                  _ThemeOption(
                    label: '浅色',
                    color: Colors.white,
                    isSelected: _settings.theme == core.ReaderTheme.light,
                    onTap: () {
                      _update(_settings.copyWith(theme: core.ReaderTheme.light));
                    },
                  ),
                  _ThemeOption(
                    label: '护眼',
                    color: const Color(0xFFF4ECD8),
                    isSelected: _settings.theme == core.ReaderTheme.sepia,
                    onTap: () {
                      _update(_settings.copyWith(theme: core.ReaderTheme.sepia));
                    },
                  ),
                  _ThemeOption(
                    label: '深色',
                    color: const Color(0xFF1E1E1E),
                    isSelected: _settings.theme == core.ReaderTheme.dark,
                    onTap: () {
                      _update(_settings.copyWith(theme: core.ReaderTheme.dark));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

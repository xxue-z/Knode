import 'package:flutter/material.dart';

/// 阅读设置底部栏组件。
///
/// 可调节字体大小、行间距、背景颜色/夜间模式。
/// 作为 BottomSheet 弹出。
class ReaderToolbar extends StatefulWidget {
  const ReaderToolbar({
    super.key,
    required this.fontSize,
    required this.lineSpacing,
    required this.isDarkMode,
    required this.onFontSizeChanged,
    required this.onLineSpacingChanged,
    required this.onDarkModeChanged,
  });

  final double fontSize;
  final double lineSpacing;
  final bool isDarkMode;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<double> onLineSpacingChanged;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<ReaderToolbar> createState() => _ReaderToolbarState();
}

class _ReaderToolbarState extends State<ReaderToolbar> {
  late double _fontSize;
  late double _lineSpacing;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.fontSize;
    _lineSpacing = widget.lineSpacing;
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 拖拽指示条。
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 字体大小。
          Row(
            children: [
              const Icon(Icons.text_fields, size: 20),
              const SizedBox(width: 12),
              const Text('字号', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 12.0,
                  max: 28.0,
                  divisions: 16,
                  label: '${_fontSize.round()}',
                  onChanged: (v) {
                    setState(() => _fontSize = v);
                    widget.onFontSizeChanged(v);
                  },
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${_fontSize.round()}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 行间距。
          Row(
            children: [
              const Icon(Icons.format_line_spacing, size: 20),
              const SizedBox(width: 12),
              const Text('行距', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: _lineSpacing,
                  min: 1.0,
                  max: 3.0,
                  divisions: 10,
                  label: _lineSpacing.toStringAsFixed(1),
                  onChanged: (v) {
                    setState(() => _lineSpacing = v);
                    widget.onLineSpacingChanged(v);
                  },
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  _lineSpacing.toStringAsFixed(1),
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 夜间模式切换。
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 20,
            ),
            title: const Text('夜间模式', style: TextStyle(fontSize: 14)),
            value: _isDarkMode,
            onChanged: (v) {
              setState(() => _isDarkMode = v);
              widget.onDarkModeChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

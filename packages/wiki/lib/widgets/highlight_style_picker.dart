
import 'package:flutter/material.dart';
import 'package:core/models/highlight_style.dart';
import 'package:core/core.dart' as core;

/// 高亮样式选择器组件
class HighlightStylePicker extends StatefulWidget {
  final HighlightStyle initialStyle;
  final ValueChanged&lt;HighlightStyle&gt; onStyleChanged;

  const HighlightStylePicker({
    super.key,
    required this.initialStyle,
    required this.onStyleChanged,
  });

  @override
  State&lt;HighlightStylePicker&gt; createState() =&gt; _HighlightStylePickerState();
}

class _HighlightStylePickerState extends State&lt;HighlightStylePicker&gt; {
  late HighlightType _selectedType;
  late String _selectedColor;

  final List&lt;String&gt; _presetColors = [
    '#FFF176', // 黄色
    '#81C784', // 绿色
    '#64B5F6', // 蓝色
    '#F06292', // 粉色
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialStyle.type;
    _selectedColor = widget.initialStyle.colorHex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = core.CoreLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 类型选择
        Text(l10n.style, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _TypeButton(
              type: HighlightType.background,
              isSelected: _selectedType == HighlightType.background,
              label: l10n.background,
              onTap: () =&gt; _selectType(HighlightType.background),
            ),
            const SizedBox(width: 8),
            _TypeButton(
              type: HighlightType.underline,
              isSelected: _selectedType == HighlightType.underline,
              label: l10n.underline,
              onTap: () =&gt; _selectType(HighlightType.underline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 颜色选择
        Text(
          _selectedType == HighlightType.background ? l10n.background : l10n.underline,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _presetColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () =&gt; _selectColor(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _colorFromHex(color),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _selectType(HighlightType type) {
    setState(() =&gt; _selectedType = type);
    widget.onStyleChanged(HighlightStyle(type: _selectedType, colorHex: _selectedColor));
  }

  void _selectColor(String color) {
    setState(() =&gt; _selectedColor = color);
    widget.onStyleChanged(HighlightStyle(type: _selectedType, colorHex: _selectedColor));
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class _TypeButton extends StatelessWidget {
  final HighlightType type;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  const _TypeButton({
    required this.type,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

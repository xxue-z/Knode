import 'package:flutter/material.dart';
import 'package:core/models/highlight_style.dart';
import 'package:wiki/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 高亮样式选择器组件
class HighlightStylePicker extends StatefulWidget {
  final HighlightStyle initialStyle;
  final ValueChanged<HighlightStyle> onStyleChanged;

  const HighlightStylePicker({
    super.key,
    required this.initialStyle,
    required this.onStyleChanged,
  });

  @override
  State<HighlightStylePicker> createState() => _HighlightStylePickerState();
}

class _HighlightStylePickerState extends State<HighlightStylePicker> {
  late HighlightType _selectedType;
  late Color _selectedColor;

  final List<Color> _presetColors = [
    const Color(0xFFFFF176), // 黄色
    const Color(0xFF81C784), // 绿色
    const Color(0xFF64B5F6), // 蓝色
    const Color(0xFFF06292), // 粉色
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialStyle.type;
    _selectedColor = widget.initialStyle.color;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 类型选择
        Text(_strings.style, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _TypeButton(
              type: HighlightType.background,
              isSelected: _selectedType == HighlightType.background,
              label: _strings.background,
              onTap: () => _selectType(HighlightType.background),
            ),
            const SizedBox(width: 8),
            _TypeButton(
              type: HighlightType.underline,
              isSelected: _selectedType == HighlightType.underline,
              label: _strings.underline,
              onTap: () => _selectType(HighlightType.underline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 颜色选择
        Text(
          _selectedType == HighlightType.background ? _strings.background : _strings.underline,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _presetColors.map((color) {
            final isSelected = _selectedColor.value == color.value;
            return GestureDetector(
              onTap: () => _selectColor(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: theme.colorScheme.primary, width: 3)
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
    setState(() => _selectedType = type);
    widget.onStyleChanged(HighlightStyle(type: _selectedType, color: _selectedColor));
  }

  void _selectColor(Color color) {
    setState(() => _selectedColor = color);
    widget.onStyleChanged(HighlightStyle(type: _selectedType, color: _selectedColor));
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

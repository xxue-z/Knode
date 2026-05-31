import 'package:flutter/material.dart';
import 'package:wiki/gen/strings.dart';

/// A row of tag chips that displays document tags.
const _strings = L10nStringsMixin();

class TagChipList extends StatelessWidget {
  const TagChipList({
    super.key,
    required this.tags,
    this.onEdit,
    this.isEditable = false,
  });

  final List<String> tags;
  final VoidCallback? onEdit;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: isEditable ? onEdit : null,
      child: Wrap(
        spacing: 6.0,
        runSpacing: 4.0,
        children: [
          for (final tag in tags)
            Chip(
              label: Text(
                tag,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              backgroundColor: colorScheme.secondaryContainer,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            ),
          if (isEditable)
            Chip(
              avatar: Icon(
                Icons.edit,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              label: Text(
                _strings.wiki_edit_tags,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              backgroundColor: colorScheme.surfaceContainerHighest,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            ),
        ],
      ),
    );
  }
}

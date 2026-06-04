/// Utility functions for truncating and formatting node labels in the
/// knowledge graph canvas.
library;

/// Truncates [text] to at most [maxLength] characters, appending an ellipsis
/// character if truncation occurred.
///
/// Examples:
/// ```dart
/// truncateLabel('Flutter');           // → 'Flutter'
/// truncateLabel('Flutter教程详解');    // → 'Flutter教…'
/// truncateLabel('Hello', maxLength: 3); // → 'Hel'
/// ```
String truncateLabel(String text, {int maxLength = 8}) {
  if (text.length <= maxLength) return text;
  if (maxLength <= 1) return text.substring(0, maxLength);
  return '${text.substring(0, maxLength - 1)}…';
}

/// Truncates a list of [tags] to at most [maxTags] entries, truncating each
/// individual tag to [maxTagLength] characters.
///
/// Returns a comma-separated string suitable for inline display.
String formatTags(List<String> tags, {int maxTags = 2, int maxTagLength = 8}) {
  return tags
      .take(maxTags)
      .map((t) => truncateLabel(t, maxLength: maxTagLength))
      .join(', ');
}

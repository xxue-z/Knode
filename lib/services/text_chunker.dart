class TextChunk {
  final int index;
  final String text;
  final String? heading;
  const TextChunk({required this.index, required this.text, this.heading});
}

class TextChunker {
  static const int maxChunkSize = 500;
  static const int minParagraphSize = 50;

  List<TextChunk> chunk(String text) {
    final byHeading = chunkByHeading(text);
    if (byHeading.length > 1) return byHeading;
    return chunkByParagraph(text);
  }

  List<TextChunk> chunkByHeading(String markdown) {
    final lines = markdown.split('\n');
    final chunks = <TextChunk>[];
    String? currentHeading;
    final buffer = StringBuffer();
    int index = 0;

    for (final line in lines) {
      if (line.startsWith(RegExp(r'^#{1,3}\s'))) {
        if (buffer.isNotEmpty) {
          final text = buffer.toString().trim();
          if (text.isNotEmpty) {
            chunks.addAll(_splitIfNeeded(index, text, currentHeading));
            index += chunks.length;
          }
          buffer.clear();
        }
        currentHeading = line.replaceFirst(RegExp(r'^#{1,3}\s'), '').trim();
      } else {
        buffer.writeln(line);
      }
    }
    if (buffer.isNotEmpty) {
      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        chunks.addAll(_splitIfNeeded(index, text, currentHeading));
      }
    }
    return chunks;
  }

  List<TextChunk> chunkByParagraph(String text) {
    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    final chunks = <TextChunk>[];
    final buffer = StringBuffer();
    int index = 0;

    for (final para in paragraphs) {
      final trimmed = para.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.length < minParagraphSize && buffer.isNotEmpty) {
        buffer.write('\n\n$trimmed');
      } else {
        if (buffer.isNotEmpty) {
          final t = buffer.toString().trim();
          if (t.isNotEmpty) chunks.add(TextChunk(index: index++, text: t));
          buffer.clear();
        }
        buffer.write(trimmed);
      }
    }
    if (buffer.isNotEmpty) {
      final t = buffer.toString().trim();
      if (t.isNotEmpty) chunks.add(TextChunk(index: index, text: t));
    }
    return chunks;
  }

  List<TextChunk> _splitIfNeeded(int startIndex, String text, String? heading) {
    if (text.length <= maxChunkSize) return [TextChunk(index: startIndex, text: text, heading: heading)];
    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    final result = <TextChunk>[];
    int idx = startIndex;
    final buf = StringBuffer();
    for (final para in paragraphs) {
      if (buf.length + para.length > maxChunkSize && buf.isNotEmpty) {
        result.add(TextChunk(index: idx++, text: buf.toString().trim(), heading: heading));
        buf.clear();
      }
      buf.write('$para\n\n');
    }
    if (buf.isNotEmpty) result.add(TextChunk(index: idx, text: buf.toString().trim(), heading: heading));
    return result;
  }
}
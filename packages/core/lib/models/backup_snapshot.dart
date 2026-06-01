class BackupSnapshot {
  final String fileName;
  final int sizeBytes;
  final DateTime createdAt;

  const BackupSnapshot({
    required this.fileName,
    required this.sizeBytes,
    required this.createdAt,
  });

  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static DateTime? parseTimestamp(String fileName) {
    final match = RegExp(r'knode_backup_(\d{8})_(\d{6})\.zip').firstMatch(fileName);
    if (match == null) return null;
    final dateStr = match.group(1)!;
    final timeStr = match.group(2)!;
    return DateTime.tryParse(
      '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}'
      'T${timeStr.substring(0, 2)}:${timeStr.substring(2, 4)}:${timeStr.substring(4, 6)}',
    );
  }
}

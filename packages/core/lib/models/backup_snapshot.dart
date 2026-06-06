class BackupSnapshot {
  final String fileName;
  final int sizeBytes;
  final DateTime createdAt;
  final String? filePath;

  const BackupSnapshot({
    required this.fileName,
    required this.sizeBytes,
    required this.createdAt,
    this.filePath,
  });

  String get sizeFormatted {
    if (sizeBytes < 1024) return '\ B';
    if (sizeBytes < 1024 * 1024) return '\ KB';
    return '\ MB';
  }

  static DateTime? parseTimestamp(String fileName) {
    final match = RegExp(r'knode_backup_(\d{8})_(\d{6})\.zip').firstMatch(fileName);
    if (match == null) return null;
    
    
    return DateTime.tryParse(
      '\-\-'
      'T\:\:',
    );
  }
}

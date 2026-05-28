class Document {
  final int id;
  final String title;
  final String fileName;
  final String? filePath;
  final int? categoryId;
  final String? originalFormat;
  final String? originalFilePath;
  final String? contentText;
  final String? summary;
  final int wordCount;
  final int readingTime;
  final int readCount;
  final String? lastReadAt;
  final int isDeleted;
  final String createdAt;
  final String updatedAt;

  const Document({
    required this.id,
    required this.title,
    required this.fileName,
    this.filePath,
    this.categoryId,
    this.originalFormat,
    this.originalFilePath,
    this.contentText,
    this.summary,
    required this.wordCount,
    required this.readingTime,
    required this.readCount,
    this.lastReadAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as int,
      title: map['title'] as String,
      fileName: map['fileName'] as String,
      filePath: map['filePath'] as String?,
      categoryId: map['categoryId'] as int?,
      originalFormat: map['originalFormat'] as String?,
      originalFilePath: map['originalFilePath'] as String?,
      contentText: map['contentText'] as String?,
      summary: map['summary'] as String?,
      wordCount: map['wordCount'] as int,
      readingTime: map['readingTime'] as int,
      readCount: map['readCount'] as int,
      lastReadAt: map['lastReadAt'] as String?,
      isDeleted: map['isDeleted'] as int,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fileName': fileName,
      'filePath': filePath,
      'categoryId': categoryId,
      'originalFormat': originalFormat,
      'originalFilePath': originalFilePath,
      'contentText': contentText,
      'summary': summary,
      'wordCount': wordCount,
      'readingTime': readingTime,
      'readCount': readCount,
      'lastReadAt': lastReadAt,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Document copyWith({
    int? id,
    String? title,
    String? fileName,
    String? filePath,
    int? categoryId,
    String? originalFormat,
    String? originalFilePath,
    String? contentText,
    String? summary,
    int? wordCount,
    int? readingTime,
    int? readCount,
    String? lastReadAt,
    int? isDeleted,
    String? createdAt,
    String? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      categoryId: categoryId ?? this.categoryId,
      originalFormat: originalFormat ?? this.originalFormat,
      originalFilePath: originalFilePath ?? this.originalFilePath,
      contentText: contentText ?? this.contentText,
      summary: summary ?? this.summary,
      wordCount: wordCount ?? this.wordCount,
      readingTime: readingTime ?? this.readingTime,
      readCount: readCount ?? this.readCount,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

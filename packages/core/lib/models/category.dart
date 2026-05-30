class Category {
  final int id;
  final String name;
  final int parentId;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.parentId,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      parentId: map['parentId'] as int,
      sortOrder: map['sortOrder'] as int,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    int? parentId,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

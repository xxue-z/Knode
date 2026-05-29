import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/tables/category_table.dart';
import '../models/category.dart';

/// 数据库列名（snake_case）与模型字段（camelCase）的映射工具。
class _CategoryMapper {
  /// 将数据库行（snake_case）转换为 [Category] 模型。
  static Category fromRow(Map<String, dynamic> row) {
    return Category(
      id: row['id'] as int,
      name: row['name'] as String,
      parentId: row['parent_id'] as int,
      sortOrder: row['sort_order'] as int,
      createdAt: row['created_at'] as String,
      updatedAt: row['updated_at'] as String,
    );
  }

  /// 将 [Category] 模型转换为数据库行（snake_case），排除 id（由自增主键生成）。
  static Map<String, dynamic> toRow(Category category) {
    return {
      'name': category.name,
      'parent_id': category.parentId,
      'sort_order': category.sortOrder,
      'created_at': category.createdAt,
      'updated_at': category.updatedAt,
    };
  }

  /// 将 [Category] 模型转换为数据库行（snake_case），包含 id。
  static Map<String, dynamic> toRowWithId(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'parent_id': category.parentId,
      'sort_order': category.sortOrder,
      'created_at': category.createdAt,
      'updated_at': category.updatedAt,
    };
  }
}

/// 类目数据访问对象，实现 CRUD 及树形查询。
///
/// 使用 [AppDatabase] 单例访问 SQLite，所有写操作通过事务保证数据一致性。
class CategoryDao {
  Database get _db => AppDatabase.instance.db;

  /// 获取所有类目，按 [sort_order] 升序排列。
  Future<List<Category>> getAll() async {
    try {
      final rows = await _db.query(
        CategoryTable.tableName,
        orderBy: 'sort_order ASC',
      );
      return rows.map(_CategoryMapper.fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to query all categories: $e');
    }
  }

  /// 获取指定 [parentId] 的子类目，按 [sort_order] 升序排列。
  ///
  /// [parentId] = 0 表示根节点类目。
  Future<List<Category>> getChildren(int parentId) async {
    try {
      final rows = await _db.query(
        CategoryTable.tableName,
        where: 'parent_id = ?',
        whereArgs: [parentId],
        orderBy: 'sort_order ASC',
      );
      return rows.map(_CategoryMapper.fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to query children for parentId=$parentId: $e');
    }
  }

  /// 根据 [id] 获取单个类目，不存在时返回 null。
  Future<Category?> getById(int id) async {
    try {
      final rows = await _db.query(
        CategoryTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _CategoryMapper.fromRow(rows.first);
    } on DatabaseException catch (e) {
      throw StateError('Failed to query category id=$id: $e');
    }
  }

  /// 插入新类目，返回新生成的行 id。
  Future<int> insert(Category category) async {
    try {
      return await _db.insert(
        CategoryTable.tableName,
        _CategoryMapper.toRow(category),
      );
    } on DatabaseException catch (e) {
      throw StateError('Failed to insert category "${category.name}": $e');
    }
  }

  /// 更新类目信息（按 id 匹配）。
  Future<void> update(Category category) async {
    try {
      final count = await _db.update(
        CategoryTable.tableName,
        _CategoryMapper.toRow(category),
        where: 'id = ?',
        whereArgs: [category.id],
      );
      if (count == 0) {
        throw StateError(
          'Category id=${category.id} not found, nothing updated.',
        );
      }
    } on DatabaseException catch (e) {
      throw StateError('Failed to update category id=${category.id}: $e');
    }
  }

  /// 删除指定 [id] 的类目。
  ///
  /// 注意：不会自动处理子类目，调用前应先移动或删除子类目（parent_id=0 的根类目）。
  Future<void> delete(int id) async {
    try {
      final count = await _db.delete(
        CategoryTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw StateError('Category id=$id not found, nothing deleted.');
      }
    } on DatabaseException catch (e) {
      throw StateError('Failed to delete category id=$id: $e');
    }
  }

  /// 将类目 [id] 移动到新的父节点 [newParentId]。
  ///
  /// 在事务中更新 [parent_id] 和 [updated_at]，保证数据一致性。
  /// [newParentId] = 0 表示移动到根节点。
  Future<void> move(int id, int newParentId) async {
    try {
      await _db.transaction((txn) async {
        final now = DateTime.now().toIso8601String();
        final count = await txn.update(
          CategoryTable.tableName,
          {
            'parent_id': newParentId,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        if (count == 0) {
          throw StateError(
            'Category id=$id not found, cannot move.',
          );
        }
      });
    } on DatabaseException catch (e) {
      throw StateError(
        'Failed to move category id=$id to newParentId=$newParentId: $e',
      );
    }
  }
}

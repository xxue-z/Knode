import '../dao/category_dao.dart';
import '../dao/document_dao.dart';
import '../models/category.dart';

/// 类目业务异常。
class BusinessException implements Exception {
  final String message;
  const BusinessException(this.message);

  @override
  String toString() => 'BusinessException: $message';
}

/// 类目业务仓库，封装 [CategoryDao]，处理类目的业务逻辑。
class CategoryRepository {
  final CategoryDao _categoryDao;
  final DocumentDao _documentDao;

  CategoryRepository({
    required CategoryDao categoryDao,
    required DocumentDao documentDao,
  })  : _categoryDao = categoryDao,
        _documentDao = documentDao;

  /// 获取所有类目。
  Future<List<Category>> getAll() => _categoryDao.getAll();

  /// 获取指定父节点的子类目。
  Future<List<Category>> getChildren(int parentId) =>
      _categoryDao.getChildren(parentId);

  /// 根据 id 获取类目。
  Future<Category?> getById(int id) => _categoryDao.getById(id);

  /// 新增类目。
  Future<int> add(String name, int parentId, {int sortOrder = 0}) {
    final category = Category(
      id: 0,
      name: name,
      parentId: parentId,
      sortOrder: sortOrder,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    return _categoryDao.insert(category);
  }

  /// 更新类目名称。
  Future<void> rename(int id, String newName) async {
    final category = await _categoryDao.getById(id);
    if (category == null) {
      throw BusinessException('类目不存在: id=$id');
    }
    await _categoryDao.update(category.copyWith(name: newName));
  }

  /// 删除类目。
  ///
  /// 删除时会将子类目的 [parentId] 重置为 0（移到根节点），
  /// 并将关联文档的 [categoryId] 置空。
  Future<void> delete(int id) async {
    final category = await _categoryDao.getById(id);
    if (category == null) {
      throw BusinessException('类目不存在: id=$id');
    }

    // 1) 子类目 parentId 重置为 0。
    final children = await _categoryDao.getChildren(id);
    for (final child in children) {
      await _categoryDao.update(child.copyWith(parentId: 0));
    }

    // 2) 关联文档 categoryId 置空（通过 DocumentDao 查询后逐个更新）。
    final docs = await _documentDao.getByCategory(id, includeDeleted: true);
    for (final doc in docs) {
      await _documentDao.update(doc.copyWith(categoryId: null));
    }

    // 3) 删除类目本身。
    await _categoryDao.delete(id);
  }

  /// 移动类目到新的父节点。
  ///
  /// 不能将类目移动到自身的子类目下（防止循环引用）。
  Future<void> move(int id, int newParentId) async {
    if (id == newParentId) {
      throw BusinessException('不能将类目移动到自身');
    }

    // 检查 newParentId 是否为自身的子类目。
    if (newParentId != 0) {
      final isDescendant = await _isDescendant(id, newParentId);
      if (isDescendant) {
        throw BusinessException('不能将类目移动到自身的子类目下');
      }
    }

    await _categoryDao.move(id, newParentId);
  }

  /// 递归检查 [ancestorId] 是否是 [descendantId] 的祖先。
  Future<bool> _isDescendant(int ancestorId, int descendantId) async {
    int currentId = descendantId;
    while (currentId != 0) {
      if (currentId == ancestorId) return true;
      final category = await _categoryDao.getById(currentId);
      if (category == null) break;
      currentId = category.parentId;
    }
    return false;
  }
}

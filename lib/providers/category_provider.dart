import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category.dart';
import '../data/repositories/category_repository.dart';

/// 类目仓库 Provider（由外部注入依赖）。
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  throw UnimplementedError(
    '请在 main.dart 中覆盖 categoryRepositoryProvider',
  );
});

/// 类目列表树形结构节点。
class CategoryTreeNode {
  final Category category;
  final List<CategoryTreeNode> children;

  const CategoryTreeNode({
    required this.category,
    this.children = const [],
  });
}

/// 类目列表状态。
class CategoryListState {
  final List<Category> allCategories;
  final AsyncValue<void> operationState;

  const CategoryListState({
    this.allCategories = const [],
    this.operationState = const AsyncData(null),
  });

  CategoryListState copyWith({
    List<Category>? allCategories,
    AsyncValue<void>? operationState,
  }) {
    return CategoryListState(
      allCategories: allCategories ?? this.allCategories,
      operationState: operationState ?? this.operationState,
    );
  }

  /// 构建树形结构（根节点 parentId = 0）。
  List<CategoryTreeNode> get tree => _buildTree(0);

  List<CategoryTreeNode> _buildTree(int parentId) {
    final children = allCategories
        .where((c) => c.parentId == parentId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return children.map((cat) {
      final subTree = _buildTree(cat.id);
      return CategoryTreeNode(category: cat, children: subTree);
    }).toList();
  }
}

/// 类目列表 AsyncNotifier。
class CategoryListNotifier extends AsyncNotifier<CategoryListState> {
  @override
  Future<CategoryListState> build() async {
    final repo = ref.read(categoryRepositoryProvider);
    final categories = await repo.getAll();
    return CategoryListState(allCategories: categories);
  }

  /// 新增类目。
  Future<void> add(String name, int parentId, {int sortOrder = 0}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.add(name, parentId, sortOrder: sortOrder);
      final categories = await repo.getAll();
      return CategoryListState(allCategories: categories);
    });
  }

  /// 重命名类目。
  Future<void> rename(int id, String newName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.rename(id, newName);
      final categories = await repo.getAll();
      return CategoryListState(allCategories: categories);
    });
  }

  /// 删除类目。
  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.delete(id);
      final categories = await repo.getAll();
      return CategoryListState(allCategories: categories);
    });
  }

  /// 移动类目。
  Future<void> move(int id, int newParentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.move(id, newParentId);
      final categories = await repo.getAll();
      return CategoryListState(allCategories: categories);
    });
  }
}

/// 类目列表 Provider。
final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, CategoryListState>(
  CategoryListNotifier.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core/models/document.dart';
import 'package:core/database/repositories/document_repository.dart';

/// 文档仓库 Provider（由外部注入依赖）。
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  throw UnimplementedError(
    '请在 main.dart 中覆盖 documentRepositoryProvider',
  );
});

/// 文档列表状态。
class DocumentListState {
  final List<Document> documents;
  final int? filterCategoryId;
  final String? searchQuery;

  const DocumentListState({
    this.documents = const [],
    this.filterCategoryId,
    this.searchQuery,
  });

  DocumentListState copyWith({
    List<Document>? documents,
    int? filterCategoryId,
    String? searchQuery,
  }) {
    return DocumentListState(
      documents: documents ?? this.documents,
      filterCategoryId: filterCategoryId ?? this.filterCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// 文档列表 AsyncNotifier。
class DocumentListNotifier extends AsyncNotifier<DocumentListState> {
  int? _categoryId;

  @override
  Future<DocumentListState> build() async {
    final repo = ref.read(documentRepositoryProvider);
    final docs = _categoryId != null
        ? await repo.getByCategory(_categoryId!)
        : await repo.getRecentlyRead();
    return DocumentListState(
      documents: docs,
      filterCategoryId: _categoryId,
    );
  }

  /// 按类目过滤文档。
  Future<void> filterByCategory(int? categoryId) async {
    _categoryId = categoryId;
    ref.invalidateSelf();
  }

  /// 搜索文档。
  Future<void> search(String query) async {
    if (query.isEmpty) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(documentRepositoryProvider);
      final docs = await repo.search(query);
      return DocumentListState(
        documents: docs,
        searchQuery: query,
      );
    });
  }

  /// 创建文档。
  Future<Document?> createDocument({
    required int categoryId,
    required String title,
    String? initialContent,
  }) async {
    Document? newDoc;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(documentRepositoryProvider);
      newDoc = await repo.createDocument(
        categoryId: categoryId,
        title: title,
        initialContent: initialContent,
      );
      final docs = _categoryId != null
          ? await repo.getByCategory(_categoryId!)
          : await repo.getRecentlyRead();
      return DocumentListState(
        documents: docs,
        filterCategoryId: _categoryId,
      );
    });
    return newDoc;
  }

  /// 保存文档内容。
  Future<void> saveContent(int docId, String content) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(documentRepositoryProvider);
      await repo.saveContent(docId, content);
      final docs = _categoryId != null
          ? await repo.getByCategory(_categoryId!)
          : await repo.getRecentlyRead();
      return DocumentListState(
        documents: docs,
        filterCategoryId: _categoryId,
      );
    });
  }

  /// 删除文档。
  Future<void> deleteDocument(int docId) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(documentRepositoryProvider);
      await repo.deleteDocument(docId);
      final docs = _categoryId != null
          ? await repo.getByCategory(_categoryId!)
          : await repo.getRecentlyRead();
      return DocumentListState(
        documents: docs,
        filterCategoryId: _categoryId,
      );
    });
  }
}

/// 文档列表 Provider。
final documentListProvider =
    AsyncNotifierProvider<DocumentListNotifier, DocumentListState>(
  DocumentListNotifier.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/bookmark.dart';
import 'package:core/models/highlight.dart';
import 'package:core/models/highlight_style.dart';
import 'package:core/database/dao/bookmark_dao.dart';
import 'package:core/database/dao/highlight_dao.dart';
import 'package:core/services/app_logger.dart';

/// 阅读器状态 Provider
final readerProvider = AsyncNotifierProvider.family<_ReaderNotifier, ReaderState, int>(_ReaderNotifier.new);

class ReaderState {
  final List<Bookmark> bookmarks;
  final List<Highlight> highlights;
  final bool isLoading;

  ReaderState({
    required this.bookmarks,
    required this.highlights,
    this.isLoading = false,
  });

  ReaderState copyWith({
    List<Bookmark>? bookmarks,
    List<Highlight>? highlights,
    bool? isLoading,
  }) {
    return ReaderState(
      bookmarks: bookmarks ?? this.bookmarks,
      highlights: highlights ?? this.highlights,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class _ReaderNotifier extends FamilyAsyncNotifier<ReaderState, int> {
  @override
  Future<ReaderState> build(int docId) async {
    return await _loadData(docId);
  }

  Future<ReaderState> _loadData(int docId) async {
    try {
      final bookmarkDao = BookmarkDao();
      final highlightDao = HighlightDao();

      final bookmarks = await bookmarkDao.getByDocId(docId);
      final highlights = await highlightDao.getByDocId(docId);

      return ReaderState(
        bookmarks: bookmarks,
        highlights: highlights,
      );
    } catch (e, st) {
      AppLogger.instance.e('加载阅读器数据失败', tag: 'ReaderProvider', error: e, stackTrace: st);
      return ReaderState(bookmarks: [], highlights: []);
    }
  }

  /// 添加书签
  Future<void> addBookmark(int docId, int start, int end, String text, String? label) async {
    try {
      final dao = BookmarkDao();
      await dao.insert(Bookmark(
        id: null,
        docId: docId,
        position: start,
        endPosition: end,
        selectedText: text,
        label: label,
        createdAt: DateTime.now(),
      ));
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('添加书签失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }

  /// 删除书签
  Future<void> removeBookmark(int bookmarkId, int docId) async {
    try {
      final dao = BookmarkDao();
      await dao.delete(bookmarkId);
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('删除书签失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }

  /// 添加高亮
  Future<void> addHighlight(int docId, int start, int end, String text, HighlightStyle style, String? note) async {
    try {
      final dao = HighlightDao();
      final now = DateTime.now();
      await dao.insert(Highlight(
        id: null,
        docId: docId,
        startPos: start,
        endPos: end,
        selectedText: text,
        style: style,
        noteText: note,
        createdAt: now,
        updatedAt: now,
      ));
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('添加高亮失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }

  /// 更新高亮
  Future<void> updateHighlight(Highlight highlight, int docId) async {
    try {
      final dao = HighlightDao();
      await dao.update(highlight.copyWith(updatedAt: DateTime.now()));
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('更新高亮失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }

  /// 删除高亮
  Future<void> removeHighlight(int highlightId, int docId) async {
    try {
      final dao = HighlightDao();
      await dao.delete(highlightId);
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('删除高亮失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }
}

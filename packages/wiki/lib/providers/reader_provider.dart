
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/bookmark.dart';
import 'package:core/models/highlight.dart';
import 'package:core/database/database.dart';
import 'package:core/services/app_logger.dart';

/// 阅读器状态 Provider
final readerProvider = AsyncNotifierProvider.family&lt;_ReaderNotifier, ReaderState, int&gt;(_ReaderNotifier.new);

class ReaderState {
  final List&lt;Bookmark&gt; bookmarks;
  final List&lt;Highlight&gt; highlights;
  final bool isLoading;

  ReaderState({
    required this.bookmarks,
    required this.highlights,
    this.isLoading = false,
  });

  ReaderState copyWith({
    List&lt;Bookmark&gt;? bookmarks,
    List&lt;Highlight&gt;? highlights,
    bool? isLoading,
  }) {
    return ReaderState(
      bookmarks: bookmarks ?? this.bookmarks,
      highlights: highlights ?? this.highlights,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class _ReaderNotifier extends FamilyAsyncNotifier&lt;ReaderState, int&gt; {
  @override
  Future&lt;ReaderState&gt; build(int docId) async {
    return await _loadData(docId);
  }

  Future&lt;ReaderState&gt; _loadData(int docId) async {
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
  Future&lt;void&gt; addBookmark(int docId, int start, int end, String text, String? label) async {
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
  Future&lt;void&gt; removeBookmark(int bookmarkId, int docId) async {
    try {
      final dao = BookmarkDao();
      await dao.delete(bookmarkId);
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('删除书签失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }

  /// 添加高亮
  Future&lt;void&gt; addHighlight(int docId, int start, int end, String text, HighlightStyle style, String? note) async {
    try {
      final dao = HighlightDao();
      await dao.insert(Highlight(
        id: null,
        docId: docId,
        startPosition: start,
        endPosition: end,
        selectedText: text,
        style: style,
        note: note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('添加高亮失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }

  /// 更新高亮
  Future&lt;void&gt; updateHighlight(Highlight highlight, int docId) async {
    try {
      final dao = HighlightDao();
      await dao.update(highlight.copyWith(updatedAt: DateTime.now()));
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('更新高亮失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }

  /// 删除高亮
  Future&lt;void&gt; removeHighlight(int highlightId, int docId) async {
    try {
      final dao = HighlightDao();
      await dao.delete(highlightId);
      state = AsyncData(await _loadData(docId));
    } catch (e, st) {
      AppLogger.instance.e('删除高亮失败', tag: 'ReaderProvider', error: e, stackTrace: st);
    }
  }
}

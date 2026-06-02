import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod 3.x 兼容扩展。
///
/// Riverpod 3.x 移除了 [AsyncValue.valueOrNull]，
/// 此扩展提供等效方法，避免在 47+ 个文件中逐一修改。
extension AsyncValueCompat<T> on AsyncValue<T> {
  /// 安全获取当前值，状态未加载完成时返回 null。
  ///
  /// 等效于 Riverpod 2.x 的 `AsyncValue.valueOrNull`。
  T? get valueOrNull {
    return switch (this) {
      AsyncData<T>(:final value) => value,
      _ => null,
    };
  }
}

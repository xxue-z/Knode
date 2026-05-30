import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/gen/strings.dart';
import 'package:core/models/local_model.dart';
import 'package:core/services/model_repo_service.dart';
import 'package:core/services/model_download_service.dart';
import 'package:core/ai/local_ai_provider.dart';
import 'settings_provider.dart';

const _strings = L10nStringsMixin();

/// ModelRepoService 实例。
final modelRepoServiceProvider = Provider<ModelRepoService>((ref) {
  return ModelRepoService();
});

/// ModelDownloadService 实例（需要在 main.dart 覆盖 modelsDir）。
final modelDownloadServiceProvider = Provider<ModelDownloadService>((ref) {
  throw UnimplementedError('请在 main.dart 中覆盖 ModelDownloadService');
});

/// LocalAIProvider 实例（需要在 main.dart 覆盖）。
final localAiProviderRef = Provider<LocalAIProvider>((ref) {
  return LocalAIProvider();
});

/// 本地模型列表状态管理。
class ModelListNotifier extends AsyncNotifier<List<LocalModel>> {
  StreamSubscription? _downloadSub;

  @override
  Future<List<LocalModel>> build() async {
    final repo = ref.read(modelRepoServiceProvider);
    return repo.getCachedModels();
  }

  /// 从远程仓库拉取模型列表。
  Future<void> fetchFromRepo(String url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(modelRepoServiceProvider);
      return repo.fetchModels(url);
    });
  }

  /// 开始下载指定模型。
  Future<void> startDownload(LocalModel model, String mirrorKey) async {
    _updateModel(model.id, (m) => m.copyWith(
      status: ModelStatus.downloading,
      downloadProgress: 0.0,
    ));

    final service = ref.read(modelDownloadServiceProvider);

    // 监听下载进度
    _downloadSub?.cancel();
    _downloadSub = service.downloadProgress.listen((progress) {
      _updateModel(model.id, (m) => m.copyWith(
        downloadProgress: progress.percent,
      ));
    });

    try {
      await service.downloadWithMirror(model, mirrorKey);
      _updateModel(model.id, (m) => m.copyWith(
        status: ModelStatus.downloaded,
        downloadProgress: 1.0,
      ));
    } catch (e) {
      _updateModel(model.id, (m) => m.copyWith(
        status: ModelStatus.loadFailed,
        errorMessage: '${_strings.core_download_failed}: $e',
      ));
    } finally {
      _downloadSub?.cancel();
      _downloadSub = null;
    }
  }

  /// 取消当前下载。
  void cancelDownload() {
    ref.read(modelDownloadServiceProvider).cancelDownload();
  }

  /// 加载模型到内存。
  Future<void> loadModel(LocalModel model) async {
    // 先卸载当前已加载的模型
    unloadCurrent();

    _updateModel(model.id, (m) => m.copyWith(
      status: ModelStatus.downloading, // 临时状态，UI 不区分
      errorMessage: null,
    ));

    try {
      final localAi = ref.read(localAiProviderRef);
      final path = '${ref.read(modelDownloadServiceProvider).modelsDir}/${model.id}.gguf';
      await localAi.loadModel(path);

      // 更新当前模型为 loaded，其他模型降为 downloaded
      final current = state.valueOrNull ?? [];
      final updated = current.map((m) {
        if (m.id == model.id) {
          return m.copyWith(status: ModelStatus.loaded);
        }
        if (m.status == ModelStatus.loaded) {
          return m.copyWith(status: ModelStatus.downloaded);
        }
        return m;
      }).toList();
      state = AsyncData(updated);

      // 持久化当前模型 ID
      await ref.read(settingsProvider.notifier).set('local_model_id', model.id);
    } catch (e) {
      _updateModel(model.id, (m) => m.copyWith(
        status: ModelStatus.loadFailed,
        errorMessage: '${_strings.core_loading_failed}: $e',
      ));
    }
  }

  /// 卸载当前已加载的模型。
  void unloadCurrent() {
    final localAi = ref.read(localAiProviderRef);
    if (localAi.isLoaded) {
      localAi.dispose();
    }
    final current = state.valueOrNull ?? [];
    final updated = current.map((m) {
      if (m.status == ModelStatus.loaded) {
        return m.copyWith(status: ModelStatus.downloaded);
      }
      return m;
    }).toList();
    if (updated != current) {
      state = AsyncData(updated);
    }
  }

  /// 删除模型文件。
  Future<void> deleteModel(LocalModel model) async {
    final service = ref.read(modelDownloadServiceProvider);
    await service.deleteModel(model.id);
    _updateModel(model.id, (m) => m.copyWith(
      status: ModelStatus.notDownloaded,
      downloadProgress: 0.0,
      errorMessage: null,
    ));
  }

  /// 导入本地 .gguf 文件。
  Future<void> importLocalModel(String filePath) async {
    final service = ref.read(modelDownloadServiceProvider);
    final name = await service.importLocalModel(filePath);

    // 添加到模型列表
    final current = state.valueOrNull ?? [];
    final exists = current.any((m) => m.id == name);
    if (!exists) {
      final imported = LocalModel(
        id: name,
        name: name,
        size: '',
        minRam: '',
        description: _strings.core_local_import,
        quantization: '',
        downloadUrls: {},
        status: ModelStatus.downloaded,
      );
      state = AsyncData([...current, imported]);
    }
  }

  /// 更新列表中指定模型。
  void _updateModel(String id, LocalModel Function(LocalModel) updater) {
    final current = state.valueOrNull ?? [];
    final updated = current.map((m) {
      if (m.id == id) return updater(m);
      return m;
    }).toList();
    state = AsyncData(updated);
  }
}

/// 本地模型列表 Provider。
final modelListProvider =
    AsyncNotifierProvider<ModelListNotifier, List<LocalModel>>(
  ModelListNotifier.new,
);

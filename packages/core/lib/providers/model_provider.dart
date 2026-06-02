import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/gen/strings.dart';
import 'package:core/models/local_model.dart';
import 'package:core/services/app_logger.dart';
import 'package:core/services/model_repo_service.dart';
import 'package:core/services/model_download_service.dart';
import 'package:core/ai/local_ai_provider.dart';
import 'settings_provider.dart';
import 'package:core/extensions/riverpod_compat.dart';

const _strings = L10nStringsMixin();

/// ModelRepoService 瀹炰緥銆?
final modelRepoServiceProvider = Provider<ModelRepoService>((ref) {
  return ModelRepoService();
});

/// ModelDownloadService 瀹炰緥锛堥渶瑕佸湪 main.dart 瑕嗙洊 modelsDir锛夈€?
final modelDownloadServiceProvider = Provider<ModelDownloadService>((ref) {
  throw UnimplementedError('璇峰湪 main.dart 涓鐩?ModelDownloadService');
});

/// LocalAIProvider 瀹炰緥锛堥渶瑕佸湪 main.dart 瑕嗙洊锛夈€?
final localAiProviderRef = Provider<LocalAIProvider>((ref) {
  return LocalAIProvider();
});

/// 鏈湴妯″瀷鍒楄〃鐘舵€佺鐞嗐€?
class ModelListNotifier extends AsyncNotifier<List<LocalModel>> {
  StreamSubscription? _downloadSub;

  @override
  Future<List<LocalModel>> build() async {
    final repo = ref.read(modelRepoServiceProvider);
    return repo.getCachedModels();
  }

  /// 浠庤繙绋嬩粨搴撴媺鍙栨ā鍨嬪垪琛ㄣ€?
  Future<void> fetchFromRepo(String url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(modelRepoServiceProvider);
      return repo.fetchModels(url);
    });
  }

  /// 寮€濮嬩笅杞芥寚瀹氭ā鍨嬨€?
  Future<void> startDownload(LocalModel model, String mirrorKey) async {
    _updateModel(model.id, (m) => m.copyWith(
      status: ModelStatus.downloading,
      downloadProgress: 0.0,
    ));

    final service = ref.read(modelDownloadServiceProvider);

    // 鐩戝惉涓嬭浇杩涘害
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

  /// 鍙栨秷褰撳墠涓嬭浇銆?
  void cancelDownload() {
    ref.read(modelDownloadServiceProvider).cancelDownload();
  }

  /// 鍔犺浇妯″瀷鍒板唴瀛樸€?
  Future<void> loadModel(LocalModel model) async {
    AppLogger.instance.i('鍔犺浇妯″瀷: ${model.name}', tag: 'ModelProvider');
    // 鍏堝嵏杞藉綋鍓嶅凡鍔犺浇鐨勬ā鍨?
    unloadCurrent();

    _updateModel(model.id, (m) => m.copyWith(
      status: ModelStatus.downloading, // 涓存椂鐘舵€侊紝UI 涓嶅尯鍒?
      errorMessage: null,
    ));

    try {
      final localAi = ref.read(localAiProviderRef);
      final path = '${ref.read(modelDownloadServiceProvider).modelsDir}/${model.id}.gguf';
      await localAi.loadModel(path);

      // 鏇存柊褰撳墠妯″瀷涓?loaded锛屽叾浠栨ā鍨嬮檷涓?downloaded
      final current = state.valueOrNull ?? <LocalModel>[];
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

      AppLogger.instance.i('妯″瀷鍔犺浇鎴愬姛: ${model.name}', tag: 'ModelProvider');
      // 鎸佷箙鍖栧綋鍓嶆ā鍨?ID
      await ref.read(settingsProvider.notifier).set('local_model_id', model.id);
    } catch (e) {
      AppLogger.instance.e('妯″瀷鍔犺浇澶辫触: ${model.name}', tag: 'ModelProvider', error: e);
      _updateModel(model.id, (m) => m.copyWith(
        status: ModelStatus.loadFailed,
        errorMessage: '${_strings.core_loading_failed}: $e',
      ));
    }
  }

  /// 鍗歌浇褰撳墠宸插姞杞界殑妯″瀷銆?
  void unloadCurrent() {
    AppLogger.instance.d('鍗歌浇褰撳墠妯″瀷', tag: 'ModelProvider');
    final localAi = ref.read(localAiProviderRef);
    if (localAi.isLoaded) {
      localAi.dispose();
    }
    final current = state.valueOrNull ?? <LocalModel>[];
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

  /// 鍒犻櫎妯″瀷鏂囦欢銆?
  Future<void> deleteModel(LocalModel model) async {
    AppLogger.instance.i('鍒犻櫎妯″瀷: ${model.id}', tag: 'ModelProvider');
    final service = ref.read(modelDownloadServiceProvider);
    await service.deleteModel(model.id);
    _updateModel(model.id, (m) => m.copyWith(
      status: ModelStatus.notDownloaded,
      downloadProgress: 0.0,
      errorMessage: null,
    ));
  }

  /// 瀵煎叆鏈湴 .gguf 鏂囦欢銆?
  Future<void> importLocalModel(String filePath) async {
    AppLogger.instance.i('瀵煎叆妯″瀷: $filePath', tag: 'ModelProvider');
    final service = ref.read(modelDownloadServiceProvider);
    final name = await service.importLocalModel(filePath);
    AppLogger.instance.i('妯″瀷瀵煎叆鎴愬姛: $name', tag: 'ModelProvider');

    // 娣诲姞鍒版ā鍨嬪垪琛?
    final current = state.valueOrNull ?? <LocalModel>[];
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

  /// 鏇存柊鍒楄〃涓寚瀹氭ā鍨嬨€?
  void _updateModel(String id, LocalModel Function(LocalModel) updater) {
    final current = state.valueOrNull ?? <LocalModel>[];
    final updated = current.map((m) {
      if (m.id == id) return updater(m);
      return m;
    }).toList();
    state = AsyncData(updated);
  }
}

/// 鏈湴妯″瀷鍒楄〃 Provider銆?
final modelListProvider =
    AsyncNotifierProvider<ModelListNotifier, List<LocalModel>>(
  ModelListNotifier.new,
);

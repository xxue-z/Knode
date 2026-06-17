import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiki/graph/models/graph_view_state.dart';
import 'package:wiki/graph/providers/graph_provider_v2.dart';
import 'package:wiki/graph/providers/data_source_provider.dart';
import 'package:wiki/graph/providers/camera_provider.dart';
import 'package:wiki/graph/datasource/mock_graph_data_source.dart';
import 'package:wiki/graph/controllers/camera_controller.dart';

void main() {
  group('GraphNotifierV2', () {
    test('build returns GraphViewState with data from MockGraphDataSource', () async {
      final container = ProviderContainer(
        overrides: [
          graphDataSourceProvider.overrideWith((ref) => MockGraphDataSource()),
          cameraControllerProvider.overrideWith((ref) => CameraController()),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(graphProviderV2.future);

      expect(state.nodes, isNotEmpty);
      expect(state.edges, isNotEmpty);
      expect(state.clusters, isNotEmpty);
      expect(state.lodLevel, LodLevel.detail);
    });

    test('refresh reloads data', () async {
      final container = ProviderContainer(
        overrides: [
          graphDataSourceProvider.overrideWith((ref) => MockGraphDataSource()),
          cameraControllerProvider.overrideWith((ref) => CameraController()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(graphProviderV2.future);
      final notifier = container.read(graphProviderV2.notifier);

      await notifier.refresh();

      final state = container.read(graphProviderV2).value;
      expect(state, isNotNull);
      expect(state!.nodes, isNotEmpty);
    });

    test('updateLod changes lodLevel', () async {
      final container = ProviderContainer(
        overrides: [
          graphDataSourceProvider.overrideWith((ref) => MockGraphDataSource()),
          cameraControllerProvider.overrideWith((ref) => CameraController()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(graphProviderV2.future);
      final notifier = container.read(graphProviderV2.notifier);

      notifier.updateLod(2.0);
      expect(container.read(graphProviderV2).value!.lodLevel, LodLevel.detail);

      notifier.updateLod(0.1);
      expect(container.read(graphProviderV2).value!.lodLevel, LodLevel.stars);

      notifier.updateLod(0.5);
      expect(container.read(graphProviderV2).value!.lodLevel, LodLevel.nodes);
    });
  });
}

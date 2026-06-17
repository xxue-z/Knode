import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/graph_view_state.dart';
import '../services/cluster_service.dart';
import '../services/layout_service.dart';
import '../services/lod_service.dart';
import 'data_source_provider.dart';
import 'camera_provider.dart';

/// V2 图谱状态 Notifier
class GraphNotifierV2 extends AsyncNotifier<GraphViewState> {
  @override
  Future<GraphViewState> build() async {
    return _loadGraph();
  }

  Future<GraphViewState> _loadGraph() async {
    final dataSource = ref.read(graphDataSourceProvider);
    final nodes = await dataSource.getNodes();
    final edges = await dataSource.getEdges();
    final clusters = await dataSource.getClusters();

    final computedClusters = clusters.isEmpty
        ? ClusterService.computeClusters(nodes: nodes, edges: edges)
        : clusters;
    LayoutService.computeLayout(
      nodes: nodes,
      clusters: computedClusters,
      edges: edges,
    );

    return GraphViewState(
      nodes: nodes,
      edges: edges,
      clusters: computedClusters,
      lodLevel: LODService.computeLodLevel(
        ref.read(cameraControllerProvider).scale,
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadGraph());
  }

  void updateLod(double scale) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      lodLevel: LODService.computeLodLevel(scale),
    ));
  }
}

final graphProviderV2 =
    AsyncNotifierProvider<GraphNotifierV2, GraphViewState>(
  GraphNotifierV2.new,
);

import 'graph_node.dart';
import 'graph_edge.dart';
import 'graph_cluster.dart';
import 'graph_camera.dart';

/// 图谱完整视图状态
class GraphViewState {
  const GraphViewState({
    this.nodes = const [],
    this.edges = const [],
    this.clusters = const [],
    this.camera = const CameraState(),
    this.selectedNodeId,
    this.lodLevel = LodLevel.stars,
    this.isLoading = false,
  });

  final List<V2GraphNode> nodes;
  final List<V2GraphEdge> edges;
  final List<V2GraphCluster> clusters;
  final CameraState camera;
  final String? selectedNodeId;
  final LodLevel lodLevel;
  final bool isLoading;

  GraphViewState copyWith({
    List<V2GraphNode>? nodes,
    List<V2GraphEdge>? edges,
    List<V2GraphCluster>? clusters,
    CameraState? camera,
    String? selectedNodeId,
    LodLevel? lodLevel,
    bool? isLoading,
  }) {
    return GraphViewState(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      clusters: clusters ?? this.clusters,
      camera: camera ?? this.camera,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
      lodLevel: lodLevel ?? this.lodLevel,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// LOD 级别
enum LodLevel {
  /// 缩放 < 0.3：星空模式，仅显示星点
  stars,

  /// 缩放 0.3~1.0：节点模式，显示节点圆
  nodes,

  /// 缩放 > 1.0：聚焦模式，显示节点+标签
  detail,
}

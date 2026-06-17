import '../models/graph_node.dart';
import '../models/graph_edge.dart';
import '../models/graph_cluster.dart';

/// 知识图谱数据源抽象接口
///
/// 实现此接口可提供不同来源的图谱数据（真实数据 / Mock 测试数据）。
/// UI 层仅依赖此接口，不关心数据来源。
abstract class GraphDataSource {
  /// 获取全部图谱节点
  Future<List<V2GraphNode>> getNodes();

  /// 获取全部图谱边
  Future<List<V2GraphEdge>> getEdges();

  /// 获取聚类信息
  Future<List<V2GraphCluster>> getClusters();

  /// 根据 ID 获取单个节点
  Future<V2GraphNode?> getNodeById(String id);

  /// 搜索节点
  Future<List<V2GraphNode>> searchNodes(String query);
}

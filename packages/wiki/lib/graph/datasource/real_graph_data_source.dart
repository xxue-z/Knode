import 'package:wiki/providers/document_provider.dart';
import '../models/graph_node.dart';
import '../models/graph_edge.dart';
import '../models/graph_cluster.dart';
import 'graph_data_source.dart';

/// 基于 DocumentRepository 的真实数据源
///
/// 连接到实际数据库，从 DocumentProvider 读取数据并转换为 V2 模型。
/// TODO: 在 RealGraphDataSource 中实现完整的 Document→V2GraphNode 转换
class RealGraphDataSource implements GraphDataSource {
  RealGraphDataSource(this._documentProvider);

  final DocumentListNotifier _documentProvider;

  @override
  Future<List<V2GraphNode>> getNodes() async {
    // TODO: 从 DocumentRepository 获取文档，转换为 V2GraphNode
    return [];
  }

  @override
  Future<List<V2GraphEdge>> getEdges() async {
    // TODO: 从文档关联数据构建 V2GraphEdge
    return [];
  }

  @override
  Future<List<V2GraphCluster>> getClusters() async {
    // TODO: 按类目分组构建 V2GraphCluster
    return [];
  }

  @override
  Future<V2GraphNode?> getNodeById(String id) async {
    return null;
  }

  @override
  Future<List<V2GraphNode>> searchNodes(String query) async {
    return [];
  }
}

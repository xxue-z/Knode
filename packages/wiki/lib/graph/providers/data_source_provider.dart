import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasource/graph_data_source.dart';
import '../datasource/mock_graph_data_source.dart';

/// 控制使用真实数据还是 Mock 数据
/// 开发时设为 true 方便测试，发布时改为 false
final bool useMockDataSource = true;

/// 数据源 Provider — 切换此处即可切换数据来源
final graphDataSourceProvider = Provider<GraphDataSource>((ref) {
  if (useMockDataSource) {
    return MockGraphDataSource();
  }
  throw UnimplementedError('Real data source not configured');
});

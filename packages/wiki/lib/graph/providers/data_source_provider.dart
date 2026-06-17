import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasource/graph_data_source.dart';
import '../datasource/mock_graph_data_source.dart';

/// 控制使用真实数据还是 Mock 数据
///
/// 开发时设为 true 方便 UI 测试，发布前需改为 false 以对接真实数据库。
/// 这是临时开发开关，后续应改为通过配置或环境变量控制。
// ignore: prefer_constructors_over_static_methods
final bool useMockDataSource = true;

/// 数据源 Provider — 切换此处即可切换数据来源
final graphDataSourceProvider = Provider<GraphDataSource>((ref) {
  if (useMockDataSource) {
    return MockGraphDataSource();
  }
  throw UnimplementedError('Real data source not configured');
});

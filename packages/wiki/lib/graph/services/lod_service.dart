import '../models/graph_view_state.dart';

/// LOD（Level of Detail）服务
class LODService {
  /// 根据缩放级别计算当前 LOD
  static LodLevel computeLodLevel(double scale) {
    if (scale < 0.3) return LodLevel.stars;
    if (scale < 1.0) return LodLevel.nodes;
    return LodLevel.detail;
  }

  /// 判断当前 LOD 是否需要显示边
  static bool shouldShowEdges(LodLevel level) {
    return level != LodLevel.stars;
  }

  /// 判断当前 LOD 是否需要显示标签
  static bool shouldShowLabels(LodLevel level) {
    return level == LodLevel.detail;
  }
}

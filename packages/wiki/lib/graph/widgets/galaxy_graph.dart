import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/camera_controller.dart';
import '../controllers/gesture_controller.dart';
import '../painters/galaxy_painter.dart';
import '../providers/graph_provider_v2.dart';
import '../providers/camera_provider.dart';
import '../providers/selection_provider.dart';

class GalaxyGraph extends ConsumerStatefulWidget {
  const GalaxyGraph({
    super.key,
    this.onNodeTap,
    this.onNodeDoubleTap,
  });

  final void Function(String nodeId)? onNodeTap;
  final void Function(String nodeId)? onNodeDoubleTap;

  @override
  ConsumerState<GalaxyGraph> createState() => _GalaxyGraphState();
}

class _GalaxyGraphState extends ConsumerState<GalaxyGraph>
    with SingleTickerProviderStateMixin {
  late GestureController _gestureCtrl;
  late final CameraController _camera;

  @override
  void initState() {
    super.initState();
    _camera = ref.read(cameraControllerProvider);
    _gestureCtrl = GestureController(_camera);
    _camera.addListener(_onCameraUpdate);
  }

  @override
  void dispose() {
    _camera.removeListener(_onCameraUpdate);
    super.dispose();
  }

  void _onCameraUpdate() {
    ref.read(graphProviderV2.notifier).updateLod(
      _camera.scale,
    );
  }

  void _onTapDown(TapDownDetails details) {
    final state = ref.read(graphProviderV2).value;
    if (state == null) return;

    final size = context.size ?? Size.zero;

    final hitNode = state.nodes.reversed.where((n) {
      final pos = _camera.project(n.position, n.depth, size);
      final dist = (pos - details.localPosition).distance;
      return dist < n.size * n.scale;
    }).toList();

    if (hitNode.isNotEmpty) {
      final node = hitNode.first;
      ref.read(selectedNodeIdProvider.notifier).state = node.id;
      widget.onNodeTap?.call(node.id);
    } else {
      ref.read(selectedNodeIdProvider.notifier).state = null;
    }
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final state = ref.read(graphProviderV2).value;
    if (state == null) return;

    final size = context.size ?? Size.zero;
    final hitNode = state.nodes.reversed.where((n) {
      final pos = _camera.project(n.position, n.depth, size);
      return (pos - details.localPosition).distance < n.size * n.scale;
    }).toList();

    if (hitNode.isNotEmpty) {
      widget.onNodeDoubleTap?.call(hitNode.first.id);
    }

    _camera.zoomTo(2.0);
  }

  @override
  Widget build(BuildContext context) {
    final graphAsync = ref.watch(graphProviderV2);
    final camera = ref.watch(cameraControllerProvider);

    return graphAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('图谱加载失败: $e')),
      data: (state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final viewport = Size(constraints.maxWidth, constraints.maxHeight);
            final painter = GalaxyPainter(
              viewState: state,
              camera: camera,
              viewport: viewport,
              brightness: Theme.of(context).brightness,
            );

            return GestureDetector(
              onTapDown: _onTapDown,
              onDoubleTapDown: _onDoubleTapDown,
              onScaleStart: _gestureCtrl.onScaleStart,
              onScaleUpdate: (details) {
                _gestureCtrl.onScaleUpdate(details, viewport);
              },
              onScaleEnd: _gestureCtrl.onScaleEnd,
              child: CustomPaint(
                painter: painter,
                size: viewport,
              ),
            );
          },
        );
      },
    );
  }
}

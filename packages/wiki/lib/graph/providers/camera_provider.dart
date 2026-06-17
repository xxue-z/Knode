import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/camera_controller.dart';

final cameraControllerProvider =
    ChangeNotifierProvider<CameraController>((ref) {
  return CameraController();
});

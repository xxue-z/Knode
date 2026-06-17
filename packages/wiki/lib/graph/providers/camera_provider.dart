import 'package:flutter_riverpod/legacy.dart';
import '../controllers/camera_controller.dart';

final cameraControllerProvider =
    ChangeNotifierProvider<CameraController>((ref) {
  return CameraController();
});

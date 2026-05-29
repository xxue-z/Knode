import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<int> getAvailableMemory() async {
    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        return android.physicalMemory ~/ (1024 * 1024);
      }
      if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        final memStr = ios.physicalMemory ?? '0';
        return int.tryParse(memStr) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  static Future<int> getAvailableStorage() async {
    try {
      final dir = Directory('/storage/emulated/0');
      if (await dir.exists()) {
        final stat = await dir.stat();
        return stat.size ~/ (1024 * 1024);
      }
    } catch (_) {}
    return 0;
  }

  static Future<bool> isModelSupported(int modelSizeMB) async {
    final memory = await getAvailableMemory();
    if (memory <= 0) return false;
    return modelSizeMB <= memory * 0.6;
  }
}
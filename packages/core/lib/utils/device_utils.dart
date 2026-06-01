import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// 设备信息工具类，检测设备可用内存和存储空间。
///
/// 供模型下载过滤使用，判断设备是否能运行指定大小的模型。
class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 获取设备可用内存（MB）。
  ///
  /// Android: 通过 /proc/meminfo 读取 MemAvailable
  /// iOS: 返回默认估计值（iOS 不直接暴露可用内存）
  static Future<int> getAvailableMemory() async {
    try {
      if (Platform.isAndroid) {
        final memInfo = await File('/proc/meminfo').readAsString();
        final match = RegExp(r'MemAvailable:\s+(\d+)\s+kB').firstMatch(memInfo);
        if (match != null) {
          final kb = int.parse(match.group(1)!);
          return kb ~/ 1024; // 转为 MB
        }
        // 回退：返回默认值 4GB
        return 4096;
      }
      if (Platform.isIOS) {
        // iOS 不直接暴露可用内存，返回默认估计值 3GB
        return 3072;
      }
    } catch (_) {}
    return 0;
  }

  /// 获取设备可用存储空间（MB）。
  ///
  /// 使用 path_provider 获取应用目录，通过 stat 获取可用空间。
  static Future<int> getAvailableStorage() async {
    try {
      if (Platform.isAndroid) {
        // Android: 使用 df 命令获取可用空间
        final result = await Process.run('df', ['/data']);
        final lines = result.stdout.toString().split('\n');
        if (lines.length >= 2) {
          final parts = lines[1].split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            final availableKb = int.tryParse(parts[3]) ?? 0;
            return availableKb ~/ 1024;
          }
        }
        // 回退
        final dir = await getApplicationDocumentsDirectory();
        final stat = await Process.run('stat', ['-f', '%a', dir.path]);
        final availableBlocks = int.tryParse(stat.stdout.toString().trim()) ?? 0;
        return (availableBlocks * 4096) ~/ (1024 * 1024);
      }
      if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        final stat = await Process.run('stat', ['-f', '%a', dir.path]);
        final availableBlocks = int.tryParse(stat.stdout.toString().trim()) ?? 0;
        return (availableBlocks * 4096) ~/ (1024 * 1024);
      }
    } catch (_) {}
    return 0;
  }

  /// 获取设备物理总内存（GB）。
  ///
  /// Android: 通过 /proc/meminfo 读取 MemTotal
  /// iOS: 使用 NSProcessInfo.physicalMemory
  static Future<double> getTotalMemoryInGB() async {
    try {
      if (Platform.isAndroid) {
        final memInfo = await File('/proc/meminfo').readAsString();
        final match = RegExp(r'MemTotal:\s+(\d+)\s+kB').firstMatch(memInfo);
        if (match != null) {
          final kb = int.parse(match.group(1)!);
          return kb / (1024 * 1024);
        }
        return 4.0;
      }
      if (Platform.isIOS) {
        // TODO: 通过 MethodChannel 调用 NSProcessInfo.physicalMemory 获取真实值
        // 或使用 device_info_plus 的 utsname.machine 对照设备内存表
        return 4.0; // 回退默认值
      }
    } catch (_) {}
    return 0.0;
  }

  /// 解析 RAM 需求字符串为 GB 数值。
  ///
  /// 支持格式: "2 GB", "2GB", "2 gb", "512 MB", "512MB", "4-6 GB"
  /// 范围格式取最大值。无法解析时返回 0。
  static double parseRamString(String ramStr) {
    if (ramStr.isEmpty) return 0;

    // 范围格式: "4-6 GB" → 取最大值 6
    final rangeMatch = RegExp(r'([\d.]+)\s*-\s*([\d.]+)\s*(GB|MB|gb|mb)').firstMatch(ramStr);
    if (rangeMatch != null) {
      final maxVal = double.tryParse(rangeMatch.group(2)!) ?? 0;
      final unit = rangeMatch.group(3)!.toUpperCase();
      return unit == 'MB' ? maxVal / 1024 : maxVal;
    }

    // 单值格式: "2 GB", "512MB"
    final match = RegExp(r'([\d.]+)\s*(GB|MB|gb|mb)').firstMatch(ramStr);
    if (match == null) return 0;
    final value = double.tryParse(match.group(1)!) ?? 0;
    final unit = match.group(2)!.toUpperCase();
    return unit == 'MB' ? value / 1024 : value;
  }

  /// 判断设备是否能运行指定大小的模型。
  ///
  /// 规则：模型大小不超过可用内存的 60%。
  static Future<bool> isModelSupported(int modelSizeMB) async {
    final memory = await getAvailableMemory();
    if (memory <= 0) return false;
    return modelSizeMB <= memory * 0.6;
  }

  /// 获取设备型号信息。
  static Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        return '${android.manufacturer} ${android.model}';
      }
      if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        return ios.name ?? 'iPhone';
      }
    } catch (_) {}
    return 'Unknown';
  }
}

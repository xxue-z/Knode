import 'package:file_picker/file_picker.dart';
export 'package:file_picker/file_picker.dart' show FileType;

/// 封装 file_picker 插件，隔离第三方依赖。
///
/// 所有文件选择/目录选择操作统一通过本类调用，
/// 未来替换底层插件时只需修改此处实现。
class FilePickerUtil {
  FilePickerUtil._();

  static FilePicker get _picker => FilePicker.platform;

  /// 选择单个文件，返回文件路径（取消返回 null）。
  static Future<String?> pickSingleFile({
    String? dialogTitle,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    final result = await _picker.pickFiles(
      dialogTitle: dialogTitle,
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first.path;
  }

  /// 选择多个文件，返回文件路径列表（取消返回空列表）。
  static Future<List<String>> pickMultipleFiles({
    String? dialogTitle,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    final result = await _picker.pickFiles(
      dialogTitle: dialogTitle,
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
  }

  /// 选择目录，返回目录路径（取消返回 null）。
  static Future<String?> pickDirectory({
    String? dialogTitle,
  }) {
    return _picker.getDirectoryPath(dialogTitle: dialogTitle);
  }
}

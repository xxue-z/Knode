import 'dart:io';

import 'package:armyknife_dartx/armyknife_dartx.dart';
import 'package:armyknife_yamlx/armyknife_yamlx.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monolith/src/monolith_file_merger.dart';

@internal
class DefaultMonolithFileMerger implements MonolithFileMerger {
  const DefaultMonolithFileMerger();

  @override
  Map<String, dynamic> merge(List<File> files) {
    // 全てのYAMLをマージ
    final yamlMaps = files.map((e) => YamlX.parse(e)).toList();
    var result = <String, dynamic>{};

    // installプロパティ
    final installProperties = <Map<String, dynamic>>[];

    // デフォルトは全てマージ
    for (final yamlMap in yamlMaps) {
      result = MapX.merge(result, yamlMap);
    }

    // インストールは特殊なマージ
    for (final yamlMap in yamlMaps) {
      final install = yamlMap['install'] as List<dynamic>? ?? [];
      for (final installItem in install) {
        if (installItem is! Map<String, dynamic>) {
          continue;
        }

        final path = installItem['path'] as String?;
        if (path == null) {
          continue;
        }

        final oldPathInstall = installProperties.firstWhereOrNull(
          (e) => e['path'] == path,
        );

        if (oldPathInstall == null) {
          // pathが一致するinstallが存在しない場合は追加
          installProperties.add(installItem);
        } else {
          // pathが一致するinstallが存在する場合はマージ
          installProperties.remove(oldPathInstall);
          installProperties.add(
            MapX.merge(
              oldPathInstall,
              installItem,
            ),
          );
        }
      }
    }

    // installプロパティを結果に追加
    result['install'] = installProperties;
    return result;
  }
}

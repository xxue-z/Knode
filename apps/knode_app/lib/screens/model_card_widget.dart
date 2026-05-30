import 'package:flutter/material.dart';
import 'package:core/models/local_model.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 模型状态联动卡片组件。
///
/// 根据 [LocalModel.status] 动态渲染背景色、操作按钮、进度动画。
class ModelCardWidget extends StatelessWidget {
  final LocalModel model;
  final void Function(String mirrorKey)? onDownload;
  final VoidCallback? onCancel;
  final VoidCallback? onLoad;
  final VoidCallback? onDelete;
  final VoidCallback? onRetry;

  const ModelCardWidget({
    super.key,
    required this.model,
    this.onDownload,
    this.onCancel,
    this.onLoad,
    this.onDelete,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor(isDark),
        ),
        child: Stack(
          children: [
            // 下载进度条背景动画
            if (model.status == ModelStatus.downloading)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: model.downloadProgress,
                  child: Container(
                    color: (isDark ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50))
                        .withValues(alpha: isDark ? 0.5 : 0.3),
                  ),
                ),
              ),
            // 卡片内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(context, isDark),
                  const SizedBox(height: 4),
                  _buildDescription(context, isDark),
                  const SizedBox(height: 8),
                  _buildTags(context, isDark),
                  const SizedBox(height: 12),
                  _buildActionRow(context, isDark),
                  if (model.status == ModelStatus.loadFailed &&
                      model.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      model.errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.red[200] : Colors.red[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 下载中百分比文字
            if (model.status == ModelStatus.downloading)
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${(model.downloadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            // 「使用中」徽章
            if (model.status == ModelStatus.loaded)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '使用中',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _backgroundColor(bool isDark) {
    switch (model.status) {
      case ModelStatus.notDownloaded:
        return isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
      case ModelStatus.downloading:
        return isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
      case ModelStatus.downloaded:
        return isDark ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9);
      case ModelStatus.loaded:
        return isDark ? const Color(0xFF1B5E20) : const Color(0xFFC8E6C9);
      case ModelStatus.loadFailed:
        return isDark ? const Color(0xFFB71C1C) : const Color(0xFFFFEBEE);
    }
  }

  Widget _buildTitleRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Text(
            model.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, bool isDark) {
    return Text(
      model.description,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags(BuildContext context, bool isDark) {
    final tags = <String>[];
    if (model.quantization.isNotEmpty) tags.add(model.quantization);
    if (model.size.isNotEmpty) tags.add(model.size);
    if (model.minRam.isNotEmpty) tags.add('需 ${model.minRam} RAM');

    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: (isDark ? Colors.grey[700] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildActionRow(BuildContext context, bool isDark) {
    switch (model.status) {
      case ModelStatus.notDownloaded:
        return _buildDownloadButtons();
      case ModelStatus.downloading:
        return Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onCancel,
            child: Text(_strings.knode_app_cancel),
          ),
        );
      case ModelStatus.downloaded:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
              onPressed: onLoad,
              child: const Text('加载'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onDelete,
              child: const Text('删除'),
            ),
          ],
        );
      case ModelStatus.loaded:
        return Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: null, // 置灰
            child: const Text('已加载'),
          ),
        );
      case ModelStatus.loadFailed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onDelete,
              child: const Text('删除'),
            ),
          ],
        );
    }
  }

  Widget _buildDownloadButtons() {
    final urls = model.downloadUrls;
    if (urls.isEmpty) {
      return const Align(
        alignment: Alignment.centerRight,
        child: Text('无下载源', style: TextStyle(color: Colors.grey)),
      );
    }

    if (urls.length == 1) {
      final key = urls.keys.first;
      return Align(
        alignment: Alignment.centerRight,
        child: FilledButton.tonal(
          onPressed: onDownload != null ? () => onDownload!(key) : null,
          child: const Text('下载'),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: urls.keys.map((key) {
        final label = key == 'global' ? '国际' : key == 'china_mirror' ? '国内' : key;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: FilledButton.tonal(
            onPressed: onDownload != null ? () => onDownload!(key) : null,
            child: Text(label),
          ),
        );
      }).toList(),
    );
  }
}
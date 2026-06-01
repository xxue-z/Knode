# G9-5 - 阅读器增强：字典服务实施计划

## 一、现状分析

### 1.1 已有代码

| 文件 | 现状 |
|------|------|
| `packages/wiki/lib/screens/reader_page.dart` | 无字典功能 |
| `packages/core/lib/services/` | 无字典相关服务 |

### 1.2 需要实现

1. `DictService` 抽象接口
2. `HaiciDictService` 海词在线词典实现
3. `DictSheet` 底部弹窗（Tab 布局，支持多词典源切换）
4. 字典设置（启用/禁用词典源、设置默认词典）

---

## 二、涉及的文件清单

| 序号 | 文件路径 | 操作 | 说明 |
|------|----------|------|------|
| 1 | `packages/core/lib/services/dict_service.dart` | 新增 | 字典抽象接口 + DictEntry 模型 |
| 2 | `packages/core/lib/services/haici_dict_service.dart` | 新增 | 海词在线词典实现 |
| 3 | `packages/wiki/lib/widgets/dict_sheet.dart` | 新增 | 字典查询底部弹窗（Tab 布局） |
| 4 | `packages/wiki/lib/screens/reader_page.dart` | 修改 | 集成字典功能 |
| 5 | `packages/wiki/res/strings.csv` | 修改 | 新增字典相关国际化字符串 |
| 6 | `packages/core/res/strings.csv` | 修改 | 新增字典服务相关国际化字符串 |

---

## 三、实施步骤

### 步骤 1：创建字典抽象接口

**新增文件**: `packages/core/lib/services/dict_service.dart`

```dart
import 'package:core/services/app_logger.dart';

/// 字典查询结果条目。
class DictEntry {
  final String word;
  final String pronunciation; // 音标
  final List<String> definitions; // 释义列表
  final String source; // 来源名称

  const DictEntry({
    required this.word,
    required this.pronunciation,
    required this.definitions,
    required this.source,
  });
}

/// 字典服务抽象接口。
///
/// 每个词典源实现此接口，提供统一的查询方法。
abstract class DictService {
  /// 词典名称（用于 Tab 显示）。
  String get name;

  /// 查询单词/短语。
  Future<List<DictEntry>> lookup(String word);
}

/// 字典注册中心。
///
/// 管理所有可用的词典服务实例。
class DictRegistry {
  DictRegistry._();
  static final DictRegistry instance = DictRegistry._();

  final List<DictService> _services = [];

  /// 注册词典服务。
  void register(DictService service) {
    _services.add(service);
    AppLogger.instance.i('词典服务已注册: ${service.name}', tag: 'DictRegistry');
  }

  /// 获取所有已注册的词典服务。
  List<DictService> get services => List.unmodifiable(_services);

  /// 按名称获取词典服务。
  DictService? getService(String name) {
    try {
      return _services.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }

  /// 获取默认词典服务（第一个）。
  DictService? get defaultService => _services.isNotEmpty ? _services.first : null;
}
```

### 步骤 2：创建海词在线词典实现

**新增文件**: `packages/core/lib/services/haici_dict_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:core/services/app_logger.dart';
import 'dict_service.dart';

/// 海词在线词典服务。
///
/// 调用海词 API 查询英文单词释义。
class HaiciDictService implements DictService {
  @override
  String get name => '海词';

  @override
  Future<List<DictEntry>> lookup(String word) async {
    if (word.trim().isEmpty) return [];

    try {
      AppLogger.instance.d('海词查询: "$word"', tag: 'HaiciDict');

      // 海词 API 请求
      final url = Uri.parse('https://api.dict.cn/hdic.php?type=audio&word=${Uri.encodeComponent(word)}');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        AppLogger.instance.w('海词 API 返回非 200: ${response.statusCode}', tag: 'HaiciDict');
        return [];
      }

      // 解析响应（海词返回 JSON）
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final entries = _parseResponse(word, data);

      AppLogger.instance.d('海词查询完成: "$word", ${entries.length} 条结果', tag: 'HaiciDict');
      return entries;
    } catch (e) {
      AppLogger.instance.e('海词查询失败: "$word"', tag: 'HaiciDict', error: e);
      return [];
    }
  }

  List<DictEntry> _parseResponse(String word, Map<String, dynamic> data) {
    final pronunciation = data['phonetic'] as String? ?? '';
    final definitions = <String>[];

    // 解析释义
    if (data['means'] != null) {
      final means = data['means'] as List;
      for (final mean in means) {
        if (mean is Map && mean['mean'] != null) {
          definitions.add(mean['mean'] as String);
        }
      }
    }

    if (definitions.isEmpty) return [];

    return [
      DictEntry(
        word: word,
        pronunciation: pronunciation,
        definitions: definitions,
        source: name,
      ),
    ];
  }
}
```

**注意**：海词 API 可能有变化，上述为示例实现。实际实现需根据海词最新 API 调整。如果海词 API 不可用，可替换为其他免费词典 API（如 Free Dictionary API: `https://api.dictionaryapi.dev/api/v2/entries/en/{word}`）。

### 步骤 3：创建字典查询底部弹窗

**新增文件**: `packages/wiki/lib/widgets/dict_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';
import 'package:core/services/dict_service.dart';

/// 字典查询底部弹窗。
///
/// Tab 布局：上方 Tab 切换词典来源，下方展示对应释义。
class DictSheet extends StatefulWidget {
  final String word;

  const DictSheet({super.key, required this.word});

  /// 显示字典弹窗。
  static void show(BuildContext context, String word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DictSheet(word: word),
    );
  }

  @override
  State<DictSheet> createState() => _DictSheetState();
}

class _DictSheetState extends State<DictSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<DictEntry>> _cache = {};
  bool _isLoading = false;
  String? _error;

  List<DictService> get _services => DictRegistry.instance.services;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _services.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _lookupCurrentTab();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _lookupCurrentTab();
    }
  }

  Future<void> _lookupCurrentTab() async {
    if (_services.isEmpty) return;

    final service = _services[_tabController.index];
    if (_cache.containsKey(service.name)) return; // 已缓存

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entries = await service.lookup(widget.word);
      if (mounted) {
        setState(() {
          _cache[service.name] = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _strings.dict_lookup_error; // 国际化
          _isLoading = false;
        });
      }
      AppLogger.instance.e('字典查询失败: ${service.name}', tag: 'DictSheet', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 查询词标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    widget.word,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Tab 栏
            if (_services.length > 1)
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _services.map((s) => Tab(text: s.name)).toList(),
              ),
            // 内容区
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(_error!, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : _buildContent(scrollController),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    final serviceName = _services.isNotEmpty ? _services[_tabController.index].name : '';
    final entries = _cache[serviceName] ?? [];

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(_strings.dict_no_results, style: TextStyle(color: Colors.grey[600])), // 国际化
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _DictEntryCard(entry: entry);
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

/// 单条字典释义卡片。
class _DictEntryCard extends StatelessWidget {
  final DictEntry entry;
  const _DictEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 音标
            if (entry.pronunciation.isNotEmpty)
              Text(
                '/${entry.pronunciation}/',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),
            // 释义列表
            ...entry.definitions.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key + 1}. ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(e.value),
                    ),
                  ],
                ),
              );
            }),
            // 来源
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_strings.dict_source}: ${entry.source}', // 国际化
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 步骤 4：改造 ReaderPage — 集成字典

**修改文件**: `packages/wiki/lib/screens/reader_page.dart`

替换 `_showDictSheet` 方法：

```dart
import 'package:core/services/dict_service.dart';
import 'package:core/services/haici_dict_service.dart';
import '../widgets/dict_sheet.dart';

/// 初始化字典服务（在 initState 中调用）。
void _initDictServices() {
  final registry = DictRegistry.instance;
  // 注册内置词典
  if (registry.services.isEmpty) {
    registry.register(HaiciDictService());
    // 可注册更多词典源
  }
}

/// 打开字典查询。
void _showDictSheet(String word) {
  AppLogger.instance.d('打开字典查询: "$word"', tag: 'Reader');
  DictSheet.show(context, word);
}
```

在 `initState` 中调用 `_initDictServices()`。

### 步骤 5：国际化字符串

**修改文件**: `packages/wiki/res/strings.csv`

新增以下行：

```csv
dict_lookup_error,Dictionary lookup failed,字典查询失败
dict_no_results,No definitions found,未找到释义
dict_source,Source,来源
```

**修改文件**: `packages/core/res/strings.csv`

新增以下行：

```csv
dict_service_registered,Dictionary service registered,词典服务已注册
dict_lookup_failed,Dictionary lookup failed,字典查询失败
```

---

## 四、验收步骤

> **每个步骤完成后、提交代码前，必须通过以下验证命令。未通过验证的代码禁止提交。**

### 验证命令

```bash
# 1. 静态分析（必须 0 error）
dart analyze packages/core packages/wiki

# 2. 运行所有测试（必须全部通过）
flutter test packages/core packages/wiki

# 3. 国际化代码生成（必须成功）
dart run monolith_runner:localization

# 4. 硬编码中文扫描（必须 0 匹配）
grep -r "Text('[一-鿿]" --include="*.dart" packages/core/lib/services/dict_service.dart packages/core/lib/services/haici_dict_service.dart packages/wiki/lib/widgets/dict_sheet.dart --exclude-dir=gen
```

### 验证标准

| 检查项 | 必须满足 | 不满足时处理 |
|--------|----------|-------------|
| `dart analyze` error 数 | 0 | 修复所有 error 后重新验证 |
| `flutter test` 失败数 | 0 | 修复失败测试后重新验证 |
| 代码生成 | 成功无报错 | 检查 CSV 格式后重新验证 |
| 硬编码中文 | 0 匹配 | 替换为 `_strings.xxx` 后重新验证 |

### 验证时机

- 步骤 1 完成后：验证 DictService 接口无编译错误
- 步骤 2 完成后：验证 HaiciDictService 无编译错误
- 步骤 3 完成后：验证 DictSheet 无编译错误
- 步骤 4 完成后：验证 ReaderPage 集成无编译错误
- 步骤 5 完成后：验证国际化代码生成成功
- **最终提交前**：执行完整验证流程

---

## 五、实施顺序与依赖关系

```
步骤 1 (DictService 接口) ─┐
步骤 2 (HaiciDictService)  ─┼─→ 步骤 3 (DictSheet) → 步骤 4 (ReaderPage 集成)
步骤 5 (国际化)             ─┘
```

步骤 1 是基础，步骤 2 依赖步骤 1，步骤 3 依赖步骤 1，步骤 4 依赖步骤 2/3，步骤 5 可并行。

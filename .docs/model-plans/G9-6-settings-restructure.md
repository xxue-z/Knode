# G9-6 - 阅读器增强：设置界面模块化实施计划

## 一、现状分析

### 1.1 已有代码

| 文件 | 现状 |
|------|------|
| `apps/knode_app/lib/screens/settings_page.dart` | 设置页面包含 AI 设置、存储设置、关于三个 Section，平铺展示 |
| `packages/core/lib/database/dao/settings_dao.dart` | settings 表已有，可直接新增键值 |

### 1.2 需要实现

1. 设置主页改为模块入口列表（Wiki 设置、AI 设置、答题设置、备份设置、通用设置、关于）
2. 每个模块有独立的设置子页面
3. Wiki 设置中包含：阅读设置、高亮样式管理、字典设置
4. 高亮样式管理：预设样式列表，可新增/编辑/删除

---

## 二、涉及的文件清单

| 序号 | 文件路径 | 操作 | 说明 |
|------|----------|------|------|
| 1 | `apps/knode_app/lib/screens/settings_page.dart` | 修改 | 改为模块入口列表 |
| 2 | `apps/knode_app/lib/screens/settings/wiki_settings_page.dart` | 新增 | Wiki 设置子页面 |
| 3 | `apps/knode_app/lib/screens/settings/ai_settings_page.dart` | 新增 | AI 设置子页面 |
| 4 | `apps/knode_app/lib/screens/settings/quiz_settings_page.dart` | 新增 | 答题设置子页面 |
| 5 | `apps/knode_app/lib/screens/settings/backup_settings_page.dart` | 新增 | 备份设置子页面 |
| 6 | `apps/knode_app/lib/screens/settings/general_settings_page.dart` | 新增 | 通用设置子页面 |
| 7 | `apps/knode_app/lib/screens/settings/highlight_style_manager.dart` | 新增 | 高亮样式管理页 |
| 8 | `apps/knode_app/res/strings.csv` | 修改 | 新增设置模块相关国际化字符串 |

---

## 三、实施步骤

### 步骤 1：改造设置主页

**修改文件**: `apps/knode_app/lib/screens/settings_page.dart`

将现有的平铺式设置改为模块入口列表：

```dart
import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';
import 'settings/wiki_settings_page.dart';
import 'settings/ai_settings_page.dart';
import 'settings/quiz_settings_page.dart';
import 'settings/backup_settings_page.dart';
import 'settings/general_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.knode_app_settings), // 国际化
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Wiki 设置
          _SettingsModuleTile(
            icon: Icons.menu_book,
            title: _strings.settings_wiki, // 国际化
            subtitle: _strings.settings_wiki_subtitle, // 国际化
            onTap: () {
              AppLogger.instance.d('进入 Wiki 设置', tag: 'Settings');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WikiSettingsPage()));
            },
          ),
          // AI 设置
          _SettingsModuleTile(
            icon: Icons.psychology,
            title: _strings.settings_ai, // 国际化
            subtitle: _strings.settings_ai_subtitle, // 国际化
            onTap: () {
              AppLogger.instance.d('进入 AI 设置', tag: 'Settings');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AISettingsPage()));
            },
          ),
          // 答题设置
          _SettingsModuleTile(
            icon: Icons.quiz,
            title: _strings.settings_quiz, // 国际化
            subtitle: _strings.settings_quiz_subtitle, // 国际化
            onTap: () {
              AppLogger.instance.d('进入答题设置', tag: 'Settings');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizSettingsPage()));
            },
          ),
          // 备份设置
          _SettingsModuleTile(
            icon: Icons.backup,
            title: _strings.settings_backup, // 国际化
            subtitle: _strings.settings_backup_subtitle, // 国际化
            onTap: () {
              AppLogger.instance.d('进入备份设置', tag: 'Settings');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupSettingsPage()));
            },
          ),
          // 通用设置
          _SettingsModuleTile(
            icon: Icons.settings,
            title: _strings.settings_general, // 国际化
            subtitle: _strings.settings_general_subtitle, // 国际化
            onTap: () {
              AppLogger.instance.d('进入通用设置', tag: 'Settings');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralSettingsPage()));
            },
          ),
          const Divider(),
          // 关于
          _SettingsModuleTile(
            icon: Icons.info_outline,
            title: _strings.settings_about, // 国际化
            onTap: () {
              // 显示关于对话框（复用已有逻辑）
            },
          ),
        ],
      ),
    );
  }
}

/// 设置模块入口组件。
class _SettingsModuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsModuleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
```

### 步骤 2：创建 Wiki 设置子页面

**新增文件**: `apps/knode_app/lib/screens/settings/wiki_settings_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';
import 'highlight_style_manager.dart';

class WikiSettingsPage extends StatefulWidget {
  const WikiSettingsPage({super.key});

  @override
  State<WikiSettingsPage> createState() => _WikiSettingsPageState();
}

class _WikiSettingsPageState extends State<WikiSettingsPage> {
  double _fontSize = 16.0;
  double _lineSpacing = 1.6;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final dao = SettingsDao();
      final fontSize = await dao.getDouble('reader_font_size') ?? 16.0;
      final lineSpacing = await dao.getDouble('reader_line_spacing') ?? 1.6;
      final isDarkMode = await dao.getBool('reader_dark_mode') ?? false;
      if (mounted) {
        setState(() {
          _fontSize = fontSize;
          _lineSpacing = lineSpacing;
          _isDarkMode = isDarkMode;
        });
      }
    } catch (e) {
      AppLogger.instance.w('加载 Wiki 设置失败', tag: 'WikiSettings', error: e);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final dao = SettingsDao();
      await dao.setDouble('reader_font_size', _fontSize);
      await dao.setDouble('reader_line_spacing', _lineSpacing);
      await dao.setBool('reader_dark_mode', _isDarkMode);
      AppLogger.instance.d('Wiki 设置已保存', tag: 'WikiSettings');
    } catch (e) {
      AppLogger.instance.e('保存 Wiki 设置失败', tag: 'WikiSettings', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.settings_wiki), // 国际化
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // --- 阅读设置 Section ---
          _SectionHeader(title: _strings.settings_reading), // 国际化
          // 字体大小
          ListTile(
            title: Text(_strings.settings_font_size), // 国际化
            subtitle: Slider(
              value: _fontSize,
              min: 12,
              max: 28,
              divisions: 16,
              label: _fontSize.toStringAsFixed(1),
              onChanged: (v) {
                setState(() => _fontSize = v);
                _saveSettings();
              },
            ),
          ),
          // 行距
          ListTile(
            title: Text(_strings.settings_line_spacing), // 国际化
            subtitle: Slider(
              value: _lineSpacing,
              min: 1.0,
              max: 3.0,
              divisions: 20,
              label: _lineSpacing.toStringAsFixed(1),
              onChanged: (v) {
                setState(() => _lineSpacing = v);
                _saveSettings();
              },
            ),
          ),
          // 深色模式
          SwitchListTile(
            title: Text(_strings.settings_dark_mode), // 国际化
            value: _isDarkMode,
            onChanged: (v) {
              setState(() => _isDarkMode = v);
              _saveSettings();
            },
          ),

          // --- 高亮样式 Section ---
          _SectionHeader(title: _strings.settings_highlight_styles), // 国际化
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(_strings.settings_manage_styles), // 国际化
            subtitle: Text(_strings.settings_manage_styles_subtitle), // 国际化
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HighlightStyleManager()));
            },
          ),

          // --- 字典设置 Section ---
          _SectionHeader(title: _strings.settings_dictionary), // 国际化
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(_strings.settings_default_dict), // 国际化
            subtitle: const Text('海词'), // TODO: 从设置中读取
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 字典源选择（G9-5 中实现）
            },
          ),
        ],
      ),
    );
  }
}

/// Section 标题组件。
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
```

### 步骤 3：创建高亮样式管理页

**新增文件**: `apps/knode_app/lib/screens/settings/highlight_style_manager.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/models/highlight_style.dart';
import 'package:core/services/app_logger.dart';

/// 高亮样式管理页面。
///
/// 预配置多套高亮样式，可新增/编辑/删除。
class HighlightStyleManager extends StatefulWidget {
  const HighlightStyleManager({super.key});

  @override
  State<HighlightStyleManager> createState() => _HighlightStyleManagerState();
}

class _HighlightStyleManagerState extends State<HighlightStyleManager> {
  List<HighlightStyle> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    try {
      final dao = SettingsDao();
      final json = await dao.getString('highlight_presets');
      if (json != null) {
        final list = jsonDecode(json) as List;
        _presets = list.map((e) => HighlightStyle.fromJson(e as String)).toList();
      } else {
        _presets = List.from(HighlightStyle.presets);
      }
    } catch (e) {
      AppLogger.instance.w('加载高亮预设失败，使用默认值', tag: 'HighlightStyleManager', error: e);
      _presets = List.from(HighlightStyle.presets);
    }
    if (mounted) setState(() {});
  }

  Future<void> _savePresets() async {
    try {
      final dao = SettingsDao();
      final json = jsonEncode(_presets.map((e) => e.toJson()).toList());
      await dao.setString('highlight_presets', json);
      AppLogger.instance.d('高亮预设已保存: ${_presets.length} 套', tag: 'HighlightStyleManager');
    } catch (e) {
      AppLogger.instance.e('保存高亮预设失败', tag: 'HighlightStyleManager', error: e);
    }
  }

  void _addPreset() {
    // 弹出样式编辑器
    _showStyleEditor(null);
  }

  void _editPreset(int index) {
    _showStyleEditor(_presets[index], index: index);
  }

  void _deletePreset(int index) {
    setState(() => _presets.removeAt(index));
    _savePresets();
  }

  void _showStyleEditor(HighlightStyle? existing, {int? index}) {
    // 简单的颜色选择 + 类型选择
    showDialog(
      context: context,
      builder: (context) {
        HighlightType type = existing?.type ?? HighlightType.background;
        Color color = existing?.color ?? Colors.yellow;
        double opacity = existing?.opacity ?? 0.3;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing != null
                  ? _strings.settings_edit_style // 国际化
                  : _strings.settings_add_style), // 国际化
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 类型选择
                  SegmentedButton<HighlightType>(
                    segments: [
                      ButtonSegment(
                        value: HighlightType.background,
                        label: Text(_strings.settings_bg_highlight), // 国际化
                      ),
                      ButtonSegment(
                        value: HighlightType.underline,
                        label: Text(_strings.settings_underline), // 国际化
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (v) => setDialogState(() => type = v.first),
                  ),
                  const SizedBox(height: 16),
                  // 颜色选择（简化：预设颜色）
                  Wrap(
                    spacing: 8,
                    children: [
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.red,
                      Colors.orange,
                      Colors.purple,
                    ].map((c) {
                      return GestureDetector(
                        onTap: () => setDialogState(() => color = c),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: color == c
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // 透明度
                  Row(
                    children: [
                      Text(_strings.settings_opacity), // 国际化
                      Expanded(
                        child: Slider(
                          value: opacity,
                          min: 0.1,
                          max: 0.8,
                          onChanged: (v) => setDialogState(() => opacity = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_strings.settings_cancel), // 国际化
                ),
                FilledButton(
                  onPressed: () {
                    final style = HighlightStyle(type: type, color: color, opacity: opacity);
                    setState(() {
                      if (index != null) {
                        _presets[index] = style;
                      } else {
                        _presets.add(style);
                      }
                    });
                    _savePresets();
                    Navigator.pop(context);
                  },
                  child: Text(_strings.settings_save), // 国际化
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.settings_highlight_styles), // 国际化
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPreset,
            tooltip: _strings.settings_add_style, // 国际化
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _presets.length,
        itemBuilder: (context, index) {
          final style = _presets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: style.type == HighlightType.background
                      ? style.color.withOpacity(style.opacity)
                      : null,
                  border: style.type == HighlightType.underline
                      ? Border(bottom: BorderSide(color: style.color, width: 3))
                      : Border.all(color: style.color),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Text(
                style.type == HighlightType.background
                    ? _strings.settings_bg_highlight // 国际化
                    : _strings.settings_underline, // 国际化
              ),
              subtitle: Text(
                '${_strings.settings_color}: #${style.color.value.toRadixString(16).substring(2)} | '
                '${_strings.settings_opacity}: ${(style.opacity * 100).round()}%',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editPreset(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _deletePreset(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 步骤 4：创建其他设置子页面（占位）

以下页面为占位实现，内容后续按需填充：

**新增文件**: `apps/knode_app/lib/screens/settings/ai_settings_page.dart`

```dart
import 'package:flutter/material.dart';

class AISettingsPage extends StatelessWidget {
  const AISettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.settings_ai), // 国际化
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 复用已有的 AI 设置内容（从原 settings_page.dart 迁移）
          // AI 助手选择、模型配置、搜索设置等
        ],
      ),
    );
  }
}
```

**新增文件**: `apps/knode_app/lib/screens/settings/quiz_settings_page.dart`

```dart
import 'package:flutter/material.dart';

class QuizSettingsPage extends StatelessWidget {
  const QuizSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.settings_quiz), // 国际化
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 难度偏好、考试配置等
        ],
      ),
    );
  }
}
```

**新增文件**: `apps/knode_app/lib/screens/settings/backup_settings_page.dart`

```dart
import 'package:flutter/material.dart';

class BackupSettingsPage extends StatelessWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.settings_backup), // 国际化
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 复用已有的备份设置内容（从原 settings_page.dart 迁移）
          // WebDAV 配置等
        ],
      ),
    );
  }
}
```

**新增文件**: `apps/knode_app/lib/screens/settings/general_settings_page.dart`

```dart
import 'package:flutter/material.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.settings_general), // 国际化
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 语言、主题、日志等
          // 复用已有的通用设置内容
        ],
      ),
    );
  }
}
```

### 步骤 5：国际化字符串

**修改文件**: `apps/knode_app/res/strings.csv`

新增以下行：

```csv
settings_wiki,Wiki Settings,Wiki 设置
settings_wiki_subtitle,Reading, highlights, dictionary,阅读设置、高亮样式、字典
settings_ai,AI Settings,AI 设置
settings_ai_subtitle,Model, assistant, search,模型、助手、搜索
settings_quiz,Quiz Settings,答题设置
settings_quiz_subtitle,Difficulty, exam config,难度偏好、考试配置
settings_backup,Backup Settings,备份设置
settings_backup_subtitle,WebDAV configuration,WebDAV 配置
settings_general,General Settings,通用设置
settings_general_subtitle,Language, theme, logs,语言、主题、日志
settings_about,About,关于
settings_reading,Reading,阅读设置
settings_font_size,Font Size,字体大小
settings_line_spacing,Line Spacing,行距
settings_dark_mode,Dark Mode,深色模式
settings_highlight_styles,Highlight Styles,高亮样式
settings_manage_styles,Manage Styles,管理样式
settings_manage_styles_subtitle,Add, edit, delete highlight presets,新增、编辑、删除高亮预设
settings_dictionary,Dictionary,字典设置
settings_default_dict,Default Dictionary,默认词典
settings_add_style,Add Style,新增样式
settings_edit_style,Edit Style,编辑样式
settings_bg_highlight,Background,背景色
settings_underline,Underline,下划线
settings_opacity,Opacity,透明度
settings_color,Color,颜色
settings_cancel,Cancel,取消
settings_save,Save,保存
```

---

## 四、验收步骤

> **每个步骤完成后、提交代码前，必须通过以下验证命令。未通过验证的代码禁止提交。**

### 验证命令

```bash
# 1. 静态分析（必须 0 error）
dart analyze apps/knode_app

# 2. 运行所有测试（必须全部通过）
flutter test apps/knode_app

# 3. 国际化代码生成（必须成功）
dart run monolith_runner:localization

# 4. 硬编码中文扫描（必须 0 匹配）
grep -r "Text('[一-鿿]" --include="*.dart" apps/knode_app/lib/screens/settings_page.dart apps/knode_app/lib/screens/settings/ --exclude-dir=gen
```

### 验证标准

| 检查项 | 必须满足 | 不满足时处理 |
|--------|----------|-------------|
| `dart analyze` error 数 | 0 | 修复所有 error 后重新验证 |
| `flutter test` 失败数 | 0 | 修复失败测试后重新验证 |
| 代码生成 | 成功无报错 | 检查 CSV 格式后重新验证 |
| 硬编码中文 | 0 匹配 | 替换为 `_strings.xxx` 后重新验证 |

### 验证时机

- 步骤 1 完成后：验证设置主页模块入口无编译错误
- 步骤 2 完成后：验证 WikiSettingsPage 无编译错误
- 步骤 3 完成后：验证 HighlightStyleManager 无编译错误
- 步骤 4 完成后：验证各占位子页面无编译错误
- 步骤 5 完成后：验证国际化代码生成成功
- **最终提交前**：执行完整验证流程

---

## 五、实施顺序与依赖关系

```
步骤 1 (设置主页改造)
  ↓
步骤 2 (WikiSettingsPage) ─┐
步骤 3 (HighlightStyleManager) ─┼─→ 可并行
步骤 4 (其他子页面占位)    ─┤
步骤 5 (国际化)            ─┘
```

步骤 1 是基础，步骤 2/3/4/5 可并行。

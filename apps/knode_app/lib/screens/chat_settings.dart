import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/gen/strings.dart' as core_strings;
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();
const _coreStrings = core_strings.L10nStringsMixin();

class ChatSettingsPage extends ConsumerStatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  ConsumerState<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends ConsumerState<ChatSettingsPage> {
  bool _enableRag = true;
  bool _enableWebSearch = false;
  String _searchProvider = 'Tavily';
  String _searchApiKey = '';
  String _defaultAiAssistant = 'builtin';
  bool _showSearchToggle = true;
  bool _enableCitation = true;
  int _maxHistoryMessages = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  void _loadSettings() {
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    setState(() {
      _enableRag = settings['chat_enable_rag'] != 'false';
      _enableWebSearch = settings['chat_enable_web_search'] == 'true';
      _searchProvider = settings['chat_search_provider'] ?? 'Tavily';
      _searchApiKey = settings['chat_search_api_key'] ?? '';
      _defaultAiAssistant = settings['chat_default_ai_assistant'] ?? 'builtin';
      _showSearchToggle = settings['chat_show_search_toggle'] != 'false';
      _enableCitation = settings['chat_enable_citation'] != 'false';
      _maxHistoryMessages = int.tryParse(settings['chat_max_history_messages'] ?? '20') ?? 20;
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    await ref.read(settingsProvider.notifier).set(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat 设置'), centerTitle: true),
      body: ListView(
        children: [
          _Section(title: 'AI 助手', children: [
            SwitchListTile(
              title: Text('启用 RAG 知识库问答'),
              subtitle: Text('基于个人知识库进行智能问答'),
              value: _enableRag,
              onChanged: (value) {
                setState(() => _enableRag = value);
                _saveSetting('chat_enable_rag', value.toString());
              },
            ),
            SwitchListTile(
              title: Text('启用引用显示'),
              subtitle: Text('AI 回答中显示知识库引用来源'),
              value: _enableCitation,
              onChanged: (value) {
                setState(() => _enableCitation = value);
                _saveSetting('chat_enable_citation', value.toString());
              },
            ),
          ]),
          _Section(title: '联网搜索', children: [
            SwitchListTile(
              title: Text('启用联网搜索'),
              subtitle: Text('开启后 AI 可联网搜索最新信息'),
              value: _enableWebSearch,
              onChanged: (value) {
                setState(() => _enableWebSearch = value);
                _saveSetting('chat_enable_web_search', value.toString());
              },
            ),
            SwitchListTile(
              title: Text('显示搜索开关'),
              subtitle: Text('在输入框显示联网搜索切换按钮'),
              value: _showSearchToggle,
              onChanged: (value) {
                setState(() => _showSearchToggle = value);
                _saveSetting('chat_show_search_toggle', value.toString());
              },
            ),
            if (_enableWebSearch) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _searchProvider,
                  decoration: InputDecoration(
                    labelText: '搜索服务商',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Tavily', child: Text('Tavily')),
                    DropdownMenuItem(value: 'SerpAPI', child: Text('SerpAPI')),
                    DropdownMenuItem(value: 'disabled', child: Text('禁用')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _searchProvider = value);
                      _saveSetting('chat_search_provider', value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '搜索 API Key',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.visibility_off),
                  ),
                  obscureText: true,
                  controller: TextEditingController(text: _searchApiKey),
                  onChanged: (value) {
                    _searchApiKey = value;
                    _saveSetting('chat_search_api_key', value);
                  },
                ),
              ),
            ],
          ]),
          _Section(title: '会话设置', children: [
            ListTile(
              title: Text('历史消息保留数量'),
              subtitle: Text('$_maxHistoryMessages 条'),
              trailing: DropdownButton<int>(
                value: _maxHistoryMessages,
                items: [
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 20, child: Text('20')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                  DropdownMenuItem(value: 100, child: Text('100')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _maxHistoryMessages = value);
                    _saveSetting('chat_max_history_messages', value.toString());
                  }
                },
              ),
            ),
          ]),
          _Section(title: '关于', children: [
            ListTile(
              title: Text('Chat 模块版本'),
              subtitle: Text('v1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          )),
        ),
        ...children,
      ],
    );
  }
}
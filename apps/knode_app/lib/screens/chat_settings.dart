import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/providers/chat_ball_provider.dart';

class ChatSettingsPage extends ConsumerStatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  ConsumerState<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends ConsumerState<ChatSettingsPage> {
  String _currentStyle = 'gradient';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  void _loadSettings() {
    final chatBallState = ref.read(chatBallNotifierProvider);
    setState(() {
      _currentStyle = chatBallState.style;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatBallState = ref.watch(chatBallNotifierProvider);
    _currentStyle = chatBallState.style;

    return Scaffold(
      appBar: AppBar(title: Text('Chat \u8bbe\u7f6e'), centerTitle: true),
      body: ListView(
        children: [
          _Section(title: '\u60ac\u6d6e\u7403\u6837\u5f0f', children: [
            _StyleOption(
              title: '\u7b80\u7ea6\u56fe\u6807\u7403',
              subtitle: '\u5706\u5f62\u80cc\u666f + Chat \u56fe\u6807',
              value: 'icon',
              icon: Icons.chat,
              selected: _currentStyle == 'icon',
              onTap: () => _onStyleChanged('icon'),
            ),
            _StyleOption(
              title: '\u6e10\u53d8\u5f69\u8272\u7403',
              subtitle: '\u5e26\u6e10\u53d8\u8272\u7684\u5706\u5f62\uff0c\u66f4\u9192\u76ee',
              value: 'gradient',
              icon: Icons.circle,
              selected: _currentStyle == 'gradient',
              onTap: () => _onStyleChanged('gradient'),
            ),
            _StyleOption(
              title: '\u5934\u50cf\u7403',
              subtitle: '\u663e\u793a\u7528\u6237\u5934\u50cf\u6216 AI \u52a9\u624b\u5934\u50cf',
              value: 'avatar',
              icon: Icons.person,
              selected: _currentStyle == 'avatar',
              onTap: () => _onStyleChanged('avatar'),
            ),
          ]),
          _Section(title: '\u5176\u4ed6\u8bbe\u7f6e', children: [
            ListTile(
              title: Text('Chat \u6a21\u578b\u7248\u672c'),
              subtitle: Text('v1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }

  void _onStyleChanged(String style) {
    setState(() => _currentStyle = style);
    ref.read(chatBallNotifierProvider.notifier).setStyle(style);
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

class _StyleOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _StyleOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: value == 'gradient'
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: value != 'gradient'
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

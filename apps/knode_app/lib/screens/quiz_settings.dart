import 'package:flutter/material.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:quiz/screens/quiz_config_page.dart';

const _strings = L10nStringsMixin();

class QuizSettingsPage extends StatelessWidget {
  const QuizSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_quiz_settings), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: Text(_strings.knode_app_quiz_settings),
            subtitle: const Text(''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizConfigPage()),
            ),
          ),
        ],
      ),
    );
  }
}

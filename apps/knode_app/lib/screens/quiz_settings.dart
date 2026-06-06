import 'package:flutter/material.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/daily_quiz_settings.dart';
import 'package:knode_app/screens/random_flashcard_settings.dart';
import 'package:knode_app/screens/wrong_review_settings.dart';
import 'package:knode_app/screens/ai_quiz_settings.dart';
import 'package:knode_app/screens/exam_settings.dart';

const _strings = L10nStringsMixin();

class QuizSettingsPage extends StatelessWidget {
  const QuizSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_quiz_settings), centerTitle: true),
      body: ListView(
        children: [
          _SettingsTile(icon: Icons.today_outlined, title: _strings.knode_app_daily_quiz, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyQuizSettingsPage()))),
          _SettingsTile(icon: Icons.shuffle_outlined, title: _strings.knode_app_random_flashcard, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RandomFlashcardSettingsPage()))),
          _SettingsTile(icon: Icons.replay_outlined, title: _strings.knode_app_wrong_review, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WrongReviewSettingsPage()))),
          _SettingsTile(icon: Icons.smart_toy_outlined, title: _strings.knode_app_ai_quiz, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiQuizSettingsPage()))),
          _SettingsTile(icon: Icons.school_outlined, title: _strings.knode_app_exam_settings, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamSettingsPage()))),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
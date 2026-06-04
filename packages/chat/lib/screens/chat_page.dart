import 'package:flutter/material.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/screens/chat_content.dart';

const _strings = L10nStringsMixin();

/// Chat页面骨架
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.chat_ai_assistant),
        centerTitle: true,
      ),
      body: const ChatContent(),
    );
  }
}

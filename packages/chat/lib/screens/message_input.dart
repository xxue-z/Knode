import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import 'package:core/services/speech_service.dart';

const _strings = L10nStringsMixin();

class MessageInput extends ConsumerStatefulWidget {
  const MessageInput({super.key, this.onSend});
  final ValueChanged<String>? onSend;

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final _controller = TextEditingController();
  final _speechService = SpeechService();
  bool _isRecording = false;

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _speechService.stopListening();
      setState(() => _isRecording = false);
    } else {
      _speechService.onResult = (text, isFinal) {
        _controller.text = text;
        if (isFinal) setState(() => _isRecording = false);
      };
      await _speechService.startListening();
      setState(() => _isRecording = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic_outlined),
              color: _isRecording ? Colors.red : null,
              onPressed: _toggleRecording,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 4, minLines: 1,
                decoration: InputDecoration(
                  hintText: _strings.chat_input_message,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/widgets.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final TextEditingController textController = TextEditingController();

  ChatProvider() {
    _messages.addAll([
      ChatMessage(
          text: 'Hello! How can I assist you today?',
          isUser: false,
          timestamp: DateTime.now()),
      ChatMessage(
          text:
              'You can ask me dental questions, and I can provide information based on your provisional analysis. 😄',
          isUser: false,
          timestamp: DateTime.now()),
      ChatMessage(
          text: 'What steps can improve my smile alignment?',
          isUser: true,
          timestamp: DateTime.now()),
      ChatMessage(
          text:
              '• Seek orthodontic consultations for braces or clear aligners.\n• Avoid habits like teeth grinding.\n• Maintain good oral hygiene to prevent gum issues that affect alignment.',
          isUser: false,
          timestamp: DateTime.now()),
    ]);
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _messages.add(ChatMessage(
        text: text.trim(), isUser: true, timestamp: DateTime.now()));
    textController.clear();
    _isTyping = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1200), () {
      _isTyping = false;
      _messages.add(ChatMessage(
        text:
            'Thank you for your question. Based on your provisional analysis, I recommend consulting with a dental professional for personalized advice.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}

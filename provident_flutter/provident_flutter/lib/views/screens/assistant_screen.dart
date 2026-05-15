import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../services/pdf_service.dart';

class AssistantScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AssistantScreen({super.key, required this.onBack});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ChatProvider(context.read<AppProvider>().analysisResult),
      child: _AssistantBody(
        onBack: widget.onBack,
        scrollController: _scrollController,
        scrollToBottom: _scrollToBottom,
      ),
    );
  }
}

class _AssistantBody extends StatelessWidget {
  final VoidCallback onBack;
  final ScrollController scrollController;
  final VoidCallback scrollToBottom;

  const _AssistantBody({
    required this.onBack,
    required this.scrollController,
    required this.scrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    scrollToBottom();

    return Column(
      children: [
        AppHeader(
          title: 'AI Dentist Assistant',
          onBack: onBack,
          rightIcon: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              chatProvider.refreshChat();
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFFFF3CD),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFF856404), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "⚠ This AI assistant is specialized for dental report analysis and oral health guidance only. It is not a general-purpose chatbot or professional medical diagnosis system.",
                  style: TextStyle(color: Color(0xFF856404), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Language: ",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight)),
              DropdownButton<String>(
                value: chatProvider.currentLanguage,
                isDense: true,
                underline: const SizedBox(),
                items: ['English', 'Hindi', 'Marathi']
                    .map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(l, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) chatProvider.setLanguage(val);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            itemCount: chatProvider.messages.length +
                (chatProvider.isTyping ? 1 : 0) +
                (chatProvider.showTellMeMoreChips ? 1 : 0) +
                1, // +1 for action buttons
            itemBuilder: (context, index) {
              // Action buttons at end
              if (index ==
                  chatProvider.messages.length +
                      (chatProvider.isTyping ? 1 : 0) +
                      (chatProvider.showTellMeMoreChips ? 1 : 0)) {
                return _ActionButtons(
                    onBack: onBack, chatProvider: chatProvider);
              }
              // Tell me more chips
              if (chatProvider.showTellMeMoreChips &&
                  index ==
                      chatProvider.messages.length +
                          (chatProvider.isTyping ? 1 : 0)) {
                return _TellMeMoreChips(chatProvider: chatProvider);
              }
              // Typing indicator
              if (chatProvider.isTyping &&
                  index == chatProvider.messages.length) {
                return _TypingIndicator();
              }
              final msg = chatProvider.messages[index];
              return _MessageBubble(message: msg);
            },
          ),
        ),
        _ChatInput(provider: chatProvider),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TellMeMoreChips extends StatelessWidget {
  final ChatProvider chatProvider;

  const _TellMeMoreChips({required this.chatProvider});

  @override
  Widget build(BuildContext context) {
    final topics = [
      'Explain Alignment',
      'Gum Health Tips',
      'Explain Symmetry',
      'Cavity Detection Help',
      'Prevention Advice',
      'Oral Hygiene Tips',
      'Should I Visit Dentist?',
      'Explain My Report',
      'Treatment Suggestions',
      'Improve Gum Health'
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 42),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: topics.map((topic) {
          String translated = chatProvider.translate(topic);
          return ActionChip(
            label: Text(translated,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryEnd,
                    fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.primaryEnd, width: 1.5),
            ),
            onPressed: () {
              chatProvider.sendMessage(translated);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x332E6DD1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BotAvatar(),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  if (message.reportCards != null) ...[
                    const SizedBox(height: 16),
                    ...message.reportCards!.map((card) => _buildReportCard(card['title']!, card['value']!)),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryEnd,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.smart_toy_outlined, color: AppColors.primaryStart, size: 18),
          );
        },
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _BotAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
            ),
            child: const Row(
              children: [
                _Dot(delay: 0),
                SizedBox(width: 4),
                _Dot(delay: 150),
                SizedBox(width: 4),
                _Dot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, -4 * _anim.value),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primaryStart,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onBack;
  final ChatProvider chatProvider;

  const _ActionButtons({required this.onBack, required this.chatProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Tell me more - send a message to the chat
            chatProvider.triggerTellMeMore();
          },
          child: const _ActionBtn(
              icon: Icons.phone_outlined, label: 'Tell me more'),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            // Download Report - generate PDF
            final provider = context.read<AppProvider>();
            final analysis = provider.analysisResult;
            if (analysis != null) {
              await PdfService.generateAndPrintReport(analysis);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Report downloaded successfully')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No report available')),
              );
            }
          },
          child: const _ActionBtn(
              icon: Icons.download_outlined, label: 'Download Report'),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            context.read<AppProvider>().goTo(AppStep.upload);
          },
          child: const _ActionBtn(
              icon: Icons.refresh_rounded, label: 'Analyze Another Photo'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryEnd, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryEnd,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final ChatProvider provider;

  const _ChatInput({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFBFD6F5)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1E60DC), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: provider.textController,
              decoration: const InputDecoration(
                hintText: 'Ask a dental question...',
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: provider.sendMessage,
            ),
          ),
          GestureDetector(
            onTap: () => provider.sendMessage(provider.textController.text),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.send_rounded,
                  color: Color(0xFF4A88EF), size: 20),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

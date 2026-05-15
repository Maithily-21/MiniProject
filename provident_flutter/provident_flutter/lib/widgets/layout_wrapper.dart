import 'package:flutter/material.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import 'bottom_nav.dart';
import 'floating_message.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final String? floatingMessage;
  final bool showChat;
  final bool showBottomNav;
  final ActiveTab activeTab;
  final ValueChanged<ActiveTab> onTabChange;
  final TextEditingController? chatController;
  final VoidCallback? onSendChat;

  const LayoutWrapper({
    super.key,
    required this.child,
    this.floatingMessage,
    this.showChat = true,
    this.showBottomNav = true,
    required this.activeTab,
    required this.onTabChange,
    this.chatController,
    this.onSendChat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative blur blobs
                Positioned(
                  top: -50,
                  left: -100,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.2,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.5,
                  right: -100,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.2,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                // Main content
                Column(
                  children: [
                    Expanded(
                      child: child,
                    ),
                    // Floating message
                    if (floatingMessage != null) ...[
                      const SizedBox(height: 8),
                      FloatingMessage(message: floatingMessage!),
                    ],
                    if (showBottomNav) ...[
                      const SizedBox(height: 8),
                      AppBottomNav(
                        activeTab: activeTab,
                        onTabChange: onTabChange,
                        showChat: showChat,
                        chatController: chatController,
                        onSendChat: onSendChat,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

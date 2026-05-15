import 'package:flutter/material.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final ActiveTab activeTab;
  final ValueChanged<ActiveTab> onTabChange;
  final bool showChat;
  final TextEditingController? chatController;
  final VoidCallback? onSendChat;

  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
    this.showChat = true,
    this.chatController,
    this.onSendChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E60DC),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showChat) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ChatInputBar(
                controller: chatController,
                onSend: onSendChat,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: activeTab == ActiveTab.home,
                  onTap: () => onTabChange(ActiveTab.home),
                ),
                _NavItem(
                  icon: Icons.assignment_outlined,
                  label: 'Reports',
                  isActive: activeTab == ActiveTab.reports,
                  onTap: () => onTabChange(ActiveTab.reports),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;

  const _ChatInputBar({this.controller, this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFBFD6F5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1E60DC),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _IconBtn(icon: Icons.mic_none_rounded, onTap: () {}),
          _IconBtn(icon: Icons.send_rounded, onTap: onSend ?? () {}),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: const Color(0xFF4A88EF), size: 22),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryEnd : AppColors.textLighter;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

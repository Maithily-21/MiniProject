import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final Widget? rightIcon;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.rightIcon,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x331D4ED8),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative blur circles
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Row(
                children: [
                  if (showBack)
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 32),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: rightIcon,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

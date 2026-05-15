import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_header.dart';

class QuestionScreen extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final String question;
  final ValueChanged<bool> onAnswer;
  final VoidCallback onBack;

  const QuestionScreen({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.question,
    required this.onAnswer,
    required this.onBack,
  });

  double get progress => questionNumber / totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Question $questionNumber/$totalQuestions',
          onBack: onBack,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFDBEAFE),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryEnd),
                  ),
                ),
                const SizedBox(height: 48),
                // Question
                Expanded(
                  child: Center(
                    child: Text(
                      question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primaryEnd,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: _AnswerButton(
                        label: 'Yes',
                        icon: Icons.check_circle_outline_rounded,
                        isPrimary: true,
                        onTap: () => onAnswer(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _AnswerButton(
                        label: 'No',
                        icon: Icons.cancel_outlined,
                        isPrimary: false,
                        onTap: () => onAnswer(false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x401D4ED8),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDBEAFE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryEnd, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryEnd,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

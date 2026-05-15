import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/primary_button.dart';

class AnalyzeStartScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onUploadPhoto;

  const AnalyzeStartScreen({
    super.key,
    required this.onBack,
    required this.onUploadPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'PROVIDENT',
          onBack: onBack,
          rightIcon: const Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                const Text(
                  'ANALYZE YOUR SMILE',
                  style: TextStyle(
                    color: AppColors.primaryEnd,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                // Smile graphic
                Center(
                  child: SizedBox(
                    width: 260,
                    child: AspectRatio(
                      aspectRatio: 2.0,
                      child: CustomPaint(
                        painter: _SmileGraphicPainter(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Upload Photo',
                  icon: const Icon(Icons.cloud_upload_outlined,
                      color: Colors.white, size: 22),
                  onTap: onUploadPhoto,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Choose from Gallery',
                  icon: const Icon(Icons.photo_library_outlined,
                      color: Colors.white, size: 22),
                  gradient: AppColors.primaryGradient2,
                  onTap: onUploadPhoto,
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Disclaimer: This app provides only provisional assessment and is not a substitute for professional dental consultation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SmileGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cy = size.height / 2;

    // Outer lips shape
    final lipPaint = Paint()
      ..color = const Color(0xFFE64A19)
      ..style = PaintingStyle.fill;

    final lipPath = Path();
    lipPath.moveTo(size.width * 0.05, cy);
    lipPath.cubicTo(
      size.width * 0.25,
      size.height * 1.0,
      size.width * 0.75,
      size.height * 1.0,
      size.width * 0.95,
      cy,
    );
    lipPath.cubicTo(
      size.width * 0.75,
      0,
      size.width * 0.25,
      0,
      size.width * 0.05,
      cy,
    );
    canvas.drawPath(lipPath, lipPaint);

    // Upper teeth area
    final teethPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final teethPath = Path();
    teethPath.moveTo(size.width * 0.15, cy);
    teethPath.cubicTo(
      size.width * 0.3,
      size.height * 0.8,
      size.width * 0.7,
      size.height * 0.8,
      size.width * 0.85,
      cy,
    );
    teethPath.cubicTo(
      size.width * 0.7,
      size.height * 0.28,
      size.width * 0.3,
      size.height * 0.28,
      size.width * 0.15,
      cy,
    );
    canvas.drawPath(teethPath, teethPaint);

    // Tooth dividing lines
    final linePaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final toothLines = [0.3, 0.4, 0.5, 0.6, 0.7];
    for (final x in toothLines) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.35),
        Offset(size.width * x, size.height * 0.72),
        linePaint,
      );
    }

    // Lower teeth
    final lowerTeethPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;

    final lowerPath = Path();
    lowerPath.moveTo(size.width * 0.2, cy);
    lowerPath.cubicTo(
      size.width * 0.35,
      size.height * 0.66,
      size.width * 0.65,
      size.height * 0.66,
      size.width * 0.8,
      cy,
    );
    lowerPath.cubicTo(
      size.width * 0.65,
      size.height * 0.58,
      size.width * 0.35,
      size.height * 0.58,
      size.width * 0.2,
      cy,
    );
    canvas.drawPath(lowerPath, lowerTeethPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

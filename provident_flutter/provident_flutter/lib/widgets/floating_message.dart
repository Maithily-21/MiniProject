import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class FloatingMessage extends StatelessWidget {
  final String message;

  const FloatingMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141E60DC),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: _SmileFaceIcon(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmileFaceIcon extends StatelessWidget {
  const _SmileFaceIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _SmilePainter(),
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..style = PaintingStyle.fill;

    // Face circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.38), size.width * 0.07, eyePaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.38), size.width * 0.07, eyePaint);

    // Smile arc
    final smilePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.62);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.78,
      size.width * 0.7,
      size.height * 0.62,
    );
    canvas.drawPath(path, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

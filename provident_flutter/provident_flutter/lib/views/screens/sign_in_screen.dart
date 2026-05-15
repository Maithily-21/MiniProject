import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'dart:math' as math;

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignIn;

  const SignInScreen({super.key, required this.onSignIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(
            0,
            MediaQuery.of(context).size.height - 200,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            _LogoSection(),
            const SizedBox(height: 32),
            // Subtitle
            const Text(
              'Sign in to start analyzing your smile photos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Email field
            _InputField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            // Password field
            _PasswordField(
              controller: _passwordController,
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Sign In',
              onTap: widget.onSignIn,
            ),
            const SizedBox(height: 24),
            // Divider
            _OrDivider(),
            const SizedBox(height: 20),
            // Social buttons
            const Row(
              children: [
                Expanded(child: _SocialButton(isGoogle: true)),
                SizedBox(width: 16),
                Expanded(child: _SocialButton(isGoogle: false)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryEnd.withOpacity(0.1),
                  child: const Icon(Icons.broken_image, color: AppColors.primaryEnd, size: 40),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Provident',
          style: TextStyle(
            color: AppColors.primaryEnd,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'AI Smile Analysis Assistant',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x061E60DC),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x061E60DC),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: const InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: Color(0xFF4A88EF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 1,
          color: const Color(0xFFDBEAFE),
        ),
        Container(
          color: const Color(0xFFDCEAFF),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'Or continue with',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final bool isGoogle;

  const _SocialButton({required this.isGoogle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x061E60DC),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isGoogle ? _GoogleLogo() : _AppleLogo(),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue arc (right side)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.0,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    // Red arc (top)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.1,
      1.0,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    // Yellow arc (bottom-left)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.2,
      0.9,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    // Green arc (bottom)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.0,
      0.65,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    // Horizontal line for G
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _AppleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, color: Colors.black, size: 22);
  }
}

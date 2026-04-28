import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Fond animé ────────────────────────────────────────────
          const _AnimatedBackground(),

          // ── Contenu principal ─────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 16 : 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(isSmall),
                        const SizedBox(height: 40),
                        _buildCard(context, isSmall),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── En-tête logo ─────────────────────────────────────────────────
  Widget _buildHeader(bool isSmall) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: Colors.white,
            size: 34,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.6, 0.6), curve: Curves.elasticOut),

        const SizedBox(height: 18),

        Text(
          "MindScribe AI",
          style: TextStyle(
            fontSize: isSmall ? 28 : 34,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.3),

        const SizedBox(height: 8),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Tag(text: "Capture", color: AppColors.accent),
            const SizedBox(width: 6),
            _Tag(text: "Transcription", color: AppColors.accentMint),
            const SizedBox(width: 6),
            _Tag(text: "Décision", color: AppColors.accentViolet),
          ],
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }

  // ── Carte de connexion ────────────────────────────────────────────
  Widget _buildCard(BuildContext context, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 20 : 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.accent.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Connexion",
                style: TextStyle(
                  fontSize: isSmall ? 18 : 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Connectez-vous pour accéder à vos réunions",
            style: TextStyle(fontSize: 13, color: AppColors.hint),
          ),

          const SizedBox(height: 28),

          // Champs
          _InputField(
            controller: controller.emailController,
            label: "Adresse email",
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          _PasswordField(controller: controller.passwordController),

          const SizedBox(height: 10),

          // Message d'erreur
          Obx(() {
            final msg = controller.errorMessage.value;
            if (msg == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 6, bottom: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.danger.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: AppColors.danger, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      msg,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2);
          }),

          const SizedBox(height: 22),

          // Bouton connexion
          Obx(() {
            final loading = controller.isLoading.value;
            return GestureDetector(
              onTap: loading ? null : controller.login,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: loading
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryGlow],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: loading ? AppColors.border : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: loading
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Center(
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation(AppColors.hint),
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Se connecter",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ],
                        ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Mot de passe oublié
          Center(
            child: TextButton(
              onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
              child: const Text(
                "Mot de passe oublié ?",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.96, 0.96),
          curve: Curves.easeOut,
        );
  }

  // ── Pied de page ──────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        // ── Lien inscription ──
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.register),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Pas encore de compte ? ',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.hint,
              ),
              children: [
                TextSpan(
                  text: 'Créer un compte',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: 400.ms).fadeIn(),

        const SizedBox(height: 16),

        // Copyright
        Text(
          "Usage interne — MindScribe AI © 2026",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.hint.withOpacity(0.7),
          ),
        ).animate(delay: 500.ms).fadeIn(),
      ],
    );
  }
}

// ─── Fond animé ──────────────────────────────────────────────────────────────

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _ctrl2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _ctrl3 = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl1, _ctrl2, _ctrl3]),
      builder: (_, __) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BackgroundPainter(
            t1: _ctrl1.value,
            t2: _ctrl2.value,
            t3: _ctrl3.value,
          ),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double t1, t2, t3;
  _BackgroundPainter({required this.t1, required this.t2, required this.t3});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );

    _drawBlob(
      canvas,
      center: Offset(
        w * 0.85 + math.sin(t1 * math.pi * 2) * w * 0.06,
        h * 0.12 + math.cos(t1 * math.pi * 2) * h * 0.04,
      ),
      radius: w * 0.52,
      color: const Color(0xFF00004D).withOpacity(0.055),
    );

    _drawBlob(
      canvas,
      center: Offset(
        w * 0.0 + math.sin(t2 * math.pi * 2) * w * 0.07,
        h * 0.48 + math.cos(t2 * math.pi * 2) * h * 0.06,
      ),
      radius: w * 0.48,
      color: const Color(0xFF4F6FFF).withOpacity(0.055),
    );

    _drawBlob(
      canvas,
      center: Offset(
        w * 0.75 + math.sin(t3 * math.pi * 2) * w * 0.05,
        h * 0.88 + math.cos(t3 * math.pi * 2) * h * 0.04,
      ),
      radius: w * 0.42,
      color: const Color(0xFF00C9A7).withOpacity(0.05),
    );

    _drawDot(canvas,
        Offset(w * 0.12, h * 0.08 + math.sin(t1 * 4) * 6),
        6,
        const Color(0xFF4F6FFF).withOpacity(0.18));

    _drawDot(canvas,
        Offset(w * 0.9, h * 0.35 + math.cos(t2 * 3) * 8),
        4,
        const Color(0xFF00C9A7).withOpacity(0.22));

    _drawDot(canvas,
        Offset(w * 0.06, h * 0.72 + math.sin(t3 * 5) * 5),
        5,
        const Color(0xFF7B5EA7).withOpacity(0.2));

    _drawDot(canvas,
        Offset(w * 0.88, h * 0.78 + math.cos(t1 * 4) * 6),
        7,
        const Color(0xFF00004D).withOpacity(0.1));

    final linePaint = Paint()
      ..color = const Color(0xFF00004D).withOpacity(0.025)
      ..strokeWidth = 1;

    for (int i = 0; i < 8; i++) {
      final x = w / 7 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), linePaint);
    }
    for (int i = 0; i < 14; i++) {
      final y = h / 13 * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), linePaint);
    }
  }

  void _drawBlob(Canvas canvas,
      {required Offset center, required double radius, required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawDot(Canvas canvas, Offset center, double r, Color color) {
    canvas.drawCircle(center, r, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.t1 != t1 || old.t2 != t2 || old.t3 != t3;
}

// ─── Widgets réutilisables ────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordField({required this.controller});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: "Mot de passe",
        labelStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.lock_outline_rounded,
              color: AppColors.primary, size: 18),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.hint,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
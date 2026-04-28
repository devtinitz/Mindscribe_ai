import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _bgCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // ── Contrôleurs ──────────────────────────────────────────────
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // ── Animations logo ───────────────────────────────────────────
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // ── Animations texte ──────────────────────────────────────────
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );

    // ── Séquence d'animations ─────────────────────────────────────
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 3500));
    await _navigate();
  }

  Future<void> _navigate() async {
    final prefs = Get.find<SharedPreferences>();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Contenu centré ──────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo animé
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryGlow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 8,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Texte animé
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          const Text(
                            'MindScribe AI',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vos réunions, intelligemment',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Version en bas ──────────────────────────────────────
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textCtrl,
              builder: (_, __) => FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    // Indicateur de chargement
                    SizedBox(
                      width: 40,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Usage interne — MindScribe AI © 2026',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.hint.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fond animé ───────────────────────────────────────────────────────────────

class _SplashBgPainter extends CustomPainter {
  final double t;
  _SplashBgPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );

    void blob(double cx, double cy, double r, Color c) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [c, c.withOpacity(0)],
        ).createShader(Rect.fromCircle(
            center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    blob(
      w * 0.8 + math.sin(t * math.pi * 2) * w * 0.06,
      h * 0.15 + math.cos(t * math.pi * 2) * h * 0.04,
      w * 0.55,
      const Color(0xFF00004D).withOpacity(0.06),
    );

    blob(
      w * 0.1 + math.sin(t * math.pi * 2) * w * 0.05,
      h * 0.75 + math.cos(t * math.pi * 2) * h * 0.05,
      w * 0.5,
      const Color(0xFF4F6FFF).withOpacity(0.06),
    );

    blob(
      w * 0.5 + math.sin(t * math.pi * 2) * w * 0.03,
      h * 0.5 + math.cos(t * math.pi * 2) * h * 0.03,
      w * 0.3,
      const Color(0xFF00C9A7).withOpacity(0.04),
    );
  }

  @override
  bool shouldRepaint(_SplashBgPainter old) => old.t != t;
}
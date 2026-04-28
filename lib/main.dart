import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/meeting/presentation/routes/app_pages.dart';
import 'features/meeting/presentation/routes/app_routes.dart';
import 'features/meeting/presentation/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MindScribe AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withOpacity(0.92),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            const _GlobalAnimatedBackground(),
            if (child != null) child,
          ],
        );
      },
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}

// ─── Fond animé global avec 20 bulles ────────────────────────────────────────

class _GlobalAnimatedBackground extends StatefulWidget {
  const _GlobalAnimatedBackground();

  @override
  State<_GlobalAnimatedBackground> createState() =>
      _GlobalAnimatedBackgroundState();
}

class _GlobalAnimatedBackgroundState extends State<_GlobalAnimatedBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (i) {
      final durations = [10, 13, 8, 16, 11, 14];
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: durations[i]),
      )..repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(_controllers),
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _GlobalBgPainter(
          ts: _controllers.map((c) => c.value).toList(),
        ),
      ),
    );
  }
}

class _GlobalBgPainter extends CustomPainter {
  final List<double> ts;

  _GlobalBgPainter({required this.ts});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Fond blanc de base ─────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );

    final t0 = ts[0];
    final t1 = ts[1];
    final t2 = ts[2];
    final t3 = ts[3];
    final t4 = ts[4];
    final t5 = ts[5];

    // ── 20 bulles grosses et visibles ─────────────────────────────
    final bubbles = [
      // Bleu nuit — grandes
      _Bubble(cx: w * 0.85 + math.sin(t0 * math.pi * 2) * w * 0.08, cy: h * 0.1 + math.cos(t0 * math.pi * 2) * h * 0.06, r: w * 0.45, color: const Color(0xFF00004D).withOpacity(0.12)),
      _Bubble(cx: w * 0.1 + math.sin(t1 * math.pi * 2) * w * 0.07, cy: h * 0.5 + math.cos(t1 * math.pi * 2) * h * 0.08, r: w * 0.42, color: const Color(0xFF00004D).withOpacity(0.1)),

      // Bleu électrique
      _Bubble(cx: w * 0.7 + math.sin(t2 * math.pi * 2) * w * 0.09, cy: h * 0.8 + math.cos(t2 * math.pi * 2) * h * 0.06, r: w * 0.4, color: const Color(0xFF4F6FFF).withOpacity(0.13)),
      _Bubble(cx: w * 0.2 + math.sin(t3 * math.pi * 2) * w * 0.06, cy: h * 0.2 + math.cos(t3 * math.pi * 2) * h * 0.07, r: w * 0.38, color: const Color(0xFF4F6FFF).withOpacity(0.11)),
      _Bubble(cx: w * 0.5 + math.sin(t4 * math.pi * 2) * w * 0.1, cy: h * 0.35 + math.cos(t4 * math.pi * 2) * h * 0.09, r: w * 0.3, color: const Color(0xFF4F6FFF).withOpacity(0.09)),

      // Mint / turquoise
      _Bubble(cx: w * 0.8 + math.sin(t5 * math.pi * 2) * w * 0.07, cy: h * 0.55 + math.cos(t5 * math.pi * 2) * h * 0.08, r: w * 0.36, color: const Color(0xFF00C9A7).withOpacity(0.12)),
      _Bubble(cx: w * 0.15 + math.sin(t0 * math.pi * 3) * w * 0.08, cy: h * 0.85 + math.cos(t0 * math.pi * 3) * h * 0.05, r: w * 0.32, color: const Color(0xFF00C9A7).withOpacity(0.1)),
      _Bubble(cx: w * 0.6 + math.sin(t1 * math.pi * 3) * w * 0.06, cy: h * 0.65 + math.cos(t1 * math.pi * 3) * h * 0.07, r: w * 0.28, color: const Color(0xFF00C9A7).withOpacity(0.09)),

      // Violet
      _Bubble(cx: w * 0.35 + math.sin(t2 * math.pi * 2.5) * w * 0.09, cy: h * 0.4 + math.cos(t2 * math.pi * 2.5) * h * 0.08, r: w * 0.34, color: const Color(0xFF7B5EA7).withOpacity(0.1)),
      _Bubble(cx: w * 0.9 + math.sin(t3 * math.pi * 2.5) * w * 0.06, cy: h * 0.3 + math.cos(t3 * math.pi * 2.5) * h * 0.06, r: w * 0.3, color: const Color(0xFF7B5EA7).withOpacity(0.09)),
      _Bubble(cx: w * 0.05 + math.sin(t4 * math.pi * 2.5) * w * 0.07, cy: h * 0.7 + math.cos(t4 * math.pi * 2.5) * h * 0.06, r: w * 0.26, color: const Color(0xFF7B5EA7).withOpacity(0.08)),

      // Bleu glow
      _Bubble(cx: w * 0.45 + math.sin(t5 * math.pi * 3) * w * 0.08, cy: h * 0.9 + math.cos(t5 * math.pi * 3) * h * 0.05, r: w * 0.32, color: const Color(0xFF1A1AAD).withOpacity(0.1)),
      _Bubble(cx: w * 0.75 + math.sin(t0 * math.pi * 3.5) * w * 0.07, cy: h * 0.42 + math.cos(t0 * math.pi * 3.5) * h * 0.07, r: w * 0.28, color: const Color(0xFF1A1AAD).withOpacity(0.09)),

      // Or doux
      _Bubble(cx: w * 0.25 + math.sin(t1 * math.pi * 3) * w * 0.08, cy: h * 0.6 + math.cos(t1 * math.pi * 3) * h * 0.07, r: w * 0.3, color: const Color(0xFFE8A838).withOpacity(0.08)),
      _Bubble(cx: w * 0.6 + math.sin(t2 * math.pi * 3.5) * w * 0.06, cy: h * 0.15 + math.cos(t2 * math.pi * 3.5) * h * 0.06, r: w * 0.25, color: const Color(0xFFE8A838).withOpacity(0.07)),

      // Petites bulles dynamiques
      _Bubble(cx: w * 0.5 + math.sin(t3 * math.pi * 4) * w * 0.12, cy: h * 0.5 + math.cos(t3 * math.pi * 4) * h * 0.1, r: w * 0.18, color: const Color(0xFF4F6FFF).withOpacity(0.15)),
      _Bubble(cx: w * 0.3 + math.sin(t4 * math.pi * 4) * w * 0.1, cy: h * 0.25 + math.cos(t4 * math.pi * 4) * h * 0.09, r: w * 0.16, color: const Color(0xFF00C9A7).withOpacity(0.14)),
      _Bubble(cx: w * 0.8 + math.sin(t5 * math.pi * 4) * w * 0.09, cy: h * 0.75 + math.cos(t5 * math.pi * 4) * h * 0.08, r: w * 0.15, color: const Color(0xFF00004D).withOpacity(0.13)),
      _Bubble(cx: w * 0.15 + math.sin(t0 * math.pi * 5) * w * 0.08, cy: h * 0.45 + math.cos(t0 * math.pi * 5) * h * 0.07, r: w * 0.14, color: const Color(0xFF7B5EA7).withOpacity(0.14)),
      _Bubble(cx: w * 0.65 + math.sin(t1 * math.pi * 5) * w * 0.07, cy: h * 0.05 + math.cos(t1 * math.pi * 5) * h * 0.06, r: w * 0.13, color: const Color(0xFF1A1AAD).withOpacity(0.13)),
    ];

    for (final b in bubbles) {
      _drawBlob(canvas, cx: b.cx, cy: b.cy, r: b.r, color: b.color);
    }

    // ── Grille subtile ────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFF00004D).withOpacity(0.03)
      ..strokeWidth = 0.8;

    for (int i = 0; i <= 10; i++) {
      final x = w / 10 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (int i = 0; i <= 18; i++) {
      final y = h / 18 * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }
  }

  void _drawBlob(Canvas canvas, {
    required double cx,
    required double cy,
    required double r,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, paint);
  }

  @override
  bool shouldRepaint(_GlobalBgPainter old) => true;
}

class _Bubble {
  final double cx, cy, r;
  final Color color;
  const _Bubble({required this.cx, required this.cy, required this.r, required this.color});
}
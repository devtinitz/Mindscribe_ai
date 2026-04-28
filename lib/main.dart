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

// ─── Bulle avec position et vitesse indépendantes ────────────────────────────

class _BubbleData {
  double x, y;         // position actuelle (0.0 à 1.0)
  double vx, vy;       // vitesse (direction libre)
  final double radius; // rayon relatif
  final Color color;

  _BubbleData({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;

    // Rebond sur les bords
    if (x < 0) { x = 0; vx = vx.abs(); }
    if (x > 1) { x = 1; vx = -vx.abs(); }
    if (y < 0) { y = 0; vy = vy.abs(); }
    if (y > 1) { y = 1; vy = -vy.abs(); }
  }
}

// ─── Fond animé global ────────────────────────────────────────────────────────

class _GlobalAnimatedBackground extends StatefulWidget {
  const _GlobalAnimatedBackground();

  @override
  State<_GlobalAnimatedBackground> createState() =>
      _GlobalAnimatedBackgroundState();
}

class _GlobalAnimatedBackgroundState extends State<_GlobalAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_BubbleData> _bubbles;
  double _lastTime = 0;

  static const _colors = [
    Color(0xFF00004D), // bleu nuit
    Color(0xFF4F6FFF), // bleu électrique
    Color(0xFF00C9A7), // mint
    Color(0xFF7B5EA7), // violet
    Color(0xFF1A1AAD), // bleu glow
    Color(0xFFE8A838), // or
  ];

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);

    // 10 bulles avec positions et vitesses aléatoires
    _bubbles = List.generate(10, (i) {
      final color = _colors[i % _colors.length];
      // Vitesses variées dans toutes les directions
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 0.01 + rng.nextDouble() * 0.03; // vitesse variable
      return _BubbleData(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        radius: 0.012 + rng.nextDouble() * 0.02, // taille variée petite
        color: color.withOpacity(0.35 + rng.nextDouble() * 0.25),
      );
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick)..repeat();
  }

  void _onTick() {
    final t = _ctrl.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0;
    final dt = (t - _lastTime) / 1000.0;
    _lastTime = t;
    if (dt > 0 && dt < 0.1) {
      for (final b in _bubbles) b.update(dt);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _BubblePainter(bubbles: _bubbles),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<_BubbleData> bubbles;
  _BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fond blanc
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );

    // Grille subtile
    final gridPaint = Paint()
      ..color = const Color(0xFF00004D).withOpacity(0.04)
      ..strokeWidth = 0.8;
    for (int i = 0; i <= 10; i++) {
      canvas.drawLine(Offset(w / 10 * i, 0), Offset(w / 10 * i, h), gridPaint);
    }
    for (int i = 0; i <= 18; i++) {
      canvas.drawLine(Offset(0, h / 18 * i), Offset(w, h / 18 * i), gridPaint);
    }

    // Dessiner les bulles
    for (final b in bubbles) {
      final cx = b.x * w;
      final cy = b.y * h;
      final r = b.radius * w;

      // Cercle solide
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = b.color);

      // Petit reflet blanc en haut à gauche
      canvas.drawCircle(
        Offset(cx - r * 0.3, cy - r * 0.3),
        r * 0.25,
        Paint()..color = Colors.white.withOpacity(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => true;
}
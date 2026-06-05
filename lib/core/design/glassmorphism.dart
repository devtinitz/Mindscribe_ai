import 'dart:ui';
import 'package:flutter/material.dart';

class AppGlass {
  // ── Glass Container Decorations ────────────────────────────────
  static BoxDecoration glassLight({
    double blur = 10,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration glassDark({
    double blur = 10,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      color: const Color(0xFF00004D).withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration glassCard({
    Color? color,
    double blur = 8,
    double opacity = 0.12,
  }) {
    final baseColor = color ?? Colors.white;
    return BoxDecoration(
      color: baseColor.withOpacity(opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ── Backdrop Filter Widget ─────────────────────────────────────
  static Widget buildGlassEffect({
    required Widget child,
    double blur = 10,
    Color overlayColor = const Color(0xFF00004D),
    double overlayOpacity = 0.05,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        decoration: BoxDecoration(
          color: overlayColor.withOpacity(overlayOpacity),
        ),
        child: child,
      ),
    );
  }

  // ── Preset Decorations ─────────────────────────────────────────
  static const BoxDecoration cardSmall = BoxDecoration(
    color: Color.fromARGB(31, 255, 255, 255),
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border(
      top: BorderSide(color: Color.fromARGB(51, 255, 255, 255), width: 1),
      left: BorderSide(color: Color.fromARGB(51, 255, 255, 255), width: 1),
    ),
  );

  static const BoxDecoration cardMedium = BoxDecoration(
    color: Color.fromARGB(38, 255, 255, 255),
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border(
      top: BorderSide(color: Color.fromARGB(64, 255, 255, 255), width: 1.5),
      left: BorderSide(color: Color.fromARGB(64, 255, 255, 255), width: 1.5),
    ),
  );

  static const BoxDecoration cardLarge = BoxDecoration(
    color: Color.fromARGB(45, 255, 255, 255),
    borderRadius: BorderRadius.all(Radius.circular(24)),
    border: Border(
      top: BorderSide(color: Color.fromARGB(77, 255, 255, 255), width: 2),
      left: BorderSide(color: Color.fromARGB(77, 255, 255, 255), width: 2),
    ),
  );
}

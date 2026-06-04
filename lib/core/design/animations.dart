import 'package:flutter/material.dart';

class AppAnimations {
  // ── Durations ─────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);
  static const Duration slowest = Duration(milliseconds: 800);

  // ── Curves ────────────────────────────────────────────────────────
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeOutQuart = Curves.easeOutQuart;
  static const Curve easeOutExpo = Curves.easeOutExpo;

  // ── Combos (duration + curve) ────────────────────────────────────
  static const Duration pageTransitionDuration = Duration(milliseconds: 350);
  static const Curve pageTransitionCurve = Curves.easeOutCubic;

  static const Duration cardAnimationDuration = Duration(milliseconds: 250);
  static const Curve cardAnimationCurve = Curves.easeOutCubic;

  static const Duration buttonPressAnimationDuration = Duration(milliseconds: 150);
  static const Curve buttonPressAnimationCurve = Curves.easeInOut;
}

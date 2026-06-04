import 'package:flutter/material.dart';

class AppSpacing {
  // Tokens d'espacement
  static const double xs = 4;    // Mini spacing
  static const double sm = 8;    // Small
  static const double base = 12; // Base
  static const double md = 16;   // Medium
  static const double lg = 24;   // Large
  static const double xl = 32;   // Extra Large
  static const double xxl = 40;  // 2X Large
  static const double xxxl = 48; // 3X Large
  static const double huge = 64; // Huge

  // Padding presets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingBase = EdgeInsets.all(base);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Padding horizontal/vertical
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
}

import 'package:flutter/material.dart';
import '../../features/meeting/presentation/theme/app_colors.dart';

class AppElevation {
  // ── Ombre subtile (hover minimal) ──────────────────────────────────
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0a000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // ── Ombre petite (cards par défaut) ────────────────────────────────
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // ── Ombre moyenne (elevated cards) ────────────────────────────────
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1a000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ── Ombre large (modals, popups) ────────────────────────────────────
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // ── Ombre très large (fullscreen modals) ──────────────────────────
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  // ── Ombre avec couleur primaire (interactive) ─────────────────────
  static List<BoxShadow> primary([double opacity = 0.3]) => [
    BoxShadow(
      color: AppColors.primary.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Ombre danger (states critiques) ──────────────────────────────
  static List<BoxShadow> danger([double opacity = 0.3]) => [
    BoxShadow(
      color: AppColors.danger.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Ombre success ────────────────────────────────────────────────
  static List<BoxShadow> success([double opacity = 0.3]) => [
    BoxShadow(
      color: AppColors.success.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

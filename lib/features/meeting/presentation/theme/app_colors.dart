import 'package:flutter/material.dart';

class AppColors {
  // ── Couleurs principales ──────────────────────────────────────────
  static const primary = Color(0xFF00004D);       // bleu nuit profond
  static const primaryLight = Color(0xFF0A0A7A);  // bleu nuit moyen
  static const primaryGlow = Color(0xFF1A1AAD);   // bleu électrique

  // ── Accents ──────────────────────────────────────────────────────
  static const accent = Color(0xFF4F6FFF);        // bleu vif
  static const accentSoft = Color(0xFF8BA4FF);    // bleu doux
  static const accentMint = Color(0xFF00C9A7);    // mint/turquoise
  static const accentViolet = Color(0xFF7B5EA7);  // violet sombre
  static const accentGold = Color(0xFFE8A838);    // or doux

  // ── Surfaces & Fonds ─────────────────────────────────────────────
  static const background = Colors.white;
  static const surface = Color(0xFFF6F7FF);       // blanc légèrement bleuté
  static const surfaceCard = Colors.white;
  static const overlay = Color(0xCC00004D);       // overlay sombre

  // ── Textes ───────────────────────────────────────────────────────
  static const text = Color(0xFF00004D);
  static const textSecondary = Color(0xFF4A4A80);
  static const hint = Color(0xFF8A8AB0);

  // ── États ────────────────────────────────────────────────────────
  static const success = Color(0xFF00C9A7);
  static const danger = Color(0xFFFF4D6D);
  static const warning = Color(0xFFE8A838);

  // ── Bordures & Inputs ────────────────────────────────────────────
  static const border = Color(0xFFDDDFF5);
  static const inputFill = Color(0xFFF4F5FF);

  // ── Dégradés prédéfinis ──────────────────────────────────────────
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryGlow, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient softGradient = LinearGradient(
    colors: [Color(0xFFF0F2FF), Color(0xFFE8F4FF), Color(0xFFEEFAF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [accentMint, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/design/spacing.dart';
import '../../../../../core/design/typography.dart';
import '../../../../../core/design/radius.dart';
import '../../theme/app_colors.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: AppRadius.xlRadius,
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.hint).withOpacity(0.15),
                  borderRadius: AppRadius.xlRadius,
                  border: Border.all(
                    color: (iconColor ?? AppColors.hint).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: iconColor ?? AppColors.hint,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Title ─────────────────────────────────────────────
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.heading4.copyWith(
                  color: AppColors.text,
                ),
              ),

              // ── Subtitle ──────────────────────────────────────────
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTypography.secondary.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              // ── Button ────────────────────────────────────────────
              if (buttonLabel != null && onButtonPressed != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: buttonLabel!,
                  onPressed: onButtonPressed,
                  size: AppButtonSize.large,
                  isFullWidth: true,
                  icon: Icons.sparkles_rounded,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

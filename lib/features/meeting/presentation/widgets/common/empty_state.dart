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
  final AppButtonSize buttonSize;
  final bool isFullWidth;

  const EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
    this.iconColor,
    this.buttonSize = AppButtonSize.medium,
    this.isFullWidth = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: AppRadius.xlRadius,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                GestureDetector(
                  onTap: onButtonPressed,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.lgRadius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          buttonLabel!,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
    );
  }
}

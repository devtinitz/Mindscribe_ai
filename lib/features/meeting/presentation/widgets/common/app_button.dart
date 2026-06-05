import 'package:flutter/material.dart';
import '../../../../../core/design/animations.dart';
import '../../../../../core/design/radius.dart';
import '../../../../../core/design/spacing.dart';
import '../../../../../core/design/typography.dart';
import '../../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    final textColor = _getTextColor(isDisabled);

    Widget buttonContent = isLoading
        ? SizedBox(
            height: _getHeight() * 0.5,
            width: _getHeight() * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(textColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize(), color: textColor),
                SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: _getTextStyle().copyWith(color: textColor),
              ),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.hint.withOpacity(0.3),
            disabledForegroundColor: Colors.white.withOpacity(0.6),
            padding: _getPadding(),
            shape: AppRadius.mdButton,
            elevation: 0,
            overlayColor: AppColors.primary.withOpacity(0.8),
          ),
          child: buttonContent,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent.withOpacity(0.1),
            foregroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.hint.withOpacity(0.1),
            disabledForegroundColor: AppColors.hint.withOpacity(0.5),
            padding: _getPadding(),
            shape: AppRadius.mdButton,
            elevation: 0,
            overlayColor: AppColors.primary.withOpacity(0.05),
          ),
          child: buttonContent,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.hint.withOpacity(0.5),
            side: BorderSide(
              color: isDisabled ? AppColors.hint : AppColors.primary,
            ),
            padding: _getPadding(),
            shape: AppRadius.mdButton,
            overlayColor: AppColors.primary.withOpacity(0.05),
          ),
          child: buttonContent,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.hint.withOpacity(0.5),
            padding: _getPadding(),
            shape: AppRadius.mdButton,
            overlayColor: AppColors.primary.withOpacity(0.05),
          ),
          child: buttonContent,
        ),
    };

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.base,
        ),
      AppButtonSize.large => const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
    };
  }

  double _getHeight() {
    return switch (size) {
      AppButtonSize.small => 32,
      AppButtonSize.medium => 40,
      AppButtonSize.large => 48,
    };
  }

  TextStyle _getTextStyle() {
    return switch (size) {
      AppButtonSize.small => AppTypography.labelMedium,
      AppButtonSize.medium => AppTypography.labelLarge,
      AppButtonSize.large => AppTypography.subtitle2,
    };
  }

  double _getIconSize() {
    return switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 18,
      AppButtonSize.large => 20,
    };
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) return AppColors.hint;
    return switch (variant) {
      AppButtonVariant.primary => Colors.white,
      AppButtonVariant.secondary => AppColors.primary,
      AppButtonVariant.outlined => AppColors.primary,
      AppButtonVariant.ghost => AppColors.primary,
    };
  }
}

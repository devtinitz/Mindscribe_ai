import 'package:flutter/material.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/design/typography.dart';
import '../../../theme/app_colors.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  final Widget? trailing;
  final double? verticalPadding;

  const AppSectionHeader({
    required this.title,
    this.icon,
    this.color,
    this.trailing,
    this.verticalPadding = AppSpacing.md,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            title,
            style: AppTypography.subtitle2.copyWith(
              color: color ?? AppColors.primary,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

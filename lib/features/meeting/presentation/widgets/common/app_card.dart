import 'package:flutter/material.dart';
import '../../../../../core/design/elevation.dart';
import '../../../../../core/design/radius.dart';
import '../../theme/app_colors.dart';

enum AppCardVariant { elevated, flat, outlined }

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final AppCardVariant variant;
  final void Function()? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? shadow;
  final BorderRadius? borderRadius;

  const AppCard({
    required this.child,
    this.padding,
    this.variant = AppCardVariant.flat,
    this.onTap,
    this.backgroundColor,
    this.shadow,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lgRadius;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? _getBackgroundColor(),
            borderRadius: radius,
            border: _getBorder(),
            boxShadow: shadow ?? _getShadow(),
          ),
          child: child,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    return switch (variant) {
      AppCardVariant.elevated => Colors.white,
      AppCardVariant.flat => Colors.white.withOpacity(0.95),
      AppCardVariant.outlined => Colors.white,
    };
  }

  Border? _getBorder() {
    return switch (variant) {
      AppCardVariant.outlined => Border.all(color: AppColors.border),
      _ => null,
    };
  }

  List<BoxShadow>? _getShadow() {
    return switch (variant) {
      AppCardVariant.elevated => AppElevation.md,
      AppCardVariant.flat => AppElevation.xs,
      AppCardVariant.outlined => AppElevation.xs,
    };
  }
}

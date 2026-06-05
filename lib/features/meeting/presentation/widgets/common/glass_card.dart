import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/design/radius.dart';
import '../../../../../core/design/spacing.dart';
import '../../theme/app_colors.dart';

enum GlassCardVariant { light, dark, colored }

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final GlassCardVariant variant;
  final void Function()? onTap;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;

  const GlassCard({
    required this.child,
    this.padding,
    this.variant = GlassCardVariant.light,
    this.onTap,
    this.blur = 10,
    this.opacity = 0.12,
    this.color,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lgRadius;
    final baseColor = _getColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: baseColor.withOpacity(opacity),
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    return switch (variant) {
      GlassCardVariant.light => Colors.white,
      GlassCardVariant.dark => const Color(0xFF00004D),
      GlassCardVariant.colored => color ?? Colors.white,
    };
  }
}

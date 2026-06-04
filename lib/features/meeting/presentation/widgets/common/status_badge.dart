import 'package:flutter/material.dart';
import '../../../../core/design/radius.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/design/typography.dart';
import '../../../theme/app_colors.dart';

enum StatusType { pending, processing, done, failed }

class StatusBadge extends StatelessWidget {
  final StatusType status;
  final String? customLabel;

  const StatusBadge({
    required this.status,
    this.customLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            customLabel ?? label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
          if (status == StatusType.processing) ...[
            const SizedBox(width: AppSpacing.xs),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ]
        ],
      ),
    );
  }

  (Color, IconData, String) _getStatusConfig() {
    return switch (status) {
      StatusType.pending => (
          Colors.orange,
          Icons.hourglass_top_rounded,
          'En attente',
        ),
      StatusType.processing => (
          AppColors.primary,
          Icons.autorenew_rounded,
          'En cours',
        ),
      StatusType.done => (
          AppColors.success,
          Icons.check_circle_rounded,
          'Terminé',
        ),
      StatusType.failed => (
          AppColors.danger,
          Icons.error_rounded,
          'Erreur',
        ),
    };
  }
}

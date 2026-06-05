import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/design/index.dart';
import '../../../../core/design/glassmorphism.dart';
import '../controllers/auth_controller.dart';
import '../controllers/meetings_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/common/index.dart';
import '../widgets/common/glass_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final meetingsController = Get.find<MeetingsController>();
    final now = DateTime.now();
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const AppSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        leading: Builder(
          builder: (ctx) => Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.menu_rounded,
                    size: 20, color: AppColors.primary),
              ),
            ),
          ),
        ),
        title: Text(
          'Dashboard',
          style: AppTypography.subtitle2.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        final meetings = meetingsController.meetings;
        final total = meetings.length;
        final done = meetings.where((m) => m.status == 'done').length;
        final pending = meetings.where((m) =>
            m.status == 'pending' || m.status == 'processing').length;
        final recent = meetings.take(3).toList();

        // ── Tâches en attente ──────────────────────────────────────
        final pendingTasks = <Map<String, String>>[];
        for (final m in meetings) {
          if (m.tasks != null) {
            for (final t in m.tasks!) {
              if (!t.isDone) {
                pendingTasks.add({
                  'title': t.action,
                  'assignee': t.assignee,
                  'meeting': m.title.isNotEmpty ? m.title : 'Réunion',
                });
              }
            }
          }
        }

        // ── Données graphique (7 derniers jours) ───────────────────
        final weekData = List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          final count = meetings.where((m) =>
            m.createdAt.year == day.year &&
            m.createdAt.month == day.month &&
            m.createdAt.day == day.day
          ).length;
          return count.toDouble();
        });

        final weekLabels = List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          const d = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
          return d[day.weekday - 1];
        });

        return SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Salutation ──
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingLg,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primaryGlow.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.xlRadius,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour ${user?.name?.split(' ').first ?? ''} 👋',
                      style: AppTypography.heading2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$dayName ${now.day} $monthName ${now.year}',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.selectParticipants),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: AppRadius.mdRadius,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.mic_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Nouvelle réunion',
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Statistiques ──
              AppSectionHeader(
                title: 'Vue d\'ensemble',
                icon: Icons.dashboard_rounded,
              ),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total',
                      value: total.toString(),
                      icon: Icons.list_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: _StatCard(
                      label: 'Terminées',
                      value: done.toString(),
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: _StatCard(
                      label: 'En cours',
                      value: pending.toString(),
                      icon: Icons.hourglass_top_rounded,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Graphique 7 jours ──
              AppSectionHeader(
                title: 'Activité cette semaine',
                icon: Icons.trending_up_rounded,
              ),

              AppCard(
                variant: AppCardVariant.outlined,
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weekData.reduce((a, b) => a + b).toInt()} réunions sur 7 jours',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (weekData.reduce((a, b) => a > b ? a : b) + 1)
                              .clamp(3, double.infinity),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppColors.primary,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()} réunion(s)',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 || idx >= weekLabels.length) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      weekLabels[idx],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                getTitlesWidget: (value, meta) {
                                  if (value % 1 != 0) return const SizedBox();
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.hint,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: AppColors.border,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (i) {
                            final isToday = i == 6;
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: weekData[i] == 0 ? 0.1 : weekData[i],
                                  color: isToday
                                      ? AppColors.accent
                                      : AppColors.primary.withOpacity(0.7),
                                  width: 22,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Tâches en attente ──
              if (pendingTasks.isNotEmpty) ...[
                AppSectionHeader(
                  title: 'Tâches en attente',
                  icon: Icons.task_alt_rounded,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${pendingTasks.length}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
                ...pendingTasks.take(5).map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        variant: AppCardVariant.outlined,
                        padding: AppSpacing.paddingBase,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.base),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'] ?? '',
                                    style: AppTypography.labelMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${task['assignee']} — ${task['meeting']}',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: AppColors.hint),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Réunions récentes ──
              AppSectionHeader(
                title: 'Réunions récentes',
                icon: Icons.history_rounded,
                trailing: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.meetings),
                  child: const Text('Voir tout'),
                ),
              ),

              if (recent.isEmpty)
                EmptyState(
                  icon: Icons.mic_off_rounded,
                  title: 'Aucune réunion pour le moment',
                  subtitle: 'Commencez votre première réunion',
                  buttonLabel: 'Nouvelle réunion',
                  onButtonPressed: () => Get.toNamed(AppRoutes.selectParticipants),
                )
              else
                ...recent.map((meeting) {
                  final statusType = switch (meeting.status) {
                    'done' => StatusType.done,
                    'failed' => StatusType.failed,
                    'processing' => StatusType.processing,
                    _ => StatusType.pending,
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      variant: AppCardVariant.outlined,
                      onTap: () {
                        Get.find<MeetingsController>()
                            .loadMeetingDetail(meeting.id ?? 0);
                        Get.toNamed(AppRoutes.meetingDetail,
                            arguments: meeting.id);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: AppRadius.mdRadius,
                            ),
                            child: const Icon(Icons.mic_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meeting.title,
                                  style: AppTypography.labelLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${meeting.createdAt.day.toString().padLeft(2, '0')}/${meeting.createdAt.month.toString().padLeft(2, '0')}/${meeting.createdAt.year}',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: statusType),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Carte statistique ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.outlined,
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.smRadius,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            value,
            style: AppTypography.heading2.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/meetings_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';

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
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.15), width: 1),
                ),
                child: const Icon(Icons.menu_rounded,
                    size: 20, color: AppColors.primary),
              ),
            ),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Salutation ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryGlow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dayName ${now.day} $monthName ${now.year}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.recorder),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Nouvelle réunion',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Statistiques ──
              const Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),

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
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Terminées',
                      value: done.toString(),
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
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

              const SizedBox(height: 24),

              // ── Graphique 7 jours ──
              const Text(
                'Activité cette semaine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weekData.reduce((a, b) => a + b).toInt()} réunions sur 7 jours',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tâches en attente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${pendingTasks.length}',
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pendingTasks.take(5).map((task) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${task['assignee']} — ${task['meeting']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: AppColors.hint),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
              ],

              // ── Réunions récentes ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Réunions récentes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.meetings),
                    child: const Text('Voir tout'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (recent.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.mic_off_rounded,
                          size: 48, color: AppColors.hint),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune réunion pour le moment',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.recorder),
                        icon: const Icon(Icons.mic_rounded, size: 16),
                        label: const Text('Commencer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recent.map((meeting) {
                  Color statusColor;
                  IconData statusIcon;
                  String statusLabel;

                  switch (meeting.status) {
                    case 'done':
                      statusColor = AppColors.success;
                      statusIcon = Icons.check_circle_rounded;
                      statusLabel = 'Terminé';
                      break;
                    case 'failed':
                      statusColor = AppColors.danger;
                      statusIcon = Icons.error_rounded;
                      statusLabel = 'Erreur';
                      break;
                    case 'processing':
                      statusColor = AppColors.primary;
                      statusIcon = Icons.autorenew_rounded;
                      statusLabel = 'En cours';
                      break;
                    default:
                      statusColor = Colors.orange;
                      statusIcon = Icons.hourglass_top_rounded;
                      statusLabel = 'En attente';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Get.find<MeetingsController>()
                            .loadMeetingDetail(meeting.id ?? 0);
                        Get.toNamed(AppRoutes.meetingDetail,
                            arguments: meeting.id);
                      },
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.mic_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      title: Text(
                        meeting.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${meeting.createdAt.day}/${meeting.createdAt.month}/${meeting.createdAt.year}',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
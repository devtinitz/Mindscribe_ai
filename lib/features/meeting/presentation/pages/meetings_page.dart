import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/meeting.dart';
import '../controllers/meetings_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';

class MeetingsPage extends GetView<MeetingsController> {
  const MeetingsPage({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'done': return AppColors.success;
      case 'failed': return AppColors.danger;
      case 'processing': return AppColors.primary;
      default: return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'done': return 'Terminé';
      case 'failed': return 'Erreur';
      case 'processing': return 'En cours...';
      default: return 'En attente';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'done': return Icons.check_circle_rounded;
      case 'failed': return Icons.error_rounded;
      case 'processing': return Icons.autorenew_rounded;
      default: return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const AppSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
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
          'Réunions passées',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: FloatingActionButton.extended(
              onPressed: () => Get.toNamed(AppRoutes.recorder),
              backgroundColor: AppColors.primary,
              elevation: 2,
              icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Nouvelle réunion',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.queryController,
              decoration: InputDecoration(
                hintText: 'Rechercher un compte-rendu...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: controller.search,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
              onSubmitted: (_) => controller.search(),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.meetings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_off_rounded,
                            size: 60, color: AppColors.hint),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune réunion trouvée.',
                          style: TextStyle(
                              fontSize: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.recorder),
                          child: const Text('Commencer un enregistrement'),
                        ),
                      ],
                    ),
                  );
                }

                final total = controller.meetings.length;

                return RefreshIndicator(
                  onRefresh: controller.loadMeetings,
                  child: ListView.separated(
                    itemCount: total,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final meeting = controller.meetings[index];
                      final num = total - index;
                      final displayTitle = meeting.title.trim().isEmpty
                          ? 'Réunion $num'
                          : meeting.title;

                      return _MeetingCard(
                        meeting: meeting,
                        displayTitle: displayTitle,
                        statusColor: _statusColor(meeting.status),
                        statusLabel: _statusLabel(meeting.status),
                        statusIcon: _statusIcon(meeting.status),
                        onTap: () {
                          controller.loadMeetingDetail(meeting.id ?? 0);
                          Get.toNamed(AppRoutes.meetingDetail,
                              arguments: meeting.id);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({
    required this.meeting,
    required this.displayTitle,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
    required this.onTap,
  });

  final Meeting meeting;
  final String displayTitle;
  final Color statusColor;
  final String statusLabel;
  final IconData statusIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mic_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meeting.createdAt.day}/${meeting.createdAt.month}/${meeting.createdAt.year}',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: AppColors.hint),
            ],
          ),
        ),
      ),
    );
  }
}
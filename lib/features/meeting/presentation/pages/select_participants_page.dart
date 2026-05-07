import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/participants_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class SelectParticipantsPage extends StatelessWidget {
  const SelectParticipantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ParticipantsController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.offAllNamed(AppRoutes.dashboard),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.primary),
          ),
        ),
        title: const Text(
          'Participants à la réunion',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off_rounded, size: 60, color: AppColors.hint),
                const SizedBox(height: 16),
                Text(
                  'Aucun membre dans l\'équipe.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.recorder),
                  icon: const Icon(Icons.mic_rounded,
                      size: 18, color: Colors.white),
                  label: const Text('Continuer sans inviter',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Info ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sélectionnez les participants. Ils recevront un email de notification et le compte-rendu automatiquement après la réunion.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Liste membres ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final member = controller.members[index];
                  return Obx(() {
                    final selected = controller.isSelected(member.id);
                    return GestureDetector(
                      onTap: () => controller.toggleMember(member.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.08)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  member.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Infos
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.text,
                                    ),
                                  ),
                                  Text(
                                    member.email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (member.role != null)
                                    Text(
                                      member.role!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Checkbox
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.hint,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            // ── Boutons ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Obx(() => Text(
                        '${controller.selectedIds.length} participant(s) sélectionné(s)',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Passer sans inviter
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Get.toNamed(AppRoutes.recorder),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side:
                                const BorderSide(color: AppColors.primary),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Passer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirmer et démarrer
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Get.toNamed(AppRoutes.recorder),
                          icon: const Icon(Icons.mic_rounded,
                              size: 18, color: Colors.white),
                          label: const Text(
                            'Démarrer la réunion',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
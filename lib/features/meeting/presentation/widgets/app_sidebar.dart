import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Drawer(
      backgroundColor: Colors.white,
      child: Obx(() {
        final user = authController.currentUser.value;

        return Column(
          children: [
            // ── En-tête profil ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryGlow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar avec initiale
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nom de l'utilisateur
                  Text(
                    user?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Navigation ──────────────────────────────────────────
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              route: AppRoutes.dashboard,
            ),
            _NavItem(
              icon: Icons.mic_rounded,
              label: 'Nouvelle réunion',
              route: AppRoutes.selectParticipants,
            ),
            _NavItem(
              icon: Icons.list_alt_rounded,
              label: 'Mes réunions',
              route: AppRoutes.meetings,
            ),

            const Spacer(),

            const Divider(height: 1),

            // ── Déconnexion ─────────────────────────────────────────
            ListTile(
              onTap: () => _confirmLogout(context, authController),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.danger, size: 18),
              ),
              title: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  void _confirmLogout(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Déconnexion',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Item de navigation ───────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = Get.currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary.withOpacity(0.08) : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          if (!isCurrent) Get.offAllNamed(route);
        },
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: isCurrent ? AppColors.primary : AppColors.hint,
              size: 18),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.primary : AppColors.text,
          ),
        ),
        trailing: isCurrent
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
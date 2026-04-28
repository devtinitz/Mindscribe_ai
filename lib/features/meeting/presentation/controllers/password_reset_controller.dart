import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class PasswordResetController extends GetxController {
  final emailController = TextEditingController();
  final tokenController = TextEditingController();
  final newPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isResetting = false.obs;
  final errorMessage = RxnString();
  final obscurePassword = true.obs;

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;

  // ── Envoie le code par email ──────────────────────────────────────
  Future<void> sendResetLink() async {
    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Veuillez entrer votre email.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final dio = Get.find<Dio>();
      await dio.post('/auth/forgot-password', data: {
        'email': emailController.text.trim(),
      });

      // Redirige vers la page de reset avec l'email
      Get.toNamed(
        AppRoutes.resetPassword,
        arguments: emailController.text.trim(),
      );

    } catch (e) {
      errorMessage.value = 'Une erreur est survenue. Réessayez.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Réinitialise le mot de passe ──────────────────────────────────
  Future<void> resetPassword() async {
    final email = Get.arguments as String? ?? emailController.text.trim();
    final token = tokenController.text.trim();
    final password = newPasswordController.text;

    if (token.isEmpty || password.isEmpty) {
      errorMessage.value = 'Tous les champs sont obligatoires.';
      return;
    }

    if (password.length < 6) {
      errorMessage.value = 'Le mot de passe doit contenir au moins 6 caractères.';
      return;
    }

    isResetting.value = true;
    errorMessage.value = null;

    try {
      final dio = Get.find<Dio>();
      await dio.post('/auth/reset-password', data: {
        'email': email,
        'token': token,
        'password': password,
      });

      // ✅ Notification de succès (4000ms)
      Get.snackbar(
        '✅ Mot de passe réinitialisé !',
        'Votre mot de passe a été modifié avec succès. Connectez-vous.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 4000),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );

      // Redirige vers le login
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAllNamed(AppRoutes.login);

    } catch (e) {
      if (e is DioException && e.response?.statusCode == 422) {
        errorMessage.value = 'Code invalide ou expiré.';
      } else {
        errorMessage.value = 'Une erreur est survenue. Réessayez.';
      }
    } finally {
      isResetting.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    tokenController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
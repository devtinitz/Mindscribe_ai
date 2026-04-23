import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class AuthController extends GetxController {
  AuthController(this._loginUser, this._logoutUser, this._registerUser);

  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RegisterUser _registerUser;

  // ── Controllers ───────────────────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── État ──────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final currentUser = Rxn<User>();

  // ── Connexion ─────────────────────────────────────────────────────
  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      errorMessage.value = 'Email et mot de passe obligatoires.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final user = await _loginUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      currentUser.value = user;
      Get.snackbar(
        '👋 Bienvenue !',
        'Bonjour ${user.name}, content de vous revoir.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
      Get.offAllNamed(AppRoutes.recorder);
    } catch (e) {
      errorMessage.value = 'Connexion impossible: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Inscription ───────────────────────────────────────────────────
  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      errorMessage.value = 'Tous les champs sont obligatoires.';
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'Les mots de passe ne correspondent pas.';
      return;
    }

    if (passwordController.text.length < 6) {
      errorMessage.value = 'Le mot de passe doit contenir au moins 6 caractères.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final user = await _registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      currentUser.value = user;
      Get.snackbar(
        '🎉 Compte créé !',
        'Bienvenue ${user.name}, votre compte a été créé avec succès.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
      Get.offAllNamed(AppRoutes.recorder);
    } catch (e) {
      errorMessage.value = 'Inscription impossible: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Déconnexion ───────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _logoutUser();
    } finally {
      currentUser.value = null;
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
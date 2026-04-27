import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/send_two_factor_code.dart';
import '../../domain/usecases/verify_two_factor_code.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class AuthController extends GetxController {
  AuthController(
    this._loginUser,
    this._logoutUser,
    this._registerUser,
    this._sendTwoFactorCode,
    this._verifyTwoFactorCode,
    this._getCurrentUser,
  );

  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RegisterUser _registerUser;
  final SendTwoFactorCode _sendTwoFactorCode;
  final VerifyTwoFactorCode _verifyTwoFactorCode;
  final GetCurrentUser _getCurrentUser;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final twoFactorController = TextEditingController();

  final isLoading = false.obs;
  final isVerifying = false.obs;
  final errorMessage = RxnString();
  final twoFactorError = RxnString();
  final currentUser = Rxn<User>();

  // ── Charge le user au démarrage ───────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadCachedUser();
  }

  Future<void> _loadCachedUser() async {
    try {
      final user = await _getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (_) {}
  }

  // ── Connexion → envoie code 2FA ───────────────────────────────────
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
      await _sendTwoFactorCode();
      Get.offAllNamed(AppRoutes.twoFactor);
    } catch (e) {
      errorMessage.value = 'Connexion impossible: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Vérifier le code 2FA → dashboard ─────────────────────────────
  Future<void> verifyTwoFactor() async {
    final code = twoFactorController.text.trim();
    if (code.length != 6) {
      twoFactorError.value = 'Entrez le code à 6 chiffres.';
      return;
    }

    isVerifying.value = true;
    twoFactorError.value = null;

    try {
      final verified = await _verifyTwoFactorCode(code);

      if (verified) {
        final user = currentUser.value;
        Get.snackbar(
          '👋 Bienvenue !',
          'Bonjour ${user?.name}, content de vous revoir.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 16,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        twoFactorError.value = 'Code invalide ou expiré.';
      }
    } catch (e) {
      twoFactorError.value = 'Erreur de vérification: $e';
    } finally {
      isVerifying.value = false;
    }
  }

  // ── Renvoyer le code ──────────────────────────────────────────────
  Future<void> resendTwoFactorCode() async {
    try {
      await _sendTwoFactorCode();
      Get.snackbar(
        '📧 Code renvoyé !',
        'Un nouveau code a été envoyé à votre email.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      twoFactorError.value = 'Impossible de renvoyer le code.';
    }
  }

  // ── Inscription → dashboard ───────────────────────────────────────
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
      errorMessage.value =
          'Le mot de passe doit contenir au moins 6 caractères.';
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
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorMessage.value = 'Inscription impossible: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Déconnexion ───────────────────────────────────────────────────
  Future<void> logout() async {
    currentUser.value = null;
    errorMessage.value = null;
    twoFactorError.value = null;

    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
    twoFactorController.clear();

    try {
      await _logoutUser();
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(AppRoutes.login);
    });
  }
}
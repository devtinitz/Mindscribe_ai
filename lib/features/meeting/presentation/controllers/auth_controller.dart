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

  // Indique si on vient de l'inscription (pour le message de bienvenue)
  bool _isNewUser = false;

  @override
  void onInit() {
    super.onInit();
    _resetState();
    _loadCachedUser();
  }

  void _resetState() {
    isLoading.value = false;
    isVerifying.value = false;
    errorMessage.value = null;
    twoFactorError.value = null;
    _isNewUser = false;
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    twoFactorController.clear();
  }

  Future<void> _loadCachedUser() async {
    try {
      final user = await _getCurrentUser();
      if (user != null) currentUser.value = user;
    } catch (_) {}
  }

  String _simplifyError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('connection') || msg.contains('network') ||
        msg.contains('xmlhttp') || msg.contains('socket') ||
        msg.contains('failed to fetch')) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }
    if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (msg.contains('422') || msg.contains('validation')) {
      return 'Informations invalides. Vérifiez les champs saisis.';
    }
    if (msg.contains('302') || msg.contains('redirect')) {
      return 'Erreur de configuration. Contactez l\'administrateur.';
    }
    if (msg.contains('429')) {
      return 'Trop de tentatives. Réessayez dans quelques minutes.';
    }
    if (msg.contains('500')) {
      return 'Erreur serveur. Réessayez dans un moment.';
    }
    if (msg.contains('email') && msg.contains('taken')) {
      return 'Cette adresse email est déjà utilisée.';
    }
    return 'Une erreur est survenue. Réessayez.';
  }

  // ── Connexion → dashboard directement (sans 2FA) ──────────────────
  Future<void> login() async {
    if (isLoading.value) return;

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      errorMessage.value = 'Email et mot de passe obligatoires.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    _isNewUser = false;

    try {
      final user = await _loginUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      currentUser.value = user;

      // Connexion directe sans 2FA
      Get.snackbar(
        '👋 Bienvenue !',
        'Content de vous revoir, ${user.name} !',
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
      errorMessage.value = _simplifyError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Vérifier le code 2FA (seulement après inscription) ───────────
  Future<void> verifyTwoFactor() async {
    if (isVerifying.value) return;

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
        twoFactorError.value = null;
        isVerifying.value = false;
        final user = currentUser.value;

        // Message différent selon nouveau ou ancien compte
        if (_isNewUser) {
          Get.snackbar(
            '🎉 Bienvenue sur MindScribe AI !',
            'Votre compte est confirmé. Bonne utilisation ${user?.name ?? ''} !',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success.withOpacity(0.9),
            colorText: Colors.white,
            borderRadius: 16,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.celebration_rounded, color: Colors.white),
          );
        } else {
          Get.snackbar(
            '👋 Bienvenue !',
            'Content de vous revoir, ${user?.name ?? ''} !',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.primary.withOpacity(0.9),
            colorText: Colors.white,
            borderRadius: 16,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          );
        }
        _isNewUser = false;
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        twoFactorError.value = 'Code invalide ou expiré. Réessayez.';
        isVerifying.value = false;
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('connection') || msg.contains('network') ||
          msg.contains('xmlhttp') || msg.contains('failed to fetch')) {
        twoFactorError.value = null;
        isVerifying.value = false;
        _isNewUser = false;
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        twoFactorError.value = 'Code invalide ou expiré. Réessayez.';
        isVerifying.value = false;
      }
    }
  }

  Future<void> resendTwoFactorCode() async {
    twoFactorController.clear();
    twoFactorError.value = null;
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

  // ── Inscription → 2FA pour confirmer le compte ────────────────────
  Future<void> register() async {
    if (isLoading.value) return;

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
      _isNewUser = true;

      // Envoie code 2FA pour confirmation du compte
      twoFactorController.clear();
      twoFactorError.value = null;
      await _sendTwoFactorCode();

      Get.snackbar(
        '📧 Code envoyé !',
        'Un code de confirmation a été envoyé à ${user.email}.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.email_rounded, color: Colors.white),
      );
      Get.offAllNamed(AppRoutes.twoFactor);
    } catch (e) {
      errorMessage.value = _simplifyError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUser();
    } catch (_) {}

    _resetState();
    currentUser.value = null;

    await Future.delayed(const Duration(milliseconds: 200));
    Get.delete<AuthController>(force: true);
    Get.offAllNamed(AppRoutes.login);
  }
}
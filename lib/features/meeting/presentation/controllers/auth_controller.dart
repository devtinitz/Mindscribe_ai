import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  AuthController(this._loginUser, this._logoutUser);

  final LoginUser _loginUser;
  final LogoutUser _logoutUser;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final currentUser = Rxn<User>();

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
      Get.snackbar('Connexion', 'Bienvenue ${user.name}');
      Get.offAllNamed(AppRoutes.recorder);
    } catch (e) {
      errorMessage.value = 'Connexion impossible: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUser();
    } finally {
      currentUser.value = null;
      emailController.clear();
      passwordController.clear();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

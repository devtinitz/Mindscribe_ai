import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  static const _tokenKey = 'auth_token';
  static const _nameKey = 'user_name';
  static const _emailKey = 'user_email';
  static const _idKey = 'user_id';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleSessionExpired();
    }
    handler.next(err);
  }

  Future<void> _handleSessionExpired() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.remove(_tokenKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_idKey);
    } catch (_) {}

    Get.snackbar(
      '⏳ Session expirée',
      'Votre session a expiré. Veuillez vous reconnecter.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(AppRoutes.login);
    });
  }
}
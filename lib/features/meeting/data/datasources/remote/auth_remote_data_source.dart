import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String name, required String email, required String password});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> sendTwoFactorCode();
  Future<bool> verifyTwoFactorCode(String code);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required Dio dio, required SharedPreferences prefs})
      : _dio = dio,
        _prefs = prefs;

  static const _tokenKey = 'auth_token';
  static const _nameKey = 'user_name';
  static const _emailKey = 'user_email';
  static const _idKey = 'user_id';

  final Dio _dio;
  final SharedPreferences _prefs;

  Future<void> _saveUser(UserModel user) async {
    await _prefs.setString(_nameKey, user.name);
    await _prefs.setString(_emailKey, user.email);
    if (user.id != null) await _prefs.setInt(_idKey, user.id!);
  }

  UserModel? _getCachedUser() {
    final token = _prefs.getString(_tokenKey);
    final name = _prefs.getString(_nameKey);
    final email = _prefs.getString(_emailKey);
    final id = _prefs.getInt(_idKey);
    if (token == null || name == null || email == null) return null;
    return UserModel(id: id, name: name, email: email, token: token);
  }

  Exception _handleDioError(DioException e) {
    // Erreurs réseau / timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Serveur inaccessible. Vérifiez votre connexion réseau.');
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    switch (statusCode) {
      case 401:
        return Exception('Email ou mot de passe incorrect.');

      case 403:
        return Exception('Accès refusé.');

      case 404:
        return Exception('Compte introuvable.');

      case 422:
        if (responseData is Map) {
          // Récupère le premier message d'erreur dans "errors"
          final errors = responseData['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              final msg = firstError.first.toString().toLowerCase();
              // Laravel renvoie "Identifiants invalides." dans errors.email
              if (msg.contains('identifiants') || msg.contains('invalid')) {
                return Exception('Email ou mot de passe incorrect.');
              }
              if (msg.contains('email') && msg.contains('pris') ||
                  msg.contains('already') || msg.contains('unique')) {
                return Exception('Cette adresse email est déjà utilisée.');
              }
              return Exception(firstError.first.toString());
            }
          }

          // Fallback sur le champ "message"
          final message = responseData['message']?.toString() ?? '';
          if (message.toLowerCase().contains('identifiants')) {
            return Exception('Email ou mot de passe incorrect.');
          }
          if (message.toLowerCase().contains('email')) {
            return Exception('Adresse email invalide ou déjà utilisée.');
          }
          if (message.toLowerCase().contains('password') ||
              message.toLowerCase().contains('mot de passe')) {
            return Exception('Le mot de passe doit contenir au moins 6 caractères.');
          }
          if (message.isNotEmpty) return Exception(message);
        }
        return Exception('Informations invalides. Vérifiez les champs saisis.');

      case 429:
        return Exception('Trop de tentatives. Réessayez dans quelques minutes.');

      case 500:
      case 502:
      case 503:
        return Exception('Erreur serveur. Réessayez dans un moment.');

      default:
        return Exception('Une erreur est survenue. Réessayez.');
    }
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data ?? <String, dynamic>{};
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _prefs.setString(_tokenKey, token);
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final user = UserModel.fromJson(data);
      await _saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      final data = response.data ?? <String, dynamic>{};
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _prefs.setString(_tokenKey, token);
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final user = UserModel.fromJson(data);
      await _saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = _prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final data = response.data ?? <String, dynamic>{};
      final user = UserModel.fromJson({...data, 'token': token});
      await _saveUser(user);
      return user;
    } on DioException {
      return _getCachedUser();
    }
  }

  @override
  Future<void> logout() async {
    final token = _prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      try {
        await _dio.post<void>('/auth/logout');
      } on DioException {
        // ignore
      }
    }
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_idKey);
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<void> sendTwoFactorCode() async {
    try {
      await _dio.post<void>('/auth/send-code');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> verifyTwoFactorCode(String code) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/verify-code',
        data: {'code': code},
      );
      return response.data?['verified'] == true;
    } on DioException {
      return false;
    }
  }
}
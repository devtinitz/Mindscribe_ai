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

  // ── Sauvegarde le user localement ────────────────────────────────
  Future<void> _saveUser(UserModel user) async {
    await _prefs.setString(_nameKey, user.name);
    await _prefs.setString(_emailKey, user.email);
    if (user.id != null) await _prefs.setInt(_idKey, user.id!);
  }

  // ── Récupère le user local ────────────────────────────────────────
  UserModel? _getCachedUser() {
    final token = _prefs.getString(_tokenKey);
    final name = _prefs.getString(_nameKey);
    final email = _prefs.getString(_emailKey);
    final id = _prefs.getInt(_idKey);

    if (token == null || name == null || email == null) return null;

    return UserModel(
      id: id,
      name: name,
      email: email,
      token: token,
    );
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
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
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
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
      // Si le serveur est inaccessible, retourne le user local
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

    // Supprime toutes les données locales
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_idKey);
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<void> sendTwoFactorCode() async {
    await _dio.post<void>('/auth/send-code');
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
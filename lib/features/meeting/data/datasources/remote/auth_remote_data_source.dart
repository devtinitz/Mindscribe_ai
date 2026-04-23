import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required Dio dio,
    required SharedPreferences prefs,
  })  : _dio = dio,
        _prefs = prefs;

  static const _tokenKey = 'auth_token';
  final Dio _dio;
  final SharedPreferences _prefs;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data ?? <String, dynamic>{};
    final token = data['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await _prefs.setString(_tokenKey, token);
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }

    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = _prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    _dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final data = response.data ?? <String, dynamic>{};
      return UserModel.fromJson({
        ...data,
        'token': token,
      });
    } on DioException {
      return null;
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
        // Logout server-side failure should not block local cleanup.
      }
    }

    await _prefs.remove(_tokenKey);
    _dio.options.headers.remove('Authorization');
  }
}

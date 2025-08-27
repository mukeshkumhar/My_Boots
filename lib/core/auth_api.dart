// lib/features/auth/auth_api.dart
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'token_store.dart';
import 'api_error.dart';

class AuthApi {
  final _dio = ApiClient().dio;

  // Login api
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/user/login',
        data: {'email': email, 'password': password},
      );
      final data =
          (res.data is Map<String, dynamic>)
              ? res.data as Map<String, dynamic>
              : <String, dynamic>{};

      // Accept both shapes:
      final tokensNode = (data['tokens'] is Map) ? data['tokens'] as Map : null;
      final access = (data['accessToken'] ?? tokensNode?['accessToken']);
      final refresh = (data['refreshToken'] ?? tokensNode?['refreshToken']);

      if (access is String && refresh is String) {
        await TokenStore.saveTokens(access, refresh);
        print("Token save $access");
      } else {
        throw ApiError(
          'Server did not return access/refresh tokens',
          res.statusCode,
        );
      }

      final userRaw = data['user'];
      if (userRaw is Map) {
        return Map<String, dynamic>.from(userRaw);
      }
      throw ApiError('Server did not return user object', res.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg =
          e.response?.data is Map && (e.response!.data['error'] != null)
              ? e.response!.data['error'].toString()
              : (e.message ?? 'Login failed');
      throw ApiError(msg, status);
    }
  }

  // register api

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String contact,
  }) async {
    try {
      final res = await _dio.post(
        '/user/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'contact': int.tryParse(contact),
        },
      );
      final data =
          (res.data is Map<String, dynamic>)
              ? res.data as Map<String, dynamic>
              : <String, dynamic>{};
      final tokensNode = (data['tokens'] is Map) ? data['tokens'] as Map : null;
      final access = (data['accessToken'] ?? tokensNode?['accessToken']);
      final refresh = (data['refreshToken'] ?? tokensNode?['refreshToken']);

      if (access is String && refresh is String) {
        await TokenStore.saveTokens(access, refresh);
        print("Token save $access");
      } else {
        throw ApiError(
          'Server did not return access/refresh tokens',
          res.statusCode,
        );
      }
      final userRaw = data['user'];
      if (userRaw is Map) {
        return Map<String, dynamic>.from(userRaw);
      }
      throw ApiError('Server did not return user object', res.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg =
          e.response?.data is Map && (e.response!.data['error'] != null)
              ? e.response!.data['error'].toString()
              : (e.message ?? 'Register failed');
      throw ApiError(msg, status);
    }
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/user/home');
    return Map<String, dynamic>.from(res.data['user']);
  }

  Future<void> logout() async {
    final refresh = await TokenStore.refreshToken;
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refresh});
    } finally {
      await TokenStore.clear();
    }
  }
}

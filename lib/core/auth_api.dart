// lib/features/auth/auth_api.dart
import 'package:dio/dio.dart';
import 'package:my_boots/models/liked_item.dart';
import 'package:my_boots/models/products_models.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'token_store.dart';
import 'api_error.dart';

class AuthApi {
  final _dio = ApiClient().dio;

  // Login api
  Future<AppUser> login({
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
      if (userRaw is! Map) {
        throw ApiError('Server did not return user object', res.statusCode);
      }
      return AppUser.fromJson(Map<String, dynamic>.from(userRaw));
      // if (userRaw is Map) {
      //   return Map<String, dynamic>.from(userRaw);
      // }
      // throw ApiError('Server did not return user object', res.statusCode);
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

  Future<AppUser> register({
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
      if (userRaw is! Map) {
        throw ApiError('Server did not return user object', res.statusCode);
      }
      return AppUser.fromJson(Map<String, dynamic>.from(userRaw));
      // if (userRaw is Map) {
      //   return Map<String, dynamic>.from(userRaw);
      // }
      // throw ApiError('Server did not return user object', res.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg =
          e.response?.data is Map && (e.response!.data['error'] != null)
              ? e.response!.data['error'].toString()
              : (e.message ?? 'Register failed');
      throw ApiError(msg, status);
    }
  }

  Future<AppUser> me() async {
    final res = await _dio.get('/user/me');
    final data = res.data;
    if (data is Map && data['user'] is Map) {
      return AppUser.fromJson(Map<String, dynamic>.from(data['user']));
    }
    throw ApiError('Invalid /me response', res.statusCode);
  }

  Future<List<RemoteProduct>> product() async {
    final res = await _dio.get('/user/home');
    final data = res.data;
    // Accept { products:[ ... ] } or a raw list [ ... ]
    print(data);
    List items;
    if (data is Map && data['products'] is List) {
      items = data['products'] as List;
    } else if (data is List) {
      items = data;
    } else {
      throw ApiError('Unexpected /user/home shape', res.statusCode);
    }

    return items
        .whereType<Map>() // ensure each item is a Map
        .map((m) => RemoteProduct.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<String?> addFavorite({
    required String productId,
    required String variantId,
    required int size,
  }) async {
    final res = await _dio.post(
      '/user/liked', // <- adjust if your route is different
      data: {'productId': productId, 'variantId': variantId, 'size': size},
    );

    // Accept { like: { _id: ... } } or { _id: ... } or anything similar
    final data = res.data;
    if (data is Map) {
      if (data['like'] is Map && (data['like']['_id'] != null)) {
        return data['like']['_id'].toString();
      }
      if (data['_id'] != null) return data['_id'].toString();
    }
    return null;
  }

  Future<List<LikedItem>> favorites() async {
    final res = await _dio.get(
      '/user/liked',
    ); // or your actual route, e.g. /user/liked
    final data = res.data;

    // Accept either { likedProduct: [...] } OR raw list [...]
    final list =
        (data is Map && data['likedProduct'] is List)
            ? data['likedProduct'] as List
            : (data is List ? data : <dynamic>[]);

    return list
        .whereType<Map>()
        .map((m) => LikedItem.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  // Remove one like by id
  Future<void> removeFavorite(String likedId) async {
    await _dio.delete(
      '/user/liked',
      data: {'likedId': likedId}, // matches your backend DELETE route body
    );
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

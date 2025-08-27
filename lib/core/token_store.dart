import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

class TokenStore {
  static const _storage = FlutterSecureStorage();
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUser = 'currentUserJson';

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  static Future<String?> get accessToken async => _storage.read(key: _kAccess);
  static Future<String?> get refreshToken async =>
      _storage.read(key: _kRefresh);

  // NEW: persist user
  static Future<void> saveUser(AppUser user) async {
    await _storage.write(key: _kUser, value: jsonEncode(user.toJson()));
  }

  static Future<AppUser?> getUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AppUser.fromJson(map);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUser);
  }
}

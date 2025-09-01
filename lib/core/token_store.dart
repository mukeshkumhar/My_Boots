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

  static int? _jwtExp(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payloadB64 = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(payloadB64)));
      final exp = payload['exp'];
      if (exp is int) return exp;
      if (exp is String) return int.tryParse(exp);
      print("JWT payload expiry: $exp");
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns true if access token exists and is not expired (with small skew).
  static Future<bool> hasValidAccess({
    Duration skew = const Duration(seconds: 30),
  }) async {
    final t = await accessToken;
    if (t == null || t.trim().isEmpty) return false;
    final exp = _jwtExp(t);
    if (exp == null) return true; // if no exp claim, assume valid
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (nowSec + skew.inSeconds) < exp;
  }

  /// Consider session active if access is valid OR at least a refresh token exists.
  /// (No backend call; your Dio interceptor can refresh on first 401.)
  static Future<bool> hasAnySession() async {
    if (await hasValidAccess()) return true;
    final r = await refreshToken;
    return r != null && r.trim().isNotEmpty;
  }
}

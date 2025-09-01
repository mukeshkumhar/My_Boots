// lib/features/auth/auth_controller.dart
import 'package:flutter/foundation.dart';
import 'package:my_boots/core/token_store.dart';
import 'package:my_boots/models/user_model.dart';
import '../../core/api_error.dart';
import 'auth_api.dart';

class AuthController extends ChangeNotifier {
  final _api = AuthApi();
  AppUser? currentUser;
  String? error;
  bool loading = false;

  Future<void> initAndValidate() async {
    try {
      // Load saved user (optional)
      currentUser = await TokenStore.getUser();

      final access = await TokenStore.accessToken;
      final refresh = await TokenStore.refreshToken;

      if (access != null && refresh != null) {
        // Validate token -> /me
        final user = await _api.me();
        currentUser = user;
        await TokenStore.saveUser(user);
      } else {
        currentUser = null;
      }
    } catch (_) {
      currentUser = null;
      await TokenStore.clear();
    } finally {
      // loading = true;
      notifyListeners();
    }
  }

  Future<AppUser> doLogin(String email, String password) async {
    _start();
    try {
      final user = await _api.login(email: email, password: password);
      currentUser = user;
      await TokenStore.saveUser(user);
      _done();
      return user;
    } on ApiError catch (e) {
      _fail(e);
      rethrow;
    } catch (e) {
      _fail(e);
      rethrow;
    }
  }

  Future<AppUser> doRegister(
    String username,
    String email,
    String contact,
    String password,
  ) async {
    _start();
    try {
      final user = await _api.register(
        username: username,
        email: email,
        contact: contact,
        password: password,
      );
      currentUser = user;
      await TokenStore.saveUser(user);
      _done();
      return user;
    } on ApiError catch (e) {
      _fail(e);
      rethrow;
    } catch (e) {
      _fail(e);
      rethrow;
    }
  }

  Future<void> loadMe() async {
    _start();
    try {
      currentUser = await _api.me();
      _done();
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> doLogout() async {
    _start();
    try {
      await _api.logout();
      currentUser = null;
      await TokenStore.clear();
      _done();
    } catch (e) {
      _fail(e);
    }
  }

  void _start() {
    loading = true;
    error = null;
    notifyListeners();
  }

  void _done() {
    loading = false;
    notifyListeners();
  }

  void _fail(Object e) {
    loading = false;
    error = e.toString();
    notifyListeners();
  }

  /// Only loads the cached user from secure storage (no API call).
  Future<void> initFromStorage() async {
    try {
      currentUser = await TokenStore.getUser();
    } catch (_) {
      currentUser = null;
    } finally {
      notifyListeners();
    }
  }
}

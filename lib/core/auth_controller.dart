// lib/features/auth/auth_controller.dart
import 'package:flutter/foundation.dart';
import '../../core/api_error.dart';
import 'auth_api.dart';

class AuthController extends ChangeNotifier {
  final _api = AuthApi();
  Map<String, dynamic>? currentUser;
  String? error;
  bool loading = false;

  Future<Map<String, dynamic>?> doLogin(String email, String password) async {
    _start();
    try {
      final user = await _api.login(email: email, password: password);
      currentUser = user;
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

  Future<Map<String, dynamic>?> doRegister(
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
}

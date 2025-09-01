// lib/splash_screen.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Pages/home.dart';
import '../User/login.dart';
import 'package:provider/provider.dart';
import '../core/auth_controller.dart';
import '../core/constants.dart';
import '../core/token_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    // Simulate a delay for the splash screen
    // final auth = context.read<AuthController>();
    // await auth.initAndValidate();
    // if (!mounted) return;
    // final goHome = auth.currentUser != null;
    //
    // await Future.delayed(const Duration(seconds: 2));
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (_) => goHome ? const HomePage() : const LoginPage(),
    //   ),
    //   (_) => false,
    // );

    final goHome = await _ensureSession(); // 👈 will refresh if needed
    if (!mounted) return;
    if (goHome) {
      // 🔑 Rehydrate controller from cached user so Profile has data immediately
      await context.read<AuthController>().initFromStorage();
    }
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => goHome ? const HomePage() : const LoginPage(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Example splash screen background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset('assets/icons/nike_logo.png'),
            ), // Example: Your app logo
            SizedBox(height: 20),
            Text(
              'My Awesome App',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _ensureSession() async {
  // 1) if access token still valid → good to go
  if (await TokenStore.hasValidAccess()) return true;

  // 2) otherwise try to refresh
  final refresh = await TokenStore.refreshToken;
  if (refresh == null || refresh.trim().isEmpty) return false;

  try {
    // Use a bare Dio (no interceptors) to avoid loops
    final dio = Dio(
      BaseOptions(
        baseUrl: '${Constants.baseUrl}/api',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final resp = await dio.post(
      '/user/refresh',
      data: {'refreshToken': refresh},
    );

    // refresh returns only { accessToken }
    final data = resp.data as Map<String, dynamic>;
    final access = data['accessToken'] as String?;
    final refreshtoken = data['refreshToken'] as String?;
    if (access == null || access.isEmpty) return false;
    if (refreshtoken == null || refreshtoken.isEmpty) return false;

    // Save and then re-check validity before returning true
    await TokenStore.saveTokens(access, refreshtoken);
    final ok = await TokenStore.hasValidAccess();
    if (!ok) {
      await TokenStore.clear();
    }
    return ok;
  } catch (_) {
    // Refresh failed (expired/revoked/invalid)
    await TokenStore.clear();
    return false;
  }
}

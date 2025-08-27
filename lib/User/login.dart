import 'package:flutter/material.dart';
import 'package:my_boots/Pages/home.dart';
import 'package:my_boots/User/signup.dart';
import 'package:provider/provider.dart';

import '../core/auth_controller.dart'; // Or cupertino.dart

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailget = TextEditingController();
  final _passget = TextEditingController();

  @override
  void dispose() {
    _emailget.dispose();
    _passget.dispose();
    super.dispose();
  }

  Future<void> performlogin() async {
    print("Login Clicked");

    if (_emailget.text.isEmpty || _passget.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('email or password cannot be empty')),
      );
      return;
    }
    try {
      final response = await context.read<AuthController>().doLogin(
        _emailget.text.trim(),
        _passget.text,
      );
      print("Login Response: $response");
      // debugPrint("Debug Response: $response");
      print(response?['username'] as String);
      final admin = response?['admin'] as bool;
      if (admin != true) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("You are not user")));
      }
    } catch (e) {
      print("Login Failed: $e");
      final msg = context.read<AuthController>().error ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // title: const Text('Login Page'),
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Text(
                  "Hello Again!",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
                const Text(
                  "Welcome Back You've Been Missed!",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: TextField(
                          controller: _emailget,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your Email",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: _passget,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your Password",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: auth.loading ? null : performlogin,
                  child:
                      auth.loading
                          ? const CircularProgressIndicator()
                          : Container(
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black,
                            ),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                ),
                // SizedBox(height: 20),
                // GestureDetector(
                //   child: Container(
                //     height: 50,
                //     margin: const EdgeInsets.symmetric(horizontal: 60),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(50),
                //       color: Colors.black,
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Center(
                //           child: Image.asset(
                //             'assets/icons/google_icon.png',
                //             width: 24,
                //             height: 24,
                //           ),
                //         ),
                //         const SizedBox(
                //           width: 10,
                //         ), // Space between icon and text
                //         const Text(
                //           // The text was missing from your snippet
                //           "Login with Google", // Or "Sign in with Google"
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Create an Account  ->",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ); // Placeholder, you'll replace this
  }
}

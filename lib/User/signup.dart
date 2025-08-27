import 'package:flutter/material.dart';
import 'package:my_boots/core/auth_controller.dart';
import '../Pages/home.dart';
import 'login.dart'; // Or cupertino.dart
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final bool _loading = false;
  final _usernameget = TextEditingController();
  final _emailget = TextEditingController();
  final _contactget = TextEditingController();
  final _passwordget = TextEditingController();

  Future<void> performregister() async {
    print("Signup Clicked");

    if (_usernameget.text.isEmpty ||
        _emailget.text.isEmpty ||
        _contactget.text.isEmpty ||
        _passwordget.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields required")));
      return;
    }
    try {
      final response = await context.read<AuthController>().doRegister(
        _usernameget.text,
        _emailget.text.trim(),
        _contactget.text,
        _passwordget.text,
      );
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
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
                const Text(
                  "Let's Create Your Account",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          controller: _usernameget,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your Name",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
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
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: TextField(
                          controller: _contactget,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your Contact no",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: TextField(
                          controller: _passwordget,
                          keyboardType: TextInputType.text,
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
                SizedBox(height: 40),
                GestureDetector(
                  onTap: _loading ? null : performregister,
                  child:
                      _loading
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
                                "Signup",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                ),
                SizedBox(height: 20),
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
                //           "Signup with Google", // Or "Sign in with Google"
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
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login if you have an Account  ->",
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

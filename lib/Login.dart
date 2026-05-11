import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Category.dart';
import 'main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Category()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                const SizedBox(height: 10),

                // 🔙 BACK
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 🔥 LOGO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                          children: const [
                            TextSpan(
                              text: 'Uni',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 132, 10, 2)),
                            ),
                            TextSpan(
                              text: 'Sell',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 232, 160, 0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text("x"),
                    const SizedBox(width: 6),
                    Image.asset('assets/images/utmlogo.png', height: 35),
                  ],
                ),

                const SizedBox(height: 40),

                const Text("Welcome",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),

                const Text("to Campus MarketPlace"),

                const SizedBox(height: 40),

                // EMAIL
                _buildField(emailController, "Email", Icons.email),

                // PASSWORD
                _buildField(passwordController, "Password", Icons.lock, true),

                const SizedBox(height: 40),

                // 🔐 LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800020),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Log In",
                            style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint,
      IconData icon, [bool isPassword = false]) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Uni',
                          style: TextStyle(color: Color.fromARGB(255, 132, 10, 2)),
                        ),
                        TextSpan(
                          text: 'Sell',
                          style: TextStyle(color: Color.fromARGB(255, 232, 160, 0)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "x",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    'assets/utmlogo.png',
                    height: 35,
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // Welcome Text
              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "to Campus MarketPlace",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 40),

              // Email Label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.email_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Login with UTMid",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Password Label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),

              // Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.visibility_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Enter your Password",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800020),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
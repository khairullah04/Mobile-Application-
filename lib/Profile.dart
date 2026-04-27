import 'package:flutter/material.dart';
import 'Login.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.person, size: 28),
                ],
              ),

              const SizedBox(height: 20),

              
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        AssetImage('assets/images/khaiprofile.jpg'),
                  ),
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 16),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              
              const Text(
                "Khai",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              
              _buildOption(Icons.person_outline, "Edit Profile"),
              _buildOption(Icons.help_outline, "Help"),

              const SizedBox(height: 20),

              _buildOption(Icons.edit_outlined, "My Posts"),
              _buildOption(Icons.inventory_2_outlined, "My orders"),

              const SizedBox(height: 20),

              _buildOption(Icons.security, "Security"),

              const Spacer(),

              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text("Log out", style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800020),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔧 Reusable option widget
  Widget _buildOption(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
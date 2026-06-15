import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Login.dart';
import 'MyPosts.dart';
import 'EditProfile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<DocumentSnapshot> getUserData() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
  }

  Future<void> openEditProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfile(),
      ),
    );

    if (updated == true) {
      setState(() {});
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const Login(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: user == null
          ? const Center(
              child: Text("User not logged in"),
            )
          : FutureBuilder<DocumentSnapshot>(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>?;

                final name = data?['name'] ?? "User";
                final username = data?['username'] ?? "";
                final email = data?['email'] ?? user.email ?? "";

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (username != "")
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "@$username",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 40),

                      profileButton(
                        icon: Icons.shopping_bag_outlined,
                        title: "My Orders",
                        onTap: () {},
                      ),

                      profileButton(
                        icon: Icons.inventory_2_outlined,
                        title: "My Posts",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyPosts(),
                            ),
                          );
                        },
                      ),

                      profileButton(
                        icon: Icons.edit_outlined,
                        title: "Edit Profile",
                        onTap: openEditProfile,
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF800020),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget profileButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                ),

                const SizedBox(width: 18),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                const Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
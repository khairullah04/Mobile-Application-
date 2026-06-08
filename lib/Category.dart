import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Login.dart';
import 'Profile.dart';
import 'DormList.dart';
import 'AcademicList.dart';
import 'ElectronicsList.dart';
import 'LifestyleList.dart';
import 'MerchList.dart';
import 'FreeGiftList.dart';
import 'ChatList.dart';

class Category extends StatelessWidget {
  const Category({super.key});

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

              // TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.person, size: 28),
                    onSelected: (value) {
                      if (value == 'logout') {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                          (route) => false,
                        );
                      } else if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Profile(),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'profile',
                        child: Text('Profile'),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                  ),

                  // TOP CHAT ICON WITH RED DOT
                  UnreadChatIcon(
                    iconColor: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatList(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // FILTER BAR
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tune),
                    SizedBox(width: 10),
                    Text(
                      "Filter categories...",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CATEGORY GRID
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AcademicList(),
                          ),
                        );
                      },
                      child: const CategoryItem(
                        image: 'assets/images/academic.jpg',
                        title: 'Academic &\nTechnical',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ElectronicsList(),
                          ),
                        );
                      },
                      child: const CategoryItem(
                        image: 'assets/images/gadget.jpg',
                        title: 'Electronics &\nGadgets',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DormList(),
                          ),
                        );
                      },
                      child: const CategoryItem(
                        image: 'assets/images/dorm.jpg',
                        title: 'Dorm\nEssentials',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LifestyleList(),
                          ),
                        );
                      },
                      child: const CategoryItem(
                        image: 'assets/images/lifestyle.jpg',
                        title: 'Lifestyle &\nCampus Life',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MerchList(),
                          ),
                        );
                      },
                      child: const CategoryItem(
                        image: 'assets/images/merch.jpg',
                        title: 'UTM\nMerchandise',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FreeGiftList(),
                          ),
                        );
                      },
                      child: const CategoryItem(
                        image: 'assets/images/free.jpg',
                        title: 'Free / Gift\n"Pass It On"',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF800020),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // HOME
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
            ),

            // WISHLIST
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/wishlist');
              },
              icon: const Icon(
                Icons.favorite_border,
                color: Colors.white70,
                size: 28,
              ),
            ),

            // CREATE POST
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createpost');
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white70,
                size: 32,
              ),
            ),

            // NOTIFICATION
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white70,
                size: 28,
              ),
            ),

            // BOTTOM CHAT ICON WITH RED DOT
            UnreadChatIcon(
              iconColor: Colors.white70,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// CATEGORY ITEM WIDGET
class CategoryItem extends StatelessWidget {
  final String image;
  final String title;

  const CategoryItem({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            image,
            height: 90,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

// REUSABLE CHAT ICON WITH RED DOT
class UnreadChatIcon extends StatelessWidget {
  final Color iconColor;
  final VoidCallback onPressed;

  const UnreadChatIcon({
    super.key,
    required this.iconColor,
    required this.onPressed,
  });

  String safeEmailKey(String email) {
    return email.replaceAll('.', '_dot_').replaceAll('@', '_at_');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.chat_bubble_outline,
          color: iconColor,
          size: 28,
        ),
      );
    }

    final currentUserKey = safeEmailKey(user.email!);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: user.email)
          .snapshots(),
      builder: (context, snapshot) {
        int totalUnread = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            final unreadCounts = Map<String, dynamic>.from(
              data['unreadCounts'] ?? {},
            );

            final countRaw = unreadCounts[currentUserKey] ?? 0;

            final int count = countRaw is int
                ? countRaw
                : int.tryParse(countRaw.toString()) ?? 0;

            totalUnread += count;
          }
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                Icons.chat_bubble_outline,
                color: iconColor,
                size: 28,
              ),
            ),

            if (totalUnread > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
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
import 'PostDetails.dart';
import 'NotificationsPage.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final searchController = TextEditingController();

  String searchText = '';

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

              const SizedBox(height: 10),

              // TOP CHAT NOTIFICATION BANNER
              ChatNotificationBanner(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // FILTER BAR
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),

                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase();
                    });
                  },

                  decoration: const InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Search items...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (searchText.isNotEmpty)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .snapshots(),

                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final results = snapshot.data!.docs.where((doc) {

                        final title =
                            doc['title'].toString().toLowerCase();

                        return title.contains(searchText);

                      }).toList();

                      if (results.isEmpty) {
                        return const Center(
                          child: Text("No items found"),
                        );
                      }

                      return ListView.builder(
                        itemCount: results.length,

                        itemBuilder: (context, index) {

                          final item = results[index];

                          return ListTile(
                            leading: const Icon(Icons.shopping_bag),

                            title: Text(item['title']),

                            subtitle: Text(
                              "RM ${item['price']}",
                            ),

                            onTap: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetails(
                                    postId: item.id,
                                    title: item['title'],
                                    description: item['description'],
                                    price: item['price'],
                                    sellerEmail: item['sellerEmail'],
                                    sellerName:
                                        item['sellerName'] ?? 'Seller',
                                    isOwner: false,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              else

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

            // NOTIFICATION BELL WITH RED DOT
            UnreadBellIcon(
              iconColor: Colors.white70,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                );
              },
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

// SAFE EMAIL KEY
String safeEmailKey(String email) {
  return email.replaceAll('.', '_dot_').replaceAll('@', '_at_');
}

// TOP CHAT NOTIFICATION BANNER
class ChatNotificationBanner extends StatelessWidget {
  final VoidCallback onTap;

  const ChatNotificationBanner({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      return const SizedBox.shrink();
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

        if (totalUnread == 0) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF800020),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    totalUnread == 1
                        ? "You have 1 new message"
                        : "You have $totalUnread new messages",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Text(
                  "Open",
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

// REUSABLE NOTIFICATION BELL WITH RED DOT
class UnreadBellIcon extends StatelessWidget {
  final Color iconColor;
  final VoidCallback onPressed;

  const UnreadBellIcon({
    super.key,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.notifications_none,
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
                Icons.notifications_none,
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
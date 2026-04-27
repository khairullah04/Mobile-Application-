import 'package:flutter/material.dart';
import 'Login.dart';
import 'Profile.dart';
import 'DormList.dart';
import 'Wishlist.dart';

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
                              builder: (context) => const Login()),
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
                  const Icon(Icons.chat_bubble_outline, size: 28),
                ],
              ),

              const SizedBox(height: 15),

              
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

              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                  children: [
                    const CategoryItem(
                      image: 'assets/images/academic.jpg',
                      title: 'Academic &\nTechnical',
                    ),
                    const CategoryItem(
                      image: 'assets/images/gadget.jpg',
                      title: 'Electronics &\nGadgets',
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

                    const CategoryItem(
                      image: 'assets/images/lifestyle.jpg',
                      title: 'Lifestyle &\nCampus Life',
                    ),
                    const CategoryItem(
                      image: 'assets/images/merch.jpg',
                      title: 'UTM\nMerchandise',
                    ),
                    const CategoryItem(
                      image: 'assets/images/free.jpg',
                      title: 'Free / Gift\n"Pass It On"',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      
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
            const Icon(Icons.home, color: Colors.white, size: 30),

            
            IconButton(
              icon: const Icon(Icons.favorite_border,
                  color: Colors.white70, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Wishlist(),
                  ),
                );
              },
            ),

            const Icon(Icons.add_circle_outline,
                color: Colors.white70, size: 32),
            const Icon(Icons.notifications_none,
                color: Colors.white70, size: 28),
            const Icon(Icons.chat_bubble_outline,
                color: Colors.white70, size: 28),
          ],
        ),
      ),
    );
  }
}

// 📦 CATEGORY ITEM WIDGET
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
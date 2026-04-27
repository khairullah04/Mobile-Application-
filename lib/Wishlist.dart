import 'package:flutter/material.dart';
import 'Category.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "My Wishlist",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              
              Row(
                children: const [
                  Chip(label: Text("All"), backgroundColor: Color(0xFF800020), labelStyle: TextStyle(color: Colors.white)),
                  SizedBox(width: 8),
                  Chip(label: Text("Book")),
                  SizedBox(width: 8),
                  Chip(label: Text("Fridge")),
                  SizedBox(width: 8),
                  Chip(label: Text("PC")),
                ],
              ),

              const SizedBox(height: 20),

              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/fridge.jpg',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Mini Fridge",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.red, size: 16),
                      Text(" 5"),
                    ],
                  ),
                  const Text(
                    "RM350",
                    style: TextStyle(color: Color(0xFF800020)),
                  ),
                ],
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
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white70),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Category()),
                );
              },
            ),
            const Icon(Icons.favorite, color: Colors.white, size: 30), // ACTIVE
            const Icon(Icons.add_circle_outline, color: Colors.white70),
            const Icon(Icons.notifications_none, color: Colors.white70),
            const Icon(Icons.chat_bubble_outline, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
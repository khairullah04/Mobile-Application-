import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'PostDetails.dart';

class DormList extends StatelessWidget {
  const DormList({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Dorm Essentials",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('category', isEqualTo: 'Dorm Essentials')
            .snapshots(),

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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No data found"),
            );
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                "No items yet",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final doc = posts[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'Available';
              final isSold = status == 'Sold';

              return GestureDetector(
                onTap: () {
                  final isOwner =
                      currentUser?.email == data['sellerEmail'];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetails(
                        postId: doc.id,
                        title: data['title'] ?? '',
                        description: data['description'] ?? '',
                        price: data['price'] ?? '',
                        sellerEmail: data['sellerEmail'] ?? '',
                        sellerName: data['sellerName'] ?? 'Seller',
                        isOwner: isOwner,
                      ),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 50,
                            ),
                          ),

                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSold ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? '',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSold ? Colors.grey : Colors.black,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              "RM ${data['price'] ?? ''}",
                              style: TextStyle(
                                color: isSold
                                    ? Colors.grey
                                    : const Color(0xFF800020),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              data['type'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),

                            if (isSold)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "This item has been sold",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
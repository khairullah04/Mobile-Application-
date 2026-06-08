import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'PostDetails.dart';

class MyPosts extends StatelessWidget {
  const MyPosts({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          "My Posts",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: user == null
          ? const Center(
              child: Text("User not logged in"),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('sellerEmail', isEqualTo: user.email)
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
                      "No posts yet",
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
                              isOwner: true,
                            ),
                          ),
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: 40,
                                  ),
                                ),

                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSold ? Colors.red : Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? '',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isSold ? Colors.grey : Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "RM ${data['price'] ?? ''}",
                                    style: TextStyle(
                                      color: isSold
                                          ? Colors.grey
                                          : const Color(0xFF800020),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    data['type'] ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),

                                  if (isSold)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
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
import 'package:flutter/material.dart';
import 'NotificationsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Category.dart';
import 'PostDetails.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  Future<Map<String, dynamic>?> getPostData(String postId) async {
    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();

    if (!postDoc.exists) return null;

    return postDoc.data();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF800020),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Wishlist",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: user == null
          ? const Center(
              child: Text("User not logged in"),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('wishlist')
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

                final items = snapshot.data!.docs;

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      "No items in wishlist yet",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final wishlistDoc = items[index];
                    final wishlistData =
                        wishlistDoc.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: getPostData(wishlistDoc.id),
                      builder: (context, postSnapshot) {
                        if (postSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final postData = postSnapshot.data;

                        if (postData == null) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),

                                const SizedBox(width: 12),

                                const Expanded(
                                  child: Text(
                                    "This post is no longer available",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('wishlist')
                                        .doc(wishlistDoc.id)
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                          );
                        }

                        final title = postData['title'] ??
                            wishlistData['title'] ??
                            '';

                        final description = postData['description'] ??
                            wishlistData['description'] ??
                            '';

                        final price = postData['price'] ??
                            wishlistData['price'] ??
                            '';

                        final sellerEmail = postData['sellerEmail'] ??
                            wishlistData['sellerEmail'] ??
                            '';

                        final sellerName = postData['sellerName'] ??
                            wishlistData['sellerName'] ??
                            'Seller';

                        final status = postData['status'] ?? 'Available';
                        final isSold = status == 'Sold';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostDetails(
                                  postId: wishlistDoc.id,
                                  title: title,
                                  description: description,
                                  price: price,
                                  sellerEmail: sellerEmail,
                                  sellerName: sellerName,
                                  isOwner: false,
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
                                          color: isSold
                                              ? Colors.red
                                              : Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isSold
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      Text(
                                        "RM $price",
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
                                        sellerName,
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

                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('wishlist')
                                        .doc(wishlistDoc.id)
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
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
              icon: const Icon(
                Icons.home,
                color: Colors.white70,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Category(),
                  ),
                );
              },
            ),

            const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 30,
            ),

            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white70,
                size: 32,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/createpost');
              },
            ),

            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white70,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                );
              },
            ),

            const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white70,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
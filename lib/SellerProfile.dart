import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'PostDetails.dart';

class SellerProfile extends StatelessWidget {
  final String sellerUid;
  final String sellerName;
  final String sellerEmail;

  const SellerProfile({
    super.key,
    required this.sellerUid,
    required this.sellerName,
    required this.sellerEmail,
  });

  Future<void> giveRating(BuildContext context, int rating) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    if (currentUser.uid == sellerUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You cannot rate yourself."),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerUid)
        .collection('ratings')
        .doc(currentUser.uid)
        .set({
      'rating': rating,
      'buyerUid': currentUser.uid,
      'buyerEmail': currentUser.email,
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You rated $sellerName $rating stars."),
      ),
    );
  }

  double calculateAverageRating(List<QueryDocumentSnapshot> ratings) {
    if (ratings.isEmpty) return 0.0;

    double total = 0;

    for (var doc in ratings) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['rating'] ?? 0).toDouble();
    }

    return total / ratings.length;
  }

  Widget ratingStars(double rating) {
    int roundedRating = rating.round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < roundedRating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }

  Widget ratingButton(BuildContext context, int rating) {
    return IconButton(
      onPressed: () {
        giveRating(context, rating);
      },
      icon: const Icon(
        Icons.star,
        color: Colors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF800020),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Seller Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFF800020),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    sellerName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(sellerUid)
                        .collection('ratings')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final ratings = snapshot.data!.docs;
                      final average = calculateAverageRating(ratings);

                      return Column(
                        children: [
                          ratingStars(average),

                          const SizedBox(height: 6),

                          Text(
                            ratings.isEmpty
                                ? "No ratings yet"
                                : "${average.toStringAsFixed(1)} / 5.0 • ${ratings.length} rating(s)",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  if (currentUser != null && currentUser.uid != sellerUid)
                    Column(
                      children: [
                        const Text(
                          "Rate this seller",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ratingButton(context, 1),
                            ratingButton(context, 2),
                            ratingButton(context, 3),
                            ratingButton(context, 4),
                            ratingButton(context, 5),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Items by $sellerName",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('sellerUid', isEqualTo: sellerUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No items from this seller yet."),
                  );
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
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
                                  child: const Icon(Icons.image, size: 40),
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
                                      fontSize: 19,
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
                                      fontSize: 17,
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
          ],
        ),
      ),
    );
  }
}
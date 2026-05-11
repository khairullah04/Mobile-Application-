import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostDetails extends StatefulWidget {
  final String postId;
  final String title;
  final String description;
  final String price;
  final String sellerEmail;
  final bool isOwner;

  const PostDetails({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerEmail,
    required this.isOwner,
  });

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkWishlist();
  }

  
  Future checkWishlist() async {

    final user = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('wishlist')
        .doc(widget.postId)
        .get();

    setState(() {
      isFavorite = doc.exists;
    });
  }

  
  Future toggleWishlist() async {

    final user = FirebaseAuth.instance.currentUser;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('wishlist')
        .doc(widget.postId);

    if (isFavorite) {

      await ref.delete();

      setState(() {
        isFavorite = false;
      });

    } else {

      await ref.set({
        'postId': widget.postId,
        'title': widget.title,
        'description': widget.description,
        'price': widget.price,
        'sellerEmail': widget.sellerEmail,
        'timestamp': Timestamp.now(),
      });

      setState(() {
        isFavorite = true;
      });
    }
  }

  
  Future deletePost() async {

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [

            
            Container(
              height: 320,
              color: Colors.grey[300],

              child: Stack(
                children: [

                  const Center(
                    child: Icon(
                      Icons.image,
                      size: 100,
                    ),
                  ),

                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [

                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        
                        if (!widget.isOwner)
                          IconButton(
                            onPressed: toggleWishlist,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.pink
                                  : Colors.black,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const Spacer(),

                    
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            const Text("Total Price"),

                            Text(
                              "RM ${widget.price}",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        
                        widget.isOwner
                            ? ElevatedButton(
                                onPressed: deletePost,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30),
                                  ),
                                ),

                                child: const Text(
                                  "Delete Post",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )

                        
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 16,
                                ),

                                decoration: BoxDecoration(
                                  color: const Color(0xFF800020),
                                  borderRadius:
                                      BorderRadius.circular(30),
                                ),

                                child: const Text(
                                  "Contact Seller",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
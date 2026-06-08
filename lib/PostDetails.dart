import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatRoom.dart';
import 'SellerProfile.dart';

class PostDetails extends StatefulWidget {
  final String postId;
  final String title;
  final String description;
  final String price;
  final String sellerEmail;
  final String sellerName;
  final bool isOwner;

  const PostDetails({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerEmail,
    required this.sellerName,
    required this.isOwner,
  });

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  bool isFavorite = false;
  String postStatus = "Available";
  String sellerUid = "";

  String safeEmailKey(String email) {
    return email.replaceAll('.', '_dot_').replaceAll('@', '_at_');
  }

  @override
  void initState() {
    super.initState();
    checkWishlist();
    loadPostData();
  }

  Future<void> loadPostData() async {
    final doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      final data = doc.data();

      setState(() {
        postStatus = data?['status'] ?? 'Available';
        sellerUid = data?['sellerUid'] ?? '';
      });
    }
  }

  Future<void> checkWishlist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(widget.postId)
        .get();

    if (!mounted) return;

    setState(() {
      isFavorite = doc.exists;
    });
  }

  Future<void> toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(widget.postId);

    if (isFavorite) {
      await ref.delete();

      if (!mounted) return;

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
        'sellerName': widget.sellerName,
        'sellerUid': sellerUid,
        'status': postStatus,
        'timestamp': Timestamp.now(),
      });

      if (!mounted) return;

      setState(() {
        isFavorite = true;
      });
    }
  }

  Future<void> markAsSold() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
      'status': 'Sold',
    });

    if (!mounted) return;

    setState(() {
      postStatus = 'Sold';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Post marked as sold."),
      ),
    );
  }

  Future<void> markAsAvailable() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
      'status': 'Available',
    });

    if (!mounted) return;

    setState(() {
      postStatus = 'Available';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Post marked as available."),
      ),
    );
  }

  Future<void> deletePost() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .delete();

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> openChatWithSeller() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.email == null) return;

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final currentUserData = currentUserDoc.data();

    final currentUserName = currentUserData?['name'] ?? currentUser.email;

    final currentUserEmail = currentUser.email!;
    final sellerEmail = widget.sellerEmail;

    final emails = [
      currentUserEmail,
      sellerEmail,
    ];

    emails.sort();

    final chatRoomId = emails.join('_');

    final currentUserKey = safeEmailKey(currentUserEmail);
    final sellerKey = safeEmailKey(sellerEmail);

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatRoomId);

    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'users': emails,
        'userNames': {
          currentUserEmail: currentUserName,
          sellerEmail: widget.sellerName,
        },
        'userUids': {
          currentUserEmail: currentUser.uid,
          sellerEmail: sellerUid,
        },
        'unreadCounts': {
          currentUserKey: 0,
          sellerKey: 0,
        },
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
        'lastSenderEmail': '',
        'createdAt': Timestamp.now(),
      });
    } else {
      final data = chatDoc.data();

      if (data != null && !data.containsKey('unreadCounts')) {
        await chatRef.update({
          'unreadCounts': {
            currentUserKey: 0,
            sellerKey: 0,
          },
        });
      }

      if (data != null && !data.containsKey('userUids')) {
        await chatRef.update({
          'userUids': {
            currentUserEmail: currentUser.uid,
            sellerEmail: sellerUid,
          },
        });
      }
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoom(
          chatRoomId: chatRoomId,
          otherUserEmail: widget.sellerEmail,
          otherUserName: widget.sellerName,
        ),
      ),
    );
  }

  void openSellerProfile() {
    if (sellerUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Seller profile is only available for newer posts.",
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellerProfile(
          sellerUid: sellerUid,
          sellerName: widget.sellerName,
          sellerEmail: widget.sellerEmail,
        ),
      ),
    );
  }

  Widget statusBadge() {
    final bool isSold = postStatus == "Sold";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSold ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        postStatus,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget sellerProfileRow() {
    return InkWell(
      onTap: openSellerProfile,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Seller: ${widget.sellerName}",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: Color(0xFF800020),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSold = postStatus == "Sold";

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

                  Positioned(
                    top: 18,
                    right: 18,
                    child: statusBadge(),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              color: isFavorite ? Colors.pink : Colors.black,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    sellerProfileRow(),

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        isSold ? markAsAvailable : markAsSold,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSold
                                          ? Colors.green
                                          : const Color(0xFF800020),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text(
                                      isSold
                                          ? "Mark Available"
                                          : "Mark as Sold",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  ElevatedButton(
                                    onPressed: deletePost,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Delete Post",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: isSold ? null : openChatWithSeller,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSold
                                      ? Colors.grey
                                      : const Color(0xFF800020),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  isSold ? "Sold" : "Contact Seller",
                                  style: const TextStyle(
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
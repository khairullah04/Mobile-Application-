import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatRoom.dart';
import 'SellerProfile.dart';
import 'EditPost.dart';

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

  String postTitle = "";
  String postDescription = "";
  String postPrice = "";
  String postStatus = "Available";
  String sellerUid = "";
  List<String> postImages = [];

  String safeEmailKey(String email) {
    return email.replaceAll('.', '_dot_').replaceAll('@', '_at_');
  }

  @override
  void initState() {
    super.initState();

    postTitle = widget.title;
    postDescription = widget.description;
    postPrice = widget.price;

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
        postTitle = data?['title'] ?? widget.title;
        postDescription = data?['description'] ?? widget.description;
        postPrice = data?['price'] ?? widget.price;
        postStatus = data?['status'] ?? 'Available';
        sellerUid = data?['sellerUid'] ?? '';
        postImages = List<String>.from(data?['images'] ?? []);
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
        'title': postTitle,
        'description': postDescription,
        'price': postPrice,
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

  Future<void> confirmDeletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text(
            "Are you sure you want to delete this post? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deletePost();
    }
  }

  Future<void> deletePost() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .delete();

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> openEditPost() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPost(
          postId: widget.postId,
        ),
      ),
    );

    if (updated == true) {
      loadPostData();
    }
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

    final itemMessage =
        "I'm interested in this item:\n$postTitle\nRM $postPrice";

    await chatRef.collection('messages').add({
      'senderEmail': currentUserEmail,
      'message': itemMessage,
      'type': 'item_reference',
      'itemId': widget.postId,
      'itemTitle': postTitle,
      'itemPrice': postPrice,
      'timestamp': Timestamp.now(),
    });

    await chatRef.update({
      'lastMessage': itemMessage,
      'lastMessageTime': Timestamp.now(),
      'lastSenderEmail': currentUserEmail,
      'unreadCounts.$sellerKey': FieldValue.increment(1),
    });

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

  Widget sellerMenuButton() {
    if (!widget.isOwner) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.black,
      ),
      onSelected: (value) {
        if (value == 'delete') {
          confirmDeletePost();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                "Delete Post",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
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
                  postImages.isNotEmpty
                      ? PageView.builder(
                          itemCount: postImages.length,
                          itemBuilder: (context, index) {
                            try {
                              final bytes = base64Decode(postImages[index]);
                              return Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.broken_image, size: 80),
                                ),
                              );
                            } catch (_) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 80),
                              );
                            }
                          },
                        )
                      : const Center(
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
                    right: widget.isOwner ? 55 : 18,
                    child: statusBadge(),
                  ),

                  if (widget.isOwner)
                    Positioned(
                      top: 8,
                      right: 5,
                      child: sellerMenuButton(),
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
                            postTitle,
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
                      postDescription,
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
                              "RM $postPrice",
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
                                    onPressed: openEditPost,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF800020),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 35,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Edit Post",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  ElevatedButton(
                                    onPressed:
                                        isSold ? markAsAvailable : markAsSold,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSold
                                          ? Colors.green
                                          : Colors.orange,
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
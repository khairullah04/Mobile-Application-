import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId;
  final String otherUserEmail;
  final String otherUserName;

  const ChatRoom({
    super.key,
    required this.chatRoomId,
    required this.otherUserEmail,
    required this.otherUserName,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController messageController = TextEditingController();

  String safeEmailKey(String email) {
    return email.replaceAll('.', '_dot_').replaceAll('@', '_at_');
  }

  @override
  void initState() {
    super.initState();
    markMessagesAsRead();
  }

  Future<void> markMessagesAsRead() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) return;

    final userKey = safeEmailKey(user.email!);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatRoomId)
        .update({
      'unreadCounts.$userKey': 0,
    });
  }

  Future<void> sendMessage({
    String? customMessage,
    String messageType = "text",
    String? itemId,
    String? itemTitle,
    String? itemPrice,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) return;

    final text = customMessage ?? messageController.text.trim();

    if (text.isEmpty) return;

    if (customMessage == null) {
      messageController.clear();
    }

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatRoomId);

    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) return;

    final chatData = chatDoc.data() as Map<String, dynamic>;

    final users = List<String>.from(chatData['users'] ?? []);

    final receiverEmail = users.firstWhere(
      (email) => email != user.email,
      orElse: () => widget.otherUserEmail,
    );

    final receiverKey = safeEmailKey(receiverEmail);

    await chatRef.collection('messages').add({
      'senderEmail': user.email,
      'message': text,
      'type': messageType,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemPrice': itemPrice,
      'timestamp': Timestamp.now(),
    });

    await chatRef.update({
      'lastMessage': text,
      'lastMessageTime': Timestamp.now(),
      'lastSenderEmail': user.email,
      'unreadCounts.$receiverKey': FieldValue.increment(1),
    });
  }

  Future<void> openItemSelector() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SizedBox(
          height: 420,
          child: Column(
            children: [
              const SizedBox(height: 12),

              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "${widget.otherUserName}'s Listed Items",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('sellerEmail', isEqualTo: widget.otherUserEmail)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No listed items found."),
                      );
                    }

                    final posts = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final data = post.data() as Map<String, dynamic>;

                        final title = data['title'] ?? "Untitled Item";
                        final price = data['price'] ?? "0";
                        final status = data['status'] ?? "Available";

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("RM $price • $status"),
                            trailing: const Icon(
                              Icons.send,
                              color: Color(0xFF800020),
                            ),
                            onTap: () async {
                              Navigator.pop(context);

                              final itemMessage =
                                  "I'm interested in this item:\n$title\nRM $price";

                              await sendMessage(
                                customMessage: itemMessage,
                                messageType: "item_reference",
                                itemId: post.id,
                                itemTitle: title,
                                itemPrice: price,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildMessageBubble({
    required bool isMe,
    required Map<String, dynamic> msgData,
  }) {
    final message = msgData['message'] ?? "";
    final type = msgData['type'] ?? "text";

    if (type == "item_reference") {
      final itemTitle = msgData['itemTitle'] ?? "Item";
      final itemPrice = msgData['itemPrice'] ?? "";

      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF800020) : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Item Reference",
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white.withOpacity(0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: isMe ? Colors.white : const Color(0xFF800020),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemTitle,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "RM $itemPrice",
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF800020) : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF800020),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.otherUserName,
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
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

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text("No messages yet"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final msgData = msg.data() as Map<String, dynamic>;

                    final isMe = msgData['senderEmail'] == currentUser?.email;

                    return buildMessageBubble(
                      isMe: isMe,
                      msgData: msgData,
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF800020),
                    ),
                    onPressed: openItemSelector,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) {
                      sendMessage();
                    },
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor: const Color(0xFF800020),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
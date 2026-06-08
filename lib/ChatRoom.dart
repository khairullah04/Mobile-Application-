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

  Future<void> sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) return;

    final text = messageController.text.trim();

    if (text.isEmpty) return;

    messageController.clear();

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
      'timestamp': Timestamp.now(),
    });

    await chatRef.update({
      'lastMessage': text,
      'lastMessageTime': Timestamp.now(),
      'lastSenderEmail': user.email,
      'unreadCounts.$receiverKey': FieldValue.increment(1),
    });
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

                    final isMe =
                        msgData['senderEmail'] == currentUser?.email;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF800020)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          msgData['message'] ?? "",
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
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
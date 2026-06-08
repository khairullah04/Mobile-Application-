import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatRoom.dart';
import 'Category.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  String safeEmailKey(String email) {
    return email.replaceAll('.', '_dot_').replaceAll('@', '_at_');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF800020),
        centerTitle: true,
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: user == null || user.email == null
          ? const Center(
              child: Text("User not logged in"),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('users', arrayContains: user.email)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
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

                final chats = snapshot.data!.docs;

                if (chats.isEmpty) {
                  return const Center(
                    child: Text(
                      "No chats yet",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final chatData = chat.data() as Map<String, dynamic>;

                    final users = List<String>.from(chatData['users'] ?? []);

                    final userNames = Map<String, dynamic>.from(
                      chatData['userNames'] ?? {},
                    );

                    final otherEmail = users.firstWhere(
                      (email) => email != user.email,
                      orElse: () => "Unknown",
                    );

                    final otherName = userNames[otherEmail] ?? otherEmail;

                    final lastMessage = chatData['lastMessage'] ?? "";

                    final unreadCounts = Map<String, dynamic>.from(
                      chatData['unreadCounts'] ?? {},
                    );

                    final currentUserKey = safeEmailKey(user.email!);

                    final unreadCountRaw = unreadCounts[currentUserKey] ?? 0;

                    final int unreadCount = unreadCountRaw is int
                        ? unreadCountRaw
                        : int.tryParse(unreadCountRaw.toString()) ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF800020),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),

                        title: Text(
                          otherName,
                          style: TextStyle(
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),

                        subtitle: Text(
                          lastMessage == "" ? "No messages yet" : lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),

                        trailing: unreadCount > 0
                            ? CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.red,
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomId: chat.id,
                                otherUserEmail: otherEmail,
                                otherUserName: otherName,
                              ),
                            ),
                          );
                        },
                      ),
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
                Icons.home_outlined,
                color: Colors.white70,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Category(),
                  ),
                );
              },
            ),

            const Icon(
              Icons.favorite_border,
              color: Colors.white70,
              size: 28,
            ),

            const Icon(
              Icons.add_circle_outline,
              color: Colors.white70,
              size: 32,
            ),

            const Icon(
              Icons.notifications_none,
              color: Colors.white70,
              size: 28,
            ),

            const Icon(
              Icons.chat_bubble,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
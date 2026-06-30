import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ChatRoom.dart';
import 'ChatList.dart';
import 'Category.dart';

// NOTIFICATIONS PAGE
//
// Built on top of the existing `chats` collection (same data the bell's
// red-dot badge already reads from `unreadCounts`). Each chat with an
// unread message becomes a notification entry. Opening a notification
// pushes the matching ChatRoom, which already resets `unreadCounts` for
// the current user, so the notification clears itself automatically.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String safeEmailKey(String email) {
    return email.replaceAll('.', '_dot_').replaceAll('@', '_at_');
  }

  String timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final diff = DateTime.now().difference(timestamp.toDate());

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF800020),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
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

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _EmptyState();
                }

                final currentUserKey = safeEmailKey(user.email!);

                final docs = snapshot.data!.docs.toList();

                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aTime = aData['lastMessageTime'];
                  final bTime = bData['lastMessageTime'];

                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }

                  return 0;
                });

                if (docs.isEmpty) {
                  return _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final users = List<String>.from(data['users'] ?? []);
                    final userNames = Map<String, dynamic>.from(
                      data['userNames'] ?? {},
                    );

                    final otherEmail = users.firstWhere(
                      (email) => email != user.email,
                      orElse: () => "Unknown",
                    );

                    final otherName = userNames[otherEmail] ?? otherEmail;

                    final lastMessage = (data['lastMessage'] ?? '').toString();

                    final unreadCounts = Map<String, dynamic>.from(
                      data['unreadCounts'] ?? {},
                    );

                    final unreadRaw = unreadCounts[currentUserKey] ?? 0;
                    final int unreadCount = unreadRaw is int
                        ? unreadRaw
                        : int.tryParse(unreadRaw.toString()) ?? 0;

                    final bool hasUnread = unreadCount > 0;

                    final lastMessageTime =
                        data['lastMessageTime'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: hasUnread ? const Color(0xFFFBEAEE) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: hasUnread
                              ? const Color(0xFF800020)
                              : Colors.grey[400],
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          hasUnread
                              ? "New message from $otherName"
                              : otherName,
                          style: TextStyle(
                            fontWeight:
                                hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage.isEmpty ? "No messages yet" : lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              timeAgo(lastMessageTime),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (hasUnread) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomId: doc.id,
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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Category(),
                  ),
                );
              },
              icon: const Icon(
                Icons.home_outlined,
                color: Colors.white70,
                size: 30,
              ),
            ),

            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/wishlist');
              },
              icon: const Icon(
                Icons.favorite_border,
                color: Colors.white70,
                size: 28,
              ),
            ),

            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createpost');
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white70,
                size: 32,
              ),
            ),

            // CURRENT PAGE - BELL STAYS HIGHLIGHTED, NOT TAPPABLE
            const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 28,
            ),

            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatList(),
                  ),
                );
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white70,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EMPTY STATE WHEN THERE ARE NO NOTIFICATIONS
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            "No notifications yet",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

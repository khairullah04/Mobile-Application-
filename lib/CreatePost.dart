import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String selectedCategory = "Dorm Essentials";
  String selectedType = "Sell";

  int currentPage = 0;

  final List<XFile?> images = [null, null, null, null];

  final picker = ImagePicker();

  Future pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        images[index] = picked;
      });
    }
  }

  Future publishPost() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (titleController.text.trim().isEmpty ||
        descController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields before publishing."),
        ),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final sellerName = userDoc['name'] ?? 'Seller';

    await FirebaseFirestore.instance.collection('posts').add({
      'title': titleController.text.trim(),
      'description': descController.text.trim(),
      'price': priceController.text.trim(),
      'category': selectedCategory,
      'type': selectedType,
      'sellerUid': user.uid,
      'sellerEmail': user.email,
      'sellerName': sellerName,
      'status': 'Available',
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;

    Navigator.pop(context);
  }

  // Builds an image preview that works on both Web and native (Windows/Android/iOS)
  Widget _buildImagePreview(XFile xfile) {
    if (kIsWeb) {
      // On web, use Image.network with the object URL path
      return Image.network(
        xfile.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 40),
      );
    } else {
      // On native platforms (Windows, Android, iOS), use Image.file
      return Image.file(
        File(xfile.path),
        fit: BoxFit.cover,
      );
    }
  }

  Widget buildImageBox(int index) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: Container(
        width: 120,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(30),
        ),
        child: images[index] == null
            ? const Icon(Icons.add, size: 40)
            : ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: _buildImagePreview(images[index]!),
              ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: currentPage == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Create a Post",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Categories",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: "Dorm Essentials",
                          child: Text("Dorm Essentials"),
                        ),
                        DropdownMenuItem(
                          value: "Electronics & Gadgets",
                          child: Text("Electronics & Gadgets"),
                        ),
                        DropdownMenuItem(
                          value: "Academic & Technical",
                          child: Text("Academic & Technical"),
                        ),
                        DropdownMenuItem(
                          value: "Lifestyle & Campus Life",
                          child: Text("Lifestyle & Campus Life"),
                        ),
                        DropdownMenuItem(
                          value: "Free / Gift",
                          child: Text("Free / Gift"),
                        ),
                        DropdownMenuItem(
                          value: "UTM Merchandise",
                          child: Text("UTM Merchandise"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Type of Announcement",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: "Sell",
                          child: Text("Sell"),
                        ),
                        DropdownMenuItem(
                          value: "Rent",
                          child: Text("Rent"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Photos",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        buildImageBox(0),
                        buildImageBox(1),
                        buildImageBox(2),
                        buildImageBox(3),
                      ],
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentPage = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          currentPage = 0;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Title",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Description",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: descController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Price",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: publishPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Publish",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

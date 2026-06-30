import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;

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

  bool isPublishing = false;

  // Holds the picked file (for preview) alongside its already-compressed
  // bytes (what actually gets uploaded), so we don't recompress on publish.
  final List<XFile?> images = [null, null, null, null];
  final List<Uint8List?> compressedBytes = [null, null, null, null];

  final picker = ImagePicker();

  // Max edge length (px) and JPEG quality used to keep each image's base64
  // string small enough that 4 of them comfortably fit under Firestore's
  // 1MB document limit.
  static const int maxDimension = 800;
  static const int jpegQuality = 60;

  Future pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final rawBytes = await picked.readAsBytes();
    final resized = _compressImage(rawBytes);

    if (resized == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't read that image, try another.")),
      );
      return;
    }

    setState(() {
      images[index] = picked;
      compressedBytes[index] = resized;
    });
  }

  // Decodes, downsizes to maxDimension on the longest side, and re-encodes
  // as JPEG at jpegQuality. Returns null if decoding fails.
  Uint8List? _compressImage(Uint8List rawBytes) {
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) return null;

    img.Image resized = decoded;
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      resized = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: maxDimension)
          : img.copyResize(decoded, height: maxDimension);
    }

    final jpg = img.encodeJpg(resized, quality: jpegQuality);
    return Uint8List.fromList(jpg);
  }

  // Converts each compressed image to a base64 string for storage directly
  // on the Firestore document. No Storage bucket needed.
  List<String> buildBase64Images() {
    final List<String> encoded = [];

    for (final bytes in compressedBytes) {
      if (bytes == null) continue;
      encoded.add(base64Encode(bytes));
    }

    return encoded;
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

    final base64Images = buildBase64Images();

    // Rough guard against exceeding Firestore's 1MB document cap. Base64
    // inflates raw bytes by ~33%; this is a conservative early check rather
    // than the exact limit.
    final totalChars = base64Images.fold<int>(0, (sum, s) => sum + s.length);
    if (totalChars > 700000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Photos are too large even after compression. Try fewer photos.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isPublishing = true;
    });

    try {
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
        // Base64-encoded JPEG strings, stored directly on the document.
        'images': base64Images,
      });

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to publish post: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPublishing = false;
        });
      }
    }
  }

  // Builds an image preview that works on both Web and native (Windows/Android/iOS).
  // Uses the already-compressed bytes so the preview matches what gets uploaded.
  Widget _buildImagePreview(int index) {
    final bytes = compressedBytes[index];
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }

    // Fallback to the raw picked file if compression hasn't completed yet.
    final xfile = images[index]!;
    if (kIsWeb) {
      return Image.network(
        xfile.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 40),
      );
    } else {
      return FutureBuilder<Uint8List>(
        future: xfile.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        },
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
                child: _buildImagePreview(index),
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
                        onPressed: isPublishing ? null : publishPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isPublishing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
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

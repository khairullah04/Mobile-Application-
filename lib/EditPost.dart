import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditPost extends StatefulWidget {
  final String postId;

  const EditPost({
    super.key,
    required this.postId,
  });

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String selectedCategory = "Dorm Essentials";
  String selectedType = "Sell";
  String selectedStatus = "Available";

  bool isLoading = true;
  bool isSaving = false;

  final List<String> categories = [
    "Dorm Essentials",
    "Electronics & Gadgets",
    "Academic & Technical",
    "Lifestyle & Campus Life",
    "Free / Gift",
    "UTM Merchandise",
  ];

  final List<String> types = [
    "Sell",
    "Rent",
  ];

  final List<String> statuses = [
    "Available",
    "Sold",
  ];

  @override
  void initState() {
    super.initState();
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

      titleController.text = data?['title'] ?? '';
      descController.text = data?['description'] ?? '';
      priceController.text = data?['price'] ?? '';

      selectedCategory = data?['category'] ?? "Dorm Essentials";
      selectedType = data?['type'] ?? "Sell";
      selectedStatus = data?['status'] ?? "Available";
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updatePost() async {
    if (titleController.text.trim().isEmpty ||
        descController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
      'title': titleController.text.trim(),
      'description': descController.text.trim(),
      'price': priceController.text.trim(),
      'category': selectedCategory,
      'type': selectedType,
      'status': selectedStatus,
      'updatedAt': Timestamp.now(),
    });

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Post updated successfully."),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(25),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Edit Post",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(
                    label: "Title",
                    controller: titleController,
                  ),

                  const SizedBox(height: 20),

                  buildTextField(
                    label: "Description",
                    controller: descController,
                    maxLines: 5,
                  ),

                  const SizedBox(height: 20),

                  buildTextField(
                    label: "Price",
                    controller: priceController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  buildDropdown(
                    label: "Category",
                    value: selectedCategory,
                    items: categories,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  buildDropdown(
                    label: "Type",
                    value: selectedType,
                    items: types,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  buildDropdown(
                    label: "Status",
                    value: selectedStatus,
                    items: statuses,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : updatePost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
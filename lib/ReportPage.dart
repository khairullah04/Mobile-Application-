import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool isLoading = true;

  List<QueryDocumentSnapshot> posts = [];

  int totalPosts = 0;
  int soldPosts = 0;
  int availablePosts = 0;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("sellerEmail", isEqualTo: user.email)
        .get();

    posts = snapshot.docs;

    totalPosts = posts.length;

    soldPosts = posts.where((e) {
      return (e["status"] ?? "Available") == "Sold";
    }).length;

    availablePosts = totalPosts - soldPosts;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> downloadPDF() async {
    final pdf = pw.Document();

    final user = FirebaseAuth.instance.currentUser;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "UniSell Marketplace Report",
              style: pw.TextStyle(fontSize: 24),
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text("Seller : ${user?.email ?? ""}"),
          pw.Text("Date : ${DateTime.now()}"),

          pw.SizedBox(height: 20),

          pw.Text("Summary",
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold)),

          pw.Bullet(text: "Total Posts : $totalPosts"),
          pw.Bullet(text: "Available Posts : $availablePosts"),
          pw.Bullet(text: "Sold Posts : $soldPosts"),

          pw.SizedBox(height: 20),

          pw.Text(
            "Post Details",
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold),
          ),

          pw.Table.fromTextArray(
            headers: [
              "Title",
              "Category",
              "Price",
              "Status"
            ],
            data: posts.map((e) {
              return [
                e["title"],
                e["category"],
                "RM ${e["price"]}",
                e["status"] ?? "Available",
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> downloadCSV() async {
    List<List<dynamic>> rows = [];

    rows.add([
      "Title",
      "Category",
      "Price",
      "Status"
    ]);

    for (var post in posts) {
      rows.add([
        post["title"],
        post["category"],
        post["price"],
        post["status"] ?? "Available",
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();

    final file = File("${directory.path}/UniSell_Report.csv");

    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "UniSell Marketplace Report",
    );
  }

  Widget reportCard(
      String title,
      String value,
      Color color,
      IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF800020),
        title: const Text(
          "Marketplace Report",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  reportCard(
                    "Total Posts",
                    totalPosts.toString(),
                    Colors.blue,
                    Icons.inventory,
                  ),

                  reportCard(
                    "Available",
                    availablePosts.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),

                  reportCard(
                    "Sold",
                    soldPosts.toString(),
                    Colors.red,
                    Icons.sell,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Download PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF800020),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: downloadPDF,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.table_chart),
                      label: const Text("Download CSV"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: downloadCSV,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
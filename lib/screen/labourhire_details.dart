import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LabourHireDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  const LabourHireDetailsPage({super.key, required this.data, required this.docId});

  @override
  State<LabourHireDetailsPage> createState() => _LabourHireDetailsPageState();
}

class _LabourHireDetailsPageState extends State<LabourHireDetailsPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3;

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('labour_hire')
        .doc(widget.docId)
        .collection('reviews')
        .add({
      'text': _reviewController.text.trim(),
      'rating': _rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _reviewController.clear();
      _rating = 3;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Scaffold(
      appBar: AppBar(
        title: Text("${data['first_name'] ?? ''} ${data['last_name'] ?? ''}"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey[100],
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text("[Labourer Photo Placeholder]", style: TextStyle(color: Colors.black54)),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.engineering, size: 28, color: Colors.blueAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Trade: ${data['skills'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              data['location'] ?? 'Region not specified',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.cake_outlined, color: Colors.orange),
                          const SizedBox(width: 10),
                          Text("Age: ${data['age'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green),
                          const SizedBox(width: 10),
                          Text("Contact: ${data['contact'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if ((data['ticket_file_name'] ?? "").toString().isNotEmpty)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("View Tickets"),
                          onPressed: () async {
                            final url = data['ticket_file_name'];
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text("Further Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Hire Rate Option: ${data['hire_rate_option'] ?? 'N/A'}"),
                      Text("Rates: \$${data['min_rate'] ?? 0} - \$${data['max_rate'] ?? 0}"),
                      const SizedBox(height: 10),
                      const Row(children: [Icon(Icons.check, color: Colors.black), SizedBox(width: 6), Text("Registered and certified")]),
                      const Row(children: [Icon(Icons.check, color: Colors.black), SizedBox(width: 6), Text("Available for project-based contracts")]),
                      const Row(children: [Icon(Icons.check, color: Colors.black), SizedBox(width: 6), Text("Trusted by commercial builders")]),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final contact = data['contact'];
                            final uri = Uri.parse("tel:$contact");
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          icon: const Icon(Icons.call, size: 20),
                          label: const Text("Call Labourer"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Leave a Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Rating: ", style: TextStyle(fontSize: 16)),
                  for (int i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setState(() => _rating = i.toDouble()),
                      icon: Icon(i <= _rating ? Icons.star : Icons.star_border, color: Colors.amber),
                    ),
                ],
              ),
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  hintText: "Write your review...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitReview,
                child: const Text("Submit Review"),
              ),
              const SizedBox(height: 20),
              const Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('labour_hire')
                    .doc(widget.docId)
                    .collection('reviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final reviews = snapshot.data!.docs;
                  if (reviews.isEmpty) return const Text("No reviews yet.");
                  return Column(
                    children: reviews.map((doc) {
                      final r = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: Icon(Icons.person, color: Colors.grey),
                        title: Text(r['text'] ?? ''),
                        subtitle: Row(
                          children: List.generate(5, (i) => Icon(
                            i < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          )),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'wet_plant_hire_details_page.dart';

class WetPlantHireListingPage extends StatelessWidget {
  const WetPlantHireListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wet Plant Hire')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wet_plant_hire')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No listings found.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WetPlantHireDetailsPage(data: data),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.construction, size: 40, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['machine_item'] ?? 'No Title',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['company_name'] ?? 'No Company Name',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['location'] ?? 'No Location',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: Colors.blue),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      data['contact_preference'] ?? 'No Contact Info',
                                      style: const TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
//
// import 'package:flutter/material.dart';
//
// // Global favourites list (basic for now)
// List<Map<String, dynamic>> favouriteAds = [];
//
// class WetPlantHireDetailsPage extends StatelessWidget {
//   final Map<String, dynamic> data;
//
//   const WetPlantHireDetailsPage({super.key, required this.data});
//
//   void _showContactDialog(BuildContext context) {
//     final contact = data['contact_preference'] ?? 'No contact info available';
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Contact Details'),
//         content: Text(contact),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _addToFavourites(BuildContext context) {
//     bool alreadyExists = favouriteAds.any((ad) => ad['id'] == data['id']);
//     if (!alreadyExists) {
//       favouriteAds.add(data);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Added to Favourites!')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Already in Favourites')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(data['machine_item'] ?? 'Details')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // IMAGE OR ICON
//             Container(
//               width: double.infinity,
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(Icons.construction, size: 100, color: Colors.grey),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'For Hire: ${data['machine_item'] ?? ''}',
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.business, size: 20),
//                 const SizedBox(width: 5),
//                 Text(data['company_name'] ?? ''),
//               ],
//             ),
//             const SizedBox(height: 5),
//             Row(
//               children: [
//                 const Icon(Icons.location_on, size: 20),
//                 const SizedBox(width: 5),
//                 Expanded(child: Text(data['location'] ?? '')),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _addToFavourites(context),
//                     child: const Text('Add to Favourites'),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => _showContactDialog(context),
//                     child: const Text('Contact'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Text('Further Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Text('Hire Rate Option: ${data['hire_rate_option'] ?? ''}'),
//             Text('Rates: \$${data['min_rate']} - \$${data['max_rate']}'),
//             const SizedBox(height: 10),
//             const Text('✔ Fuel-efficient and GPS-enabled'),
//             const Text('✔ Available for wet or dry hire'),
//             const Text('✔ Suitable for commercial and residential use'),
//           ],
//         ),
//       ),
//     );
//   }
// }

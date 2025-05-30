//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'lumpsumcontractorhire_details.dart';
//
// class LumpSumContractorListingPage extends StatefulWidget {
//   const LumpSumContractorListingPage({super.key});
//
//   @override
//   State<LumpSumContractorListingPage> createState() => _LumpSumContractorListingPageState();
// }
//
// class _LumpSumContractorListingPageState extends State<LumpSumContractorListingPage> {
//   String? selectedService = 'All';
//   String searchText = '';
//   double? minRateFilter;
//   double? maxRateFilter;
//   bool showMap = false;
//   GoogleMapController? mapController;
//
//   final TextEditingController searchController = TextEditingController();
//   final List<String> serviceOptions = ['All', 'Civil', 'Electrical', 'Plumbing', 'Carpentry', 'Landscaping'];
//   final Map<String, bool> favorites = {};
//
//   void _showRateFilterDialog(BuildContext context) {
//     final minController = TextEditingController(text: minRateFilter?.toString() ?? '');
//     final maxController = TextEditingController(text: maxRateFilter?.toString() ?? '');
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Filter by Hire Rate"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: minController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Min Rate'),
//             ),
//             TextField(
//               controller: maxController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Max Rate'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 minRateFilter = double.tryParse(minController.text);
//                 maxRateFilter = double.tryParse(maxController.text);
//               });
//               Navigator.pop(context);
//             },
//             child: const Text("Apply"),
//           )
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lump Sum Contractors'),
//         actions: [
//           IconButton(
//             icon: Icon(showMap ? Icons.list : Icons.map),
//             onPressed: () => setState(() => showMap = !showMap),
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: searchController,
//                   decoration: const InputDecoration(
//                     hintText: 'Search by location or company name',
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (value) => setState(() => searchText = value.toLowerCase()),
//                 ),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<String>(
//                   value: selectedService,
//                   decoration: const InputDecoration(
//                     labelText: 'Filter by Service',
//                     border: OutlineInputBorder(),
//                   ),
//                   items: serviceOptions.map((service) => DropdownMenuItem(
//                     value: service,
//                     child: Text(service),
//                   )).toList(),
//                   onChanged: (val) => setState(() => selectedService = val),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton.icon(
//                   onPressed: () => _showRateFilterDialog(context),
//                   icon: const Icon(Icons.filter_alt),
//                   label: const Text("Hire Rate"),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('lump_sum_contractors')
//                   .orderBy('created_at', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//                 if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No contractors found.'));
//
//                 final docs = snapshot.data!.docs;
//                 final filteredDocs = docs.where((doc) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final matchesService = selectedService == 'All' ||
//                       (data['service_category']?.toString().toLowerCase() ?? '') == selectedService!.toLowerCase();
//                   final matchesSearch = (data['location']?.toString().toLowerCase().contains(searchText) ?? false) ||
//                       (data['company_name']?.toString().toLowerCase().contains(searchText) ?? false);
//                   final minRate = (data['min_rate'] ?? 0).toDouble();
//                   final maxRate = (data['max_rate'] ?? 0).toDouble();
//                   final matchesPrice = (minRateFilter == null || minRate >= minRateFilter!) &&
//                       (maxRateFilter == null || maxRate <= maxRateFilter!);
//                   return matchesService && matchesSearch && matchesPrice;
//                 }).toList();
//
//                 if (showMap) {
//                   Set<Marker> markers = {};
//
//                   for (var doc in filteredDocs) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final lat = data['lat'];
//                     final lng = data['lng'];
//
//                     if (lat != null && lng != null) {
//                       markers.add(
//                         Marker(
//                           markerId: MarkerId(doc.id),
//                           position: LatLng(lat.toDouble(), lng.toDouble()),
//                           infoWindow: InfoWindow(
//                             title: data['company_name'] ?? '',
//                             snippet: data['location'] ?? '',
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => LumpSumContractorDetailsPage(data: data),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                   }
//
//                   return GoogleMap(
//                     initialCameraPosition: const CameraPosition(target: LatLng(-37.8136, 144.9631), zoom: 10),
//                     markers: markers,
//                     onMapCreated: (controller) => mapController = controller,
//                   );
//                 }
//
//                 return ListView.builder(
//                   itemCount: filteredDocs.length,
//                   itemBuilder: (context, index) {
//                     final doc = filteredDocs[index];
//                     final data = doc.data() as Map<String, dynamic>;
//                     final id = doc.id;
//                     final isFav = favorites[id] ?? false;
//
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => LumpSumContractorDetailsPage(data: data),
//                           ),
//                         );
//                       },
//                       child: Card(
//                         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Row(
//                             children: [
//                               const Icon(Icons.handyman, size: 40, color: Colors.grey),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(data['service_category'] ?? 'Service Name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                                     const SizedBox(height: 4),
//                                     Text(data['company_name'] ?? 'Unnamed Contractor', style: const TextStyle(fontSize: 14)),
//                                     const SizedBox(height: 4),
//                                     Text("Rates: \$${data['min_rate']} - \$${data['max_rate']}"),
//                                     Text("Rate Option: ${data['hire_rate_option'] ?? 'N/A'}"),
//                                     const SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.location_on, size: 14, color: Colors.grey),
//                                         const SizedBox(width: 5),
//                                         Expanded(child: Text(data['location'] ?? 'No Location')),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.phone, size: 14, color: Colors.blue),
//                                         const SizedBox(width: 5),
//                                         Text(data['contact_preference'] ?? 'No Contact'),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
//                                 onPressed: () async {
//                                   if (currentUser == null) return;
//
//                                   setState(() {
//                                     favorites[id] = !isFav;
//                                   });
//
//                                   final favRef = FirebaseFirestore.instance.collection('favorites');
//                                   final docRef = favRef.doc('${currentUser.uid}_$id');
//
//                                   if (!isFav) {
//                                     await docRef.set({
//                                       'userId': currentUser.uid,
//                                       'listingId': id,
//                                       'type': 'lump_sum_contractors',
//                                       ...data,
//                                       'timestamp': FieldValue.serverTimestamp(),
//                                     });
//                                   } else {
//                                     await docRef.delete();
//                                   }
//
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(!isFav ? 'Added to favorites' : 'Removed from favorites'),
//                                       duration: const Duration(seconds: 2),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'lumpsumcontractorhire_details.dart';

class LumpSumContractorListingPage extends StatefulWidget {
  const LumpSumContractorListingPage({super.key});

  @override
  State<LumpSumContractorListingPage> createState() => _LumpSumContractorListingPageState();
}

class _LumpSumContractorListingPageState extends State<LumpSumContractorListingPage> {
  final Map<String, bool> favorites = {};
  bool showMap = false;
  GoogleMapController? mapController;

  String searchText = '';
  double? minRateFilter;
  double? maxRateFilter;
  DateTimeRange? selectedDateRange;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserFavourites();
  }

  Future<void> _loadUserFavourites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favourites')
        .get();

    setState(() {
      for (var doc in snapshot.docs) {
        favorites[doc['machine_id']] = true;
      }
    });
  }

  Future<void> addToFavourites(String adId, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favourites');

    final existing = await favRef.where('machine_id', isEqualTo: adId).get();
    if (existing.docs.isEmpty) {
      data['category'] = 'lump_sum_contractors'; // or appropriate collection name

      await favRef.add({
        'machine_id': adId,
        'ad_data': data,
        'saved_at': FieldValue.serverTimestamp(),
      });

    }
  }

  Future<void> removeFromFavourites(String adId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favourites');

    final snapshot = await favRef.where('machine_id', isEqualTo: adId).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  void _showRateFilterDialog(BuildContext context) {
    final minController = TextEditingController(text: minRateFilter?.toString() ?? '');
    final maxController = TextEditingController(text: maxRateFilter?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filter by Hire Rate"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Min Rate'),
            ),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max Rate'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                minRateFilter = double.tryParse(minController.text);
                maxRateFilter = double.tryParse(maxController.text);
              });
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lump Sum Contractors'),
        actions: [
          IconButton(
            icon: Icon(showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => showMap = !showMap),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (val) => setState(() => searchText = val.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Search by location or company',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showRateFilterDialog(context),
                  icon: const Icon(Icons.filter_alt),
                  label: const Text("Hire Rate"),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lump_sum_contractors')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final location = (data['location'] ?? '').toString().toLowerCase();
            final company = (data['company_name'] ?? '').toString().toLowerCase();
            final matchSearch = location.contains(searchText) || company.contains(searchText);

            final timestamp = (data['created_at'] as Timestamp?)?.toDate();
            final dateMatch = selectedDateRange == null ||
                (timestamp != null &&
                    timestamp.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                    timestamp.isBefore(selectedDateRange!.end.add(const Duration(days: 1))));

            final minRate = double.tryParse((data['min_rate'] ?? '').toString()) ?? 0;
            final maxRate = double.tryParse((data['max_rate'] ?? '').toString()) ?? 0;
            final rateMatch = (minRateFilter == null || minRate >= minRateFilter!) &&
                (maxRateFilter == null || maxRate <= maxRateFilter!);

            return matchSearch && dateMatch && rateMatch;
          }).toList();

          if (showMap) {
            Set<Marker> markers = {};
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final lat = data['lat'];
              final lng = data['lng'];
              if (lat != null && lng != null) {
                markers.add(
                  Marker(
                    markerId: MarkerId(doc.id),
                    position: LatLng(lat.toDouble(), lng.toDouble()),
                    infoWindow: InfoWindow(
                      title: data['company_name'] ?? '',
                      snippet: data['location'] ?? '',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LumpSumContractorDetailsPage(data: data),
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
            return GoogleMap(
              initialCameraPosition: const CameraPosition(target: LatLng(-33.8688, 151.2093), zoom: 10),
              markers: markers,
              onMapCreated: (controller) => mapController = controller,
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;
              final isFav = favorites[id] ?? false;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LumpSumContractorDetailsPage(data: data),
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
                        const Icon(Icons.handyman, size: 40, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['service_category'] ?? 'Service Name',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(data['company_name'] ?? 'No Company Name', style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(data['location'] ?? 'No Location',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text("Rate: \$${data['min_rate']} - \$${data['max_rate']}",
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : null),
                          onPressed: () async {
                            setState(() => favorites[id] = !isFav);
                            if (!isFav) {
                              await addToFavourites(id, data);
                            } else {
                              await removeFromFavourites(id);
                            }
                          },
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

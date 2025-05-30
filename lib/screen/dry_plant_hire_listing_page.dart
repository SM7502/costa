// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dry_plant_hire_details_page.dart';
//
// class DryPlantHireListingPage extends StatefulWidget {
//   const DryPlantHireListingPage({super.key});
//
//   @override
//   State<DryPlantHireListingPage> createState() =>
//       _DryPlantHireListingPageState();
// }
//
// class _DryPlantHireListingPageState extends State<DryPlantHireListingPage> {
//   bool showMap = false;
//   late GoogleMapController mapController;
//
//   String searchQuery = '';
//   double? minRateFilter;
//   double? maxRateFilter;
//   String? selectedMachineType;
//   DateTimeRange? selectedDateRange;
//   final Map<String, bool> favorites = {};
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dry Plant Hire'),
//         actions: [
//           IconButton(
//             icon: Icon(showMap ? Icons.list : Icons.map),
//             onPressed: () => setState(() => showMap = !showMap),
//             tooltip: showMap ? 'Switch to List View' : 'Switch to Map View',
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(130),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 TextField(
//                   onChanged:
//                       (val) => setState(() => searchQuery = val.toLowerCase()),
//                   decoration: InputDecoration(
//                     hintText: 'Search by location or company',
//                     prefixIcon: const Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () async {
//                           final picked = await showDateRangePicker(
//                             context: context,
//                             firstDate: DateTime(2024),
//                             lastDate: DateTime(2026),
//                           );
//                           if (picked != null) {
//                             setState(() => selectedDateRange = picked);
//                           }
//                         },
//                         icon: const Icon(Icons.date_range),
//                         label: const Text("Filter by Date"),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _showRateFilterDialog(context),
//                         icon: const Icon(Icons.filter_alt),
//                         label: const Text("Hire Rate"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream:
//         FirebaseFirestore.instance
//             .collection('dry_plant_hire')
//             .orderBy('created_at', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting)
//             return const Center(child: CircularProgressIndicator());
//           if (snapshot.hasError)
//             return Center(child: Text('Error: ${snapshot.error}'));
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
//             return const Center(child: Text('No listings found.'));
//
//           final docs =
//           snapshot.data!.docs.where((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             final nameMatch = (data['company_name'] ?? '')
//                 .toString()
//                 .toLowerCase()
//                 .contains(searchQuery);
//             final locMatch = (data['location'] ?? '')
//                 .toString()
//                 .toLowerCase()
//                 .contains(searchQuery);
//             final machineMatch =
//                 selectedMachineType == null ||
//                     data['machine_item'] == selectedMachineType;
//             final minRate =
//                 double.tryParse((data['min_rate'] ?? '').toString()) ?? 0;
//             final rateMatch =
//                 (minRateFilter == null || minRate >= minRateFilter!) &&
//                     (maxRateFilter == null || minRate <= maxRateFilter!);
//
//             final timestamp = (data['created_at'] as Timestamp?)?.toDate();
//             final dateMatch =
//                 selectedDateRange == null ||
//                     (timestamp != null &&
//                         timestamp.isAfter(
//                           selectedDateRange!.start.subtract(
//                             const Duration(days: 1),
//                           ),
//                         ) &&
//                         timestamp.isBefore(
//                           selectedDateRange!.end.add(const Duration(days: 1)),
//                         ));
//
//             return (nameMatch || locMatch) &&
//                 machineMatch &&
//                 rateMatch &&
//                 dateMatch;
//           }).toList();
//
//           if (showMap) {
//             return GoogleMap(
//               onMapCreated: (controller) => mapController = controller,
//               initialCameraPosition: const CameraPosition(
//                 target: LatLng(-25.2744, 133.7751),
//                 zoom: 4,
//               ),
//               markers:
//               docs
//                   .map((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 final lat = data['latitude'];
//                 final lng = data['longitude'];
//                 if (lat != null && lng != null) {
//                   return Marker(
//                     markerId: MarkerId(doc.id),
//                     position: LatLng(lat, lng),
//                     infoWindow: InfoWindow(
//                       title: data['machine_item'] ?? 'Machine',
//                       snippet: data['company_name'] ?? '',
//                     ),
//                     onTap: () {
//                       showDialog(
//                         context: context,
//                         builder:
//                             (_) => AlertDialog(
//                           title: Text(
//                             data['machine_item'] ?? 'Details',
//                           ),
//                           content: Text(
//                             'Location: ${data['location'] ?? ''}',
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed:
//                                   () => Navigator.pop(context),
//                               child: const Text('Close'),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return null;
//               })
//                   .whereType<Marker>()
//                   .toSet(),
//             );
//           }
//
//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final doc = docs[index];
//               final data = doc.data() as Map<String, dynamic>;
//               final id = doc.id;
//               final isFav = favorites[id] ?? false;
//
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => DryPlantHireDetailsPage(data: data),
//                     ),
//                   );
//                 },
//                 child: Card(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 70,
//                           height: 70,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.build,
//                             size: 40,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 data['machine_item'] ?? 'No Title',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 data['company_name'] ?? 'No Company Name',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 data['location'] ?? 'No Location',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.phone,
//                                     size: 14,
//                                     color: Colors.blue,
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Expanded(
//                                     child: Text(
//                                       data['contact_preference'] ??
//                                           'No Contact Info',
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             isFav ? Icons.favorite : Icons.favorite_border,
//                             color: isFav ? Colors.red : null,
//                           ),
//                           onPressed: () async {
//                             if (currentUser == null) return;
//
//                             setState(() {
//                               favorites[id] = !isFav;
//                             });
//
//                             final favRef = FirebaseFirestore.instance
//                                 .collection('favorites');
//                             final docRef = favRef.doc('${currentUser.uid}_$id');
//
//                             if (!isFav) {
//                               await docRef.set({
//                                 'userId': currentUser.uid,
//                                 'listingId': id,
//                                 'type': 'dry_plant_hire',
//                                 ...data,
//                                 'timestamp': FieldValue.serverTimestamp(),
//                               });
//                             } else {
//                               await docRef.delete();
//                             }
//
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   !isFav
//                                       ? 'Added to favorites'
//                                       : 'Removed from favorites',
//                                 ),
//                                 duration: const Duration(seconds: 2),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   void _showRateFilterDialog(BuildContext context) {
//     final minController = TextEditingController(
//       text: minRateFilter?.toString() ?? '',
//     );
//     final maxController = TextEditingController(
//       text: maxRateFilter?.toString() ?? '',
//     );
//
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
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
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 minRateFilter = double.tryParse(minController.text);
//                 maxRateFilter = double.tryParse(maxController.text);
//               });
//               Navigator.pop(context);
//             },
//             child: const Text("Apply"),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dry_plant_hire_details_page.dart';

class DryPlantHireListingPage extends StatefulWidget {
  const DryPlantHireListingPage({super.key});

  @override
  State<DryPlantHireListingPage> createState() => _DryPlantHireListingPageState();
}

class _DryPlantHireListingPageState extends State<DryPlantHireListingPage> {
  final Map<String, bool> favorites = {};
  bool showMap = false;
  late GoogleMapController mapController;
  String searchQuery = '';
  double? minRateFilter;
  double? maxRateFilter;
  DateTimeRange? selectedDateRange;

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
      data['category'] = 'dry_plant_hire'; // or appropriate collection name

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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dry Plant Hire'),
        actions: [
          IconButton(
            icon: Icon(showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => showMap = !showMap),
            tooltip: showMap ? 'Switch to List View' : 'Switch to Map View',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by location or company',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2026),
                          );
                          if (picked != null) {
                            setState(() => selectedDateRange = picked);
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text("Filter by Date"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRateFilterDialog(context),
                        icon: const Icon(Icons.filter_alt),
                        label: const Text("Hire Rate"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dry_plant_hire')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final matchCompany = (data['company_name'] ?? '').toString().toLowerCase().contains(searchQuery);
            final matchLocation = (data['location'] ?? '').toString().toLowerCase().contains(searchQuery);

            final timestamp = (data['created_at'] as Timestamp?)?.toDate();
            final dateMatch = selectedDateRange == null ||
                (timestamp != null &&
                    timestamp.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                    timestamp.isBefore(selectedDateRange!.end.add(const Duration(days: 1))));

            final minRate = double.tryParse((data['min_rate'] ?? '').toString()) ?? 0;
            final rateMatch = (minRateFilter == null || minRate >= minRateFilter!) &&
                (maxRateFilter == null || minRate <= maxRateFilter!);

            return (matchCompany || matchLocation) && dateMatch && rateMatch;
          }).toList();

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;
              final isFav = favorites[id] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DryPlantHireDetailsPage(data: data)),
                  ),
                  leading: const Icon(Icons.precision_manufacturing, size: 40),
                  title: Text(data['machine_item'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['company_name'] ?? 'No Company'),
                      Text(data['location'] ?? 'No Location'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                    onPressed: () async {
                      setState(() => favorites[id] = !isFav);
                      if (!isFav) {
                        await addToFavourites(id, data);
                      } else {
                        await removeFromFavourites(id);
                      }
                    },
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

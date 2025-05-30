import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'labourhire_details.dart';

class LabourHireListingPage extends StatefulWidget {
  const LabourHireListingPage({super.key});

  @override
  State<LabourHireListingPage> createState() => _LabourHireListingPageState();
}

class _LabourHireListingPageState extends State<LabourHireListingPage> {
  String searchText = '';
  DateTimeRange? selectedDateRange;
  double? minRateFilter;
  double? maxRateFilter;
  bool showMap = false;

  final Map<String, bool> favorites = {};
  final TextEditingController searchController = TextEditingController();
  GoogleMapController? mapController;

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
      data['category'] = 'labour_hire'; // or appropriate collection name

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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Labour Hire Listings'),
        actions: [
          IconButton(
            icon: Icon(showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => showMap = !showMap),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (val) => setState(() => searchText = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name or location',
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
                            firstDate: DateTime(2024),
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
                )
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('labour_hire')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final fullName = "${data['first_name']} ${data['last_name']}".toLowerCase();
            final locMatch = (data['location'] ?? '').toString().toLowerCase().contains(searchText);
            final nameMatch = fullName.contains(searchText);

            final minRate = double.tryParse(data['min_rate']?.toString() ?? '') ?? 0;
            final rateMatch = (minRateFilter == null || minRate >= minRateFilter!) &&
                (maxRateFilter == null || minRate <= maxRateFilter!);

            final timestamp = (data['created_at'] as Timestamp?)?.toDate();
            final dateMatch = selectedDateRange == null ||
                (timestamp != null &&
                    timestamp.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                    timestamp.isBefore(selectedDateRange!.end.add(const Duration(days: 1))));

            return (locMatch || nameMatch) && rateMatch && dateMatch;
          }).toList();

          if (showMap) {
            return GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: const CameraPosition(target: LatLng(-25.2744, 133.7751), zoom: 4),
              markers: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final lat = data['latitude'];
                final lng = data['longitude'];
                if (lat != null && lng != null) {
                  return Marker(
                    markerId: MarkerId(doc.id),
                    position: LatLng(lat, lng),
                    infoWindow: InfoWindow(
                      title: "${data['first_name']} ${data['last_name']}",
                      snippet: data['location'],
                    ),
                  );
                }
                return null;
              }).whereType<Marker>().toSet(),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isFav = favorites[doc.id] ?? false;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabourHireDetailsPage(data: data, docId: doc.id),
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
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.handyman, size: 40, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${data['first_name']} ${data['last_name']}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text("Trade: ${data['skills'] ?? 'N/A'}"),
                              Text("Rate Option: ${data['hire_rate_option'] ?? 'N/A'}"),
                              Text("Rates: \$${data['min_rate']} - \$${data['max_rate']}", style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      data['location'] ?? 'No Location',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['contact'] ?? 'No Contact Info',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                          onPressed: () async {
                            if (currentUser == null) return;

                            setState(() {
                              favorites[doc.id] = !isFav;
                            });

                            if (!isFav) {
                              await addToFavourites(doc.id, data);
                            } else {
                              await removeFromFavourites(doc.id);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(!isFav ? 'Added to favourites' : 'Removed from favourites'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
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
}

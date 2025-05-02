import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'lumpsumcontractorhire_details.dart';

class LumpSumContractorListingPage extends StatefulWidget {
  const LumpSumContractorListingPage({super.key});

  @override
  State<LumpSumContractorListingPage> createState() => _LumpSumContractorListingPageState();
}

class _LumpSumContractorListingPageState extends State<LumpSumContractorListingPage> {
  String? selectedService;
  String searchText = '';
  double minPrice = 0;
  double maxPrice = 10000;

  final TextEditingController searchController = TextEditingController();
  bool showMap = false;

  GoogleMapController? mapController;
  final List<String> serviceOptions = [
    'All',
    'Civil',
    'Electrical',
    'Plumbing',
    'Carpentry',
    'Landscaping'
  ];

  @override
  void initState() {
    super.initState();
    selectedService = 'All';
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by location or company name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedService,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Service',
                    border: OutlineInputBorder(),
                  ),
                  items: serviceOptions.map((service) => DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  )).toList(),
                  onChanged: (val) {
                    setState(() => selectedService = val);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Min: '),
                    Expanded(
                      child: Slider(
                        value: minPrice,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        label: minPrice.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            minPrice = value;
                          });
                        },
                      ),
                    ),
                    const Text('Max: '),
                    Expanded(
                      child: Slider(
                        value: maxPrice,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        label: maxPrice.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            maxPrice = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lump_sum_contractors')
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
                  return const Center(child: Text('No contractors found.'));
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesService = selectedService == 'All' ||
                      (data['service_category']?.toString().toLowerCase() ?? '') == selectedService!.toLowerCase();
                  final matchesSearch = (data['location']?.toString().toLowerCase().contains(searchText) ?? false) ||
                      (data['company_name']?.toString().toLowerCase().contains(searchText) ?? false);
                  final minRate = (data['min_rate'] ?? 0).toDouble();
                  final maxRate = (data['max_rate'] ?? 0).toDouble();
                  final matchesPrice = minRate >= minPrice && maxRate <= maxPrice;
                  return matchesService && matchesSearch && matchesPrice;
                }).toList();

                if (showMap) {
                  Set<Marker> markers = {};

                  for (var doc in filteredDocs) {
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
                    initialCameraPosition: CameraPosition(
                      target: markers.isNotEmpty
                          ? markers.first.position
                          : const LatLng(-37.8136, 144.9631),
                      zoom: 10,
                    ),
                    markers: markers,
                    onMapCreated: (controller) => mapController = controller,
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['service_category'] ?? 'Service Name',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['company_name'] ?? 'Unnamed Contractor',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text("Rate Option: ${data['hire_rate_option'] ?? 'N/A'}"),
                              Text("Rates: \$${data['min_rate']} - \$${data['max_rate']}"),
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
                                    data['contact_preference'] ?? 'No Contact Info',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
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
          )
        ],
      ),
    );
  }
}

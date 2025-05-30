import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:costa/screen/dry_plant_hire_details_page.dart';
import 'package:costa/screen/labourhirepage.dart';
import 'package:costa/screen/labourhire_details.dart';

import 'package:costa/screen/labourhire_listing.dart';
import 'package:costa/screen/lumpsumcontractorhire_listing.dart';
import 'package:costa/screen/Lumpsumcontractorhire_details.dart';
import 'package:costa/screen/wet_plant_hire_details_page.dart';
import 'package:costa/screen/wet_plant_hire_listing_page.dart';
import 'package:costa/screen/dry_plant_hire_listing_page.dart';
import 'PostServiceStep1.dart';
import 'subscription_page.dart';
import 'CustomerProfile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeContent(),
    PostServiceStep1(),
    NotificationsScreen(),
    CustomerProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Image.asset(
            'assets/images/Costa_civil_logo.png',
            height: 100,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.workspace_premium_rounded, color: Colors.blue),
              tooltip: "Subscribe",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> searchResults = [];
  bool _isLoading = false;
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_current + 1) % 2;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _pauseAutoSlide() => _timer?.cancel();
  void _resumeAutoSlide() => _startAutoSlide();

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      searchResults = [];
    });

    final List<Map<String, dynamic>> results = [];

    for (final collection in [
      'dry_plant_hire',
      'wet_plant_hire',
      'labour_hire',
      'lump_sum_contractors'
    ]) {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('keywords', arrayContains: query.toLowerCase())
          .get();

      results.addAll(snapshot.docs.map((doc) => {
        'collection': collection,
        'data': doc.data(),
        'docId': doc.id,  // 👈 add this line
      }));

    }

    setState(() {
      _isLoading = false;
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search services...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      _performSearch(query);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter a search term")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const FittedBox(child: Text('Search')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (searchResults.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                final data = result['data'];
                final collection = result['collection'];

                return ListTile(
                  title: Text(data['company_name'] ?? data['last_name'] ?? 'No Name'),
                  subtitle: Text(data['location'] ?? 'No Location'),
                  trailing: Chip(
                    label: Text(
                      collection.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  onTap: () {
                    if (collection == 'wet_plant_hire') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => WetPlantHireDetailsPage(data: data)));
                    } else if (collection == 'dry_plant_hire') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DryPlantHireDetailsPage(data: data)));
                    } else if (collection == 'labour_hire') {Navigator.push(context, MaterialPageRoute(builder: (_) => LabourHireDetailsPage(data: data, docId: result['docId'], )));// <-- this must be provided));
                    } else if (collection == 'lump_sum_contractors') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => LumpSumContractorDetailsPage(data: data)));
                    }
                  },
                );
              },
            ),
          const SizedBox(height: 24),
          GestureDetector(
            onTapDown: (_) => _pauseAutoSlide(),
            onTapUp: (_) => _resumeAutoSlide(),
            onTapCancel: () => _resumeAutoSlide(),
            child: Column(
              children: [
                SizedBox(
                  height: screenWidth * 0.45,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _current = index),
                    children: [
                      Image.asset('assets/images/image1.png', fit: BoxFit.cover),
                      Image.asset('assets/images/image5.png', fit: BoxFit.cover),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index ? Colors.blueAccent : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Your Favourite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: screenWidth * 0.35,
            child: userId == null
                ? const Center(child: Text("Log in to view favourites"))
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('favourites')
                  .orderBy('saved_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final favDocs = snapshot.data!.docs;
                if (favDocs.isEmpty) return const Center(child: Text("No favourites yet"));

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favDocs.length,
                  itemBuilder: (context, index) {
                    final data = favDocs[index]['ad_data'] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          final category = data['category'];
                          Widget page;

                          if (category == 'wet_plant_hire') {
                            page = WetPlantHireDetailsPage(data: data);
                          } else if (category == 'dry_plant_hire') {
                            page = DryPlantHireDetailsPage(data: data);
                          } else if (category == 'labour_hire') {
                            page = LabourHireDetailsPage(data: data, docId: favDocs[index].id);
                          } else if (category == 'lump_sum_contractors') {
                            page = LumpSumContractorDetailsPage(data: data);
                          } else {
                            // fallback to a default page or show error
                            return;
                          }

                          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                        },

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            getImageForCategory(data['category']),
                            width: 160,
                            fit: BoxFit.cover,
                          ),

                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('Service Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  buildServiceButton(context, Icons.construction, 'Wet Plant Hire'),
                  buildServiceButton(context, Icons.precision_manufacturing, 'Dry Plant Hire'),
                  buildServiceButton(context, Icons.engineering, 'Labour Hire'),
                  buildServiceButton(context, Icons.assignment_turned_in, 'Lump Sum Contractor'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildServiceButton(BuildContext context, IconData icon, String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      onPressed: () {
        if (label == 'Wet Plant Hire') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WetPlantHireListingPage()));
        } else if (label == 'Dry Plant Hire') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DryPlantHireListingPage()));
        } else if (label == 'Labour Hire') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LabourHireListingPage()));
        } else if (label == 'Lump Sum Contractor') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LumpSumContractorListingPage()));
        }
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
String getImageForCategory(String? category) {
  switch (category) {
    case 'wet_plant_hire':
      return 'assets/images/wet_plant.png';
    case 'dry_plant_hire':
      return 'assets/images/dry_plant.png';
    case 'labour_hire':
      return 'assets/images/labour.png';
    case 'lump_sum_contractors':
      return 'assets/images/contractor.png';
    default:
      return 'assets/images/default_ad_image.png';
  }
}


class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        icon: Icon(Icons.chat),
        label: Text('Open Chat'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Page'));
  }
}

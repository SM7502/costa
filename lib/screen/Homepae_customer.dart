
import 'dart:async';
import 'package:flutter/material.dart';
import 'ad_view_page.dart';
import 'wet_plant_hire_listing_page.dart'; // <--- important import added

// Model class for Ad
class Ad {
  final String imagePath;
  final String title;
  final String company;
  final String location;
  final String description;
  final List<String> features;

  Ad({
    required this.imagePath,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.features,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeContent(),
    YourFavourite(),
    NotificationsScreen(),
    ProfileScreen(),
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
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          title: Image.asset(
            'assets/images/Costa_civil_logo.png',
            height: 100,
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Notifications'),
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
  final List<Ad> ads = [
    Ad(
      imagePath: 'assets/images/image1.png',
      title: 'For Hire: Excavator',
      company: 'EBA Earthworks',
      location: 'Melbourne, VIC',
      description: 'Hydraulic excavator with experienced operator.',
      features: [
        'Fuel-efficient and GPS-enabled',
        'Available for wet or dry hire',
        'Ideal for commercial and residential jobs',
      ],
    ),
    Ad(
      imagePath: 'assets/images/image5.png',
      title: 'For Hire: Loader',
      company: 'BuildPro Equipment',
      location: 'Sydney, NSW',
      description: 'Reliable loader for bulk material handling.',
      features: [
        'High load capacity',
        'Operator included',
        'Flexible rental duration',
      ],
    ),
  ];

  final PageController _pageController = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_current + 1) % ads.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: FittedBox(child: Text('Search')),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTapDown: (_) => _pauseAutoSlide(),
            onTapUp: (_) => _resumeAutoSlide(),
            onTapCancel: () => _resumeAutoSlide(),
            child: Column(
              children: [
                SizedBox(
                  height: screenWidth * 0.45,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _current = index),
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdViewPage(
                                imagePath: ad.imagePath,
                                title: ad.title,
                                company: ad.company,
                                location: ad.location,
                                description: ad.description,
                                features: ad.features,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(ad.imagePath, fit: BoxFit.cover, width: double.infinity),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    ads.length,
                        (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
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
          SizedBox(height: 24),
          Text('Your Favourite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          SizedBox(
            height: screenWidth * 0.35,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                buildImageCard('assets/images/image3.png'),
                buildImageCard('assets/images/image4.png'),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text('Service Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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

  Widget buildImageCard(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(assetPath, width: 160, fit: BoxFit.cover),
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
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      onPressed: () {
        if (label == 'Wet Plant Hire') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WetPlantHireListingPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ServicePage(serviceName: label)),
          );
        }
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class ServicePage extends StatelessWidget {
  final String serviceName;
  ServicePage({required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(serviceName)),
      body: Center(
        child: Text(
          '$serviceName Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Notifications Page'));
  }
}

class YourFavourite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Your Favourite Page'));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Page'));
  }
}

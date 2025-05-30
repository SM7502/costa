import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:costa/screen/labourhirepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Homepage_contractor.dart';
import 'wet_plant_hire_page.dart';
import 'dry_plant_hire_page.dart';
import 'LumpSumContractorPage.dart';

class PostServiceStep1 extends StatefulWidget {
  @override
  _PostServiceStep1State createState() => _PostServiceStep1State();
}

class _PostServiceStep1State extends State<PostServiceStep1> {
  String? selectedService;
  Map<String, String> userSubscriptions = {}; // planName -> status

  final List<String> serviceOptions = [
    'Wet Plant Hire',
    'Dry Plant Hire',
    'Labour Hire',
    'Lump Sum Contractor',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSubscriptions();
  }

  Future<void> _loadUserSubscriptions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final plansSnapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(user.uid)
          .collection('plans')
          .get();

      final Map<String, String> subscriptions = {};
      for (var doc in plansSnapshot.docs) {
        subscriptions[doc.id] = doc['status'] ?? 'unknown';
      }

      setState(() {
        userSubscriptions = subscriptions;
      });
    } catch (e) {
      print('Error loading subscriptions: $e');
    }
  }

  void _handleNext() {
    if (selectedService == 'Wet Plant Hire') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => WetPlantHirePage()));
    } else if (selectedService == 'Dry Plant Hire') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DryPlantHirePage()));
    } else if (selectedService == 'Labour Hire') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LabourHirePage()));
    }  else if (selectedService == 'Lump Sum Contractor') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LumpSumContractorPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation not implemented for "$selectedService" yet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POST A SERVICE'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1 of 4', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 12),
            Text(
              'What service would you like to advertise?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ...serviceOptions.map((option) {
              bool isSubscribed = userSubscriptions[option] == 'active';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: isSubscribed
                      ? () => setState(() => selectedService = option)
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please subscribe to "$option" to access this feature.'))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedService == option
                          ? Colors.blue
                          : isSubscribed
                          ? Colors.white
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.build,
                            color: selectedService == option
                                ? Colors.white
                                : isSubscribed
                                ? Colors.blue
                                : Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: selectedService == option
                                  ? Colors.white
                                  : isSubscribed
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16,
                            color: selectedService == option
                                ? Colors.white
                                : isSubscribed
                                ? Colors.grey
                                : Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              );
            }),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedService != null ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text('NEXT'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

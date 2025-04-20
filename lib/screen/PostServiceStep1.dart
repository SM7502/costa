import 'package:flutter/material.dart';
import 'Homepage_contractor.dart';
import 'wet_plant_hire_page.dart';
import 'dry_plant_hire_page.dart';

class PostServiceStep1 extends StatefulWidget {
  @override
  _PostServiceStep1State createState() => _PostServiceStep1State();
}

class _PostServiceStep1State extends State<PostServiceStep1> {
  String? selectedService;
  final List<String> serviceOptions = [
    'Wet Plant Hire',
    'Dry Plant Hire',
    'Labour Hire',
    'Lump Sum Contractor',
  ];

  void _handleNext() {
    if (selectedService == 'Wet Plant Hire') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WetPlantHirePage()),
      );
    } else if (selectedService == 'Dry Plant Hire') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DryPlantHirePage()),
      );
    } else {
      // Add navigation for other options or show a message
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
            Text(
              'Step 1 of 4',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Text(
              'What service would you like to advertise?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ...serviceOptions.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedService = option;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedService == option ? Colors.blue : Colors.white,
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
                      Icon(Icons.build, color: selectedService == option ? Colors.white : Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedService == option ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: selectedService == option ? Colors.white : Colors.grey),
                    ],
                  ),
                ),
              ),
            )),
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

import 'package:flutter/material.dart';



class CustomerProfile extends StatelessWidget {
  const CustomerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "MY PROFILE",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/man.jpg'), // make sure this exists
            ),
            const SizedBox(height: 20),
            const Text(
              'Aayush',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'ALD',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text('suryabanshi54@gmail.com'),
            const Text('+61 433 411 222'),
            const Text('aldcorporate.com'),
            const SizedBox(height: 20),
            buildButton(context, Icons.edit, "Edit Info"),
            buildButton(context, Icons.picture_as_pdf, "Attachments (PDFs)"),
            buildButton(context, Icons.policy, "View Policy / Legal"),
            buildButton(context, Icons.notifications, "Manage Notifications"),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, IconData icon, String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.blue.shade700, width: 3),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),) // Reduced radius for sharper corners
        ),
        icon: Icon(icon),
        label: Text(text),
        onPressed: () {
          // Add functionality here
        },
      ),
    );
  }
}

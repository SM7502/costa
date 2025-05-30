// lib/screens/customer_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'login_screen.dart';
import 'policy_page.dart';


class CustomerProfile extends StatelessWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view profile.'));
    }
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),           // ← stream instead of one‐shot future
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || !snap.data!.exists) {
              return const Center(child: Text('Profile not found.'));
            }

            final data     = snap.data!.data()!;
            final firstName= data['firstName'] as String? ?? '';
            final lastName = data['lastName']  as String? ?? '';
            final email    = data['email']     as String? ?? '';
            final phone    = data['phone']     as String? ?? '';
            final fullName = '$firstName $lastName'.trim();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'MY PROFILE',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: const AssetImage('assets/images/contractorprofile.jpg'),
                  ),
                  const SizedBox(height: 20),
                  Text(fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(email, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(phone, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),

                  buildButton(context, Icons.edit, 'Edit Info', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfilePage()),
                    );
                  }),
                  buildButton(context, Icons.picture_as_pdf, 'Attachments (PDFs)', () {}),
                  buildButton(context, Icons.policy, 'View Policy / Legal', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PolicyPage()),
                    );
                  }),

                  buildButton(context, Icons.notifications, 'Manage Notifications', () {}),

                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(top: 4),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('LOGOUT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildButton(
      BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black),
        label: Text(text, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.blue.shade700, width: 3),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}


// lib/screens/edit_profile.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey      = GlobalKey<FormState>();
  final _firstNameCtrl= TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();      // ← new
  File? _pickedImage;
  String? _currentPhotoUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc  = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data() ?? {};

    _firstNameCtrl.text   = data['firstName'] ?? '';
    _lastNameCtrl.text    = data['lastName']  ?? '';
    _phoneCtrl.text       = data['phone']     ?? '';   // ← load phone
    _currentPhotoUrl      = data['photoUrl']  as String? ?? user.photoURL;

    setState(() {});
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final user = FirebaseAuth.instance.currentUser!;
    String? photoUrl = _currentPhotoUrl;

    // upload new image if picked
    if (_pickedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_profile_images/${user.uid}.jpg');
      await ref.putFile(_pickedImage!);
      photoUrl = await ref.getDownloadURL();
      await user.updatePhotoURL(photoUrl);
    }

    // update displayName
    final fullName = '${_firstNameCtrl.text} ${_lastNameCtrl.text}'.trim();
    await user.updateDisplayName(fullName);

    // update Firestore doc (including phone)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'firstName': _firstNameCtrl.text,
      'lastName':  _lastNameCtrl.text,
      'phone':     _phoneCtrl.text,      // ← save phone
      'photoUrl':  photoUrl,
    }, SetOptions(merge: true));

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();  // ← dispose it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Info'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_currentPhotoUrl != null
                      ? NetworkImage(_currentPhotoUrl!)
                      : null) as ImageProvider?,
                  child: _pickedImage == null &&
                      _currentPhotoUrl == null
                      ? const Icon(Icons.camera_alt,
                      size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // First Name
              TextFormField(
                controller: _firstNameCtrl,
                decoration:
                const InputDecoration(labelText: 'First Name'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // Last Name
              TextFormField(
                controller: _lastNameCtrl,
                decoration:
                const InputDecoration(labelText: 'Last Name'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // ← NEW Phone Number field
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '0412 345 678',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

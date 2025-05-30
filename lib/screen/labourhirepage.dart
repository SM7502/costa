import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/keyword_generator.dart';

class LabourHirePage extends StatefulWidget {
  const LabourHirePage({super.key});

  @override
  State<LabourHirePage> createState() => _LabourHirePageState();
}

class _LabourHirePageState extends State<LabourHirePage> {
  String hireRateOption = 'Fixed rate';
  File? selectedImage;
  File? coverLetterFile;
  File? ticketFile;
  String? coverLetterFileName;
  String? ticketFileName;

  Position? currentPosition;
  LatLng? selectedLatLng;
  GoogleMapController? mapController;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController minRateController = TextEditingController();
  final TextEditingController maxRateController = TextEditingController();

  List<String> _generateKeywords(String skills, String location) {
    return [
      ...skills.toLowerCase().split(' '),
      ...location.toLowerCase().split(RegExp(r'[ ,]+')),
    ];
  }


  String gender = "Male";
  String whiteRedCard = "No";
  String riwCard = "No";
  String unionMember = "No";

  @override
  void initState() {
    super.initState();
    minRateController.addListener(() {
      if (hireRateOption != 'Rate range') {
        maxRateController.text = minRateController.text;
      }
    });
    locationController.addListener(() => _updateMapFromAddress(locationController.text));
    _getCurrentLocation();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => selectedImage = File(file.path));
  }

  Future<void> _pickCoverLetterFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        coverLetterFile = File(result.files.single.path!);
        coverLetterFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickTicketFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        ticketFile = File(result.files.single.path!);
        ticketFileName = result.files.single.name;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (await Permission.location.request().isGranted) {
      final pos = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      setState(() {
        currentPosition = pos;
        selectedLatLng = LatLng(pos.latitude, pos.longitude);
        locationController.text =
        "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}";
      });
    }
  }

  Future<void> _updateMapFromAddress(String address) async {
    if (address.trim().isEmpty) return;
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() => selectedLatLng = LatLng(locations[0].latitude, locations[0].longitude));
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(selectedLatLng!, 16));
      }
    } catch (_) {}
  }

  Future<void> _submitForm() async {
    final int? age = int.tryParse(ageController.text);
    final int? minRate = int.tryParse(minRateController.text);
    final int? maxRate = int.tryParse(maxRateController.text);

    if (age == null || age < 16 || age > 59) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Age must be between 16 and 59.")));
      return;
    }
    if (hireRateOption == 'Rate range' && minRate == maxRate) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Min and Max rate must be different.")));
      return;
    }
    if (contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contact is required.")));
      return;
    }
    final skill = skillsController.text.trim();
    final location = locationController.text.trim();

    final keywords = _generateKeywords(skill, location);

    try {
      await FirebaseFirestore.instance.collection('labour_hire').add({
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'age': age,
        'gender': gender,
        'skills': skillsController.text.trim(),
        'contact': contactController.text.trim(),
        'hire_rate_option': hireRateOption,
        'min_rate': minRate,
        'max_rate': maxRate,
        'location': locationController.text.trim(),
        'latitude': selectedLatLng?.latitude,
        'longitude': selectedLatLng?.longitude,
        'cover_letter_file_name': coverLetterFileName,
        'ticket_file_name': ticketFileName,
        'white_red_card': whiteRedCard,
        'riw_card': riwCard,
        'union_member': unionMember,
        'created_at': FieldValue.serverTimestamp(),
        'keywords': keywords,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Submission Successful")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e")));
    }
  }

  Widget _formLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 6),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _textField(TextEditingController controller, String hint, {bool isNumber = false, bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _radio(String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: hireRateOption,
      onChanged: (val) {
        setState(() {
          hireRateOption = val!;
          if (hireRateOption != 'Rate range') {
            maxRateController.text = minRateController.text;
          }
        });
      },
      title: Text(value),
    );
  }

  Widget _yesNo(String title, String current, Function(String) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel(title),
        Row(
          children: ['Yes', 'No'].map((e) => Row(
            children: [
              Radio<String>(value: e, groupValue: current, onChanged: (val) => onChange(val!)),
              Text(e),
            ],
          )).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Labour Hire")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formLabel("Upload Image (Optional)"),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: selectedImage != null
                    ? Image.file(selectedImage!, fit: BoxFit.cover)
                    : const Text("Tap to choose image"),
              ),
            ),

            _formLabel("Labour First Name*"),
            _textField(firstNameController, "Enter first name"),

            _formLabel("Labour Last Name*"),
            _textField(lastNameController, "Enter last name"),

            _formLabel("Age"),
            _textField(ageController, "Enter age", isNumber: true),

            _formLabel("Gender"),
            Row(children: [
              Radio<String>(value: 'Male', groupValue: gender, onChanged: (val) => setState(() => gender = val!)),
              const Text('Male'),
              Radio<String>(value: 'Female', groupValue: gender, onChanged: (val) => setState(() => gender = val!)),
              const Text('Female'),
            ]),

            _formLabel("Upload Tickets (Optional)"),
            ElevatedButton.icon(
              onPressed: _pickTicketFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Tickets"),
            ),
            if (ticketFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Selected: \$ticketFileName", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
              ),

            _yesNo("White card / Red card?", whiteRedCard, (val) => setState(() => whiteRedCard = val)),
            _yesNo("RIW card?", riwCard, (val) => setState(() => riwCard = val)),
            _yesNo("Union member?", unionMember, (val) => setState(() => unionMember = val)),

            _formLabel("Skills/Trade"),
            _textField(skillsController, "e.g. Carpenter, Welder"),

            _formLabel("Hire Rate"),
            _radio("Fixed rate"),
            _radio("Negotiable"),
            _radio("Rate range"),

            Row(
              children: [
                Expanded(child: _textField(minRateController, "Min Rate", isNumber: true)),
                const SizedBox(width: 10),
                Expanded(child: _textField(maxRateController, "Max Rate", isNumber: true, enabled: hireRateOption == 'Rate range')),
              ],
            ),

            _formLabel("Contact (Email or Phone)*"),
            _textField(contactController, "Enter contact"),

            _formLabel("Use current location or enter below"),
            ElevatedButton(onPressed: _getCurrentLocation, child: const Text("Use current location")),

            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: selectedLatLng == null
                  ? const Center(child: Text("Map will show location here"))
                  : GoogleMap(
                initialCameraPosition: CameraPosition(target: selectedLatLng!, zoom: 16),
                markers: {Marker(markerId: const MarkerId("selectedLocation"), position: selectedLatLng!)},
                onMapCreated: (controller) => mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),

            _formLabel("Enter location manually"),
            _textField(locationController, "Enter address"),

            _formLabel("Company Cover Letter (Optional)"),
            ElevatedButton.icon(
              onPressed: _pickCoverLetterFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Attach File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[50],
                foregroundColor: Colors.purple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Colors.purple),
                ),
              ),
            ),
            if (coverLetterFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Attached: \$coverLetterFileName", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
              ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Back"))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: _submitForm, child: const Text("Post"))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
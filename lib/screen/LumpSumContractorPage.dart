import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/keyword_generator.dart';

class LumpSumContractorPage extends StatefulWidget {
  const LumpSumContractorPage({super.key});

  @override
  State<LumpSumContractorPage> createState() => _LumpSumContractorPageState();
}

class _LumpSumContractorPageState extends State<LumpSumContractorPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController contactPrefController = TextEditingController();
  final TextEditingController minRateController = TextEditingController();
  final TextEditingController maxRateController = TextEditingController();

  List<String> _generateKeywords(String company, String location, String category) {
    return [
      ...company.toLowerCase().split(' '),
      ...location.toLowerCase().split(RegExp(r'[ ,]+')),
      ...category.toLowerCase().split(' '),
    ];
  }


  String hireRateOption = 'Fixed rate';
  String? selectedServiceCategory;
  final List<String> serviceCategories = [
    "Civil",
    "Electrical",
    "Plumbing",
    "Carpentry",
    "Landscaping"
  ];

  File? capabilityFile;
  String? capabilityFileName;

  Position? currentPosition;
  LatLng? selectedLatLng;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    minRateController.addListener(() {
      if (hireRateOption != 'Rate range') {
        maxRateController.text = minRateController.text;
      }
    });
    locationController.addListener(() {
      _updateMapFromAddress(locationController.text);
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    var status = await Geolocator.requestPermission();
    if (status == LocationPermission.whileInUse || status == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final placemark = placemarks.first;
      String address =
          "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}";

      setState(() {
        currentPosition = position;
        selectedLatLng = LatLng(position.latitude, position.longitude);
        locationController.text = address;
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(selectedLatLng!, 16));
      });
    }
  }

  Future<void> _updateMapFromAddress(String address) async {
    if (address.trim().isEmpty) return;
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final latLng = LatLng(locations[0].latitude, locations[0].longitude);
        setState(() => selectedLatLng = latLng);
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
      }
    } catch (e) {
      debugPrint("Geocoding failed: $e");
    }
  }

  Future<void> _pickCapabilityPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        capabilityFile = File(result.files.single.path!);
        capabilityFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submitForm() async {
    final min = int.tryParse(minRateController.text.trim());
    final max = int.tryParse(maxRateController.text.trim());

    if (min == null || max == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid Min and Max rates.")),
      );
      return;
    }

    if (hireRateOption != 'Rate range' && min != max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Min and Max should be the SAME.")),
      );
      return;
    }

    if (hireRateOption == 'Rate range' && min == max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Min and Max should be DIFFERENT.")),
      );
      return;
    }

    try {
      String? capabilityUrl;
      if (capabilityFile != null) {
        final ref = FirebaseStorage.instance
            .ref('lump_sum_capabilities/${DateTime.now().millisecondsSinceEpoch}_$capabilityFileName');
        await ref.putFile(capabilityFile!);
        capabilityUrl = await ref.getDownloadURL();
      }
      final company = companyNameController.text.trim();
      final location = locationController.text.trim();
      final category = selectedServiceCategory?.trim() ?? '';

      final keywords = _generateKeywords(company, location, category);

      final docRef = FirebaseFirestore.instance.collection('lump_sum_contractors').doc();
      await docRef.set({
        'company_name': company,
        'service_category': category,
        'capability_pdf_url': capabilityUrl ?? '',
        'hire_rate_option': hireRateOption,
        'min_rate': min,
        'max_rate': max,
        'contact_preference': contactPrefController.text.trim(),
        'location': location,
        'lat': selectedLatLng?.latitude ?? 0,
        'lng': selectedLatLng?.longitude ?? 0,
        'created_at': FieldValue.serverTimestamp(),
        'keywords': keywords,
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contractor submitted!")),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Submission failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong.")),
      );
    }
  }

  Widget _formLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 6),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    bool enabled = true,
  }) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lump Sum Contractor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formLabel("Company Name*"),
            _textField(controller: companyNameController, hint: "Enter company name"),
            _formLabel("Service Category"),
            DropdownButtonFormField<String>(
              value: selectedServiceCategory,
              items: serviceCategories.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
              onChanged: (val) => setState(() => selectedServiceCategory = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            _formLabel("Upload Capability Statement (PDF)"),
            ElevatedButton.icon(
              onPressed: _pickCapabilityPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Attach PDF"),
            ),
            if (capabilityFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Attached: $capabilityFileName", style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            _formLabel("Hire Rate"),
            Column(
              children: [
                _radio("Fixed rate"),
                _radio("Negotiable"),
                _radio("Rate range"),
              ],
            ),
            Row(
              children: [
                Expanded(child: _textField(controller: minRateController, hint: "Min Rate", isNumber: true)),
                const SizedBox(width: 10),
                Expanded(
                  child: _textField(
                    controller: maxRateController,
                    hint: "Max Rate",
                    isNumber: true,
                    enabled: hireRateOption == 'Rate range',
                  ),
                ),
              ],
            ),
            _formLabel("Contact Preference"),
            _textField(controller: contactPrefController, hint: "Email or phone"),
            _formLabel("Use current location or type below"),
            ElevatedButton(onPressed: _getCurrentLocation, child: const Text("Use current location")),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: selectedLatLng == null
                  ? const Center(child: Text("Map will show location here"))
                  : GoogleMap(
                initialCameraPosition: CameraPosition(target: selectedLatLng!, zoom: 16),
                markers: {
                  Marker(markerId: const MarkerId("selectedLocation"), position: selectedLatLng!),
                },
                onMapCreated: (controller) => mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            _formLabel("Enter Location"),
            _textField(controller: locationController, hint: "Type address manually"),
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
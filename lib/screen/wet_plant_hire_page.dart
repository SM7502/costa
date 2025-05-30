import 'dart:io';
import 'dart:convert';
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

class WetPlantHirePage extends StatefulWidget {
  const WetPlantHirePage({super.key});

  @override
  State<WetPlantHirePage> createState() => _WetPlantHirePageState();
}

class _WetPlantHirePageState extends State<WetPlantHirePage> {
  String hireRateOption = 'Fixed rate';
  File? selectedImage;
  File? coverLetterFile;
  String? coverLetterFileName;
  Position? currentPosition;
  LatLng? selectedLatLng;
  GoogleMapController? mapController;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactPrefController = TextEditingController();
  final TextEditingController minRateController = TextEditingController();
  final TextEditingController maxRateController = TextEditingController();

  List<String> _generateKeywords(String company, String machine, String location) {
    return [
      ...company.toLowerCase().split(' '),
      ...machine.toLowerCase().split(' '),
      ...location.toLowerCase().split(RegExp(r'[ ,]+')),
    ];
  }


  // Machine Category Structure
  String? selectedCategory;
  String? selectedTypeCategory;
  String? selectedSubCategory;
  String? selectedFurtherInfo;

  Map<String, dynamic> machineData = {};

  List<String> getCategories() => machineData.keys.toList();

  List<String> getTypeCategories() {
    if (selectedCategory == null) return [];
    return (machineData[selectedCategory!] as Map<String, dynamic>).keys.toList();
  }

  List<String> getSubCategories() {
    if (selectedCategory == null || selectedTypeCategory == null) return [];
    return (machineData[selectedCategory!][selectedTypeCategory!] as Map<String, dynamic>).keys.toList();
  }

  List<String> getFurtherInfo() {
    if (selectedCategory == null || selectedTypeCategory == null || selectedSubCategory == null) return [];
    return List<String>.from(machineData[selectedCategory!][selectedTypeCategory!][selectedSubCategory!] as List);
  }

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
    _loadMachineData();
  }

  void _loadMachineData() async {
    final jsonString = await rootBundle.loadString('assets/machine_data.json');
    setState(() {
      machineData = Map<String, dynamic>.from(json.decode(jsonString));
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => selectedImage = File(file.path));
    }
  }

  Future<void> _pickCoverLetterFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        coverLetterFile = File(result.files.single.path!);
        coverLetterFileName = result.files.single.name;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      final pos = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      String address =
          "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}";

      setState(() {
        currentPosition = pos;
        selectedLatLng = LatLng(pos.latitude, pos.longitude);
        locationController.text = address;
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(selectedLatLng!, 16));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is denied.")),
      );
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
    final company = companyNameController.text.trim();
    final location = locationController.text.trim();
    final machine = selectedSubCategory ?? '';

    final keywords = _generateKeywords(company, machine, location);

    try {
      await FirebaseFirestore.instance.collection('wet_plant_hire').add({
        'company_name': companyNameController.text.trim(),
        'category': selectedCategory,
        'type_category': selectedTypeCategory,
        'sub_category': selectedSubCategory,
        'further_info': selectedFurtherInfo,
        'hire_rate_option': hireRateOption,
        'min_rate': min,
        'max_rate': max,
        'contact_preference': contactPrefController.text.trim(),
        'location': locationController.text.trim(),
        'latitude': selectedLatLng?.latitude,
        'longitude': selectedLatLng?.longitude,
        'cover_letter_file_name': coverLetterFileName,
        'created_at': FieldValue.serverTimestamp(),
        'keywords': keywords,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data submitted to Firestore!")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Firestore error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit data.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wet Plant Hire")),
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

            _formLabel("Company Name*"),
            _textField(controller: companyNameController, hint: "Enter company name"),

            _formLabel("Machine Category"),
            _dropdown(getCategories(), selectedCategory, (val) {
              setState(() {
                selectedCategory = val;
                selectedTypeCategory = null;
                selectedSubCategory = null;
                selectedFurtherInfo = null;
              });
            }),

            _formLabel("Machine Type Category"),
            _dropdown(getTypeCategories(), selectedTypeCategory, (val) {
              setState(() {
                selectedTypeCategory = val;
                selectedSubCategory = null;
                selectedFurtherInfo = null;
              });
            }),

            _formLabel("Machine Type Sub-Category"),
            _dropdown(getSubCategories(), selectedSubCategory, (val) {
              setState(() {
                selectedSubCategory = val;
                selectedFurtherInfo = null;
              });
            }),

            _formLabel("Further Information"),
            _dropdown(getFurtherInfo(), selectedFurtherInfo, (val) {
              setState(() => selectedFurtherInfo = val);
            }),

            _formLabel("Hire Rate"),
            Column(children: [_radio("Fixed rate"), _radio("Negotiable"), _radio("Rate range")]),

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

            _formLabel("Contact Preference (Email or Mobile)"),
            _textField(controller: contactPrefController, hint: "Enter contact"),

            const SizedBox(height: 16),
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

            _formLabel("Enter location manually"),
            _textField(controller: locationController, hint: "Enter address"),

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
                child: Text(
                  "Attached: $coverLetterFileName",
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                ),
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

  Widget _dropdown(List<String> items, String? selected, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selected,
      items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(border: OutlineInputBorder()),
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
}

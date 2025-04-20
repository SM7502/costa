// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:file_picker/file_picker.dart';
//
// class DryPlantHirePage extends StatefulWidget {
//   const DryPlantHirePage({super.key});
//
//   @override
//   State<DryPlantHirePage> createState() => _DryPlantHirePageState();
// }
//
// class _DryPlantHirePageState extends State<DryPlantHirePage> {
//   String hireRateOption = 'Fixed rate';
//
//   File? selectedImage;
//   File? coverLetterFile;
//   String? coverLetterFileName;
//
//   Position? currentPosition;
//   LatLng? selectedLatLng;
//   GoogleMapController? mapController;
//
//   final TextEditingController companyNameController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController contactPrefController = TextEditingController();
//   final TextEditingController minRateController = TextEditingController();
//   final TextEditingController maxRateController = TextEditingController();
//
//   String? selectedSubCategory;
//   String? selectedItem;
//
//   final Map<String, List<String>> categoryItems = {
//     "Construction Equipment": [
//       "Excavators",
//       "Dozers",
//       "Backhoe Loaders",
//       "Skid Steer Loaders",
//       "Wheel Loaders"
//     ],
//     "Earthmoving Equipment": [
//       "Graders",
//       "Trenchers",
//       "Dump Trucks",
//       "Compactors"
//     ]
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     minRateController.addListener(() {
//       if (hireRateOption != 'Rate range') {
//         maxRateController.text = minRateController.text;
//       }
//     });
//     locationController.addListener(() {
//       _updateMapFromAddress(locationController.text);
//     });
//     _getCurrentLocation();
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final imageFile = await picker.pickImage(source: ImageSource.gallery);
//     if (imageFile != null) {
//       setState(() => selectedImage = File(imageFile.path));
//     }
//   }
//
//   Future<void> _pickCoverLetterFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'doc', 'docx'],
//     );
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         coverLetterFile = File(result.files.single.path!);
//         coverLetterFileName = result.files.single.name;
//       });
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     var status = await Permission.location.status;
//     if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
//       status = await Permission.location.request();
//     }
//
//     if (status.isGranted) {
//       final position = await Geolocator.getCurrentPosition();
//       final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//       final placemark = placemarks.first;
//       String address =
//           "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}";
//
//       setState(() {
//         currentPosition = position;
//         selectedLatLng = LatLng(position.latitude, position.longitude);
//         locationController.text = address;
//         mapController?.animateCamera(CameraUpdate.newLatLngZoom(selectedLatLng!, 16));
//       });
//     } else if (status.isPermanentlyDenied) {
//       await openAppSettings();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enable location permission from settings.")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Location permission is denied.")),
//       );
//     }
//   }
//
//
//   Future<void> _updateMapFromAddress(String address) async {
//     if (address.trim().isEmpty) return;
//     try {
//       final locations = await locationFromAddress(address);
//       if (locations.isNotEmpty) {
//         final latLng = LatLng(locations[0].latitude, locations[0].longitude);
//         setState(() => selectedLatLng = latLng);
//         mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
//       }
//     } catch (e) {
//       debugPrint("Geocoding failed: $e");
//     }
//   }
//
//   void _submitForm() {
//     final min = int.tryParse(minRateController.text.trim());
//     final max = int.tryParse(maxRateController.text.trim());
//
//     if (min == null || max == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter valid Min and Max rates.")),
//       );
//       return;
//     }
//
//     if (hireRateOption != 'Rate range' && min != max) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Min and Max should be the SAME.")),
//       );
//       return;
//     }
//
//     if (hireRateOption == 'Rate range' && min == max) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Min and Max should be DIFFERENT.")),
//       );
//       return;
//     }
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Form submitted!")),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final subCategories = categoryItems.keys.toList();
//     final items = selectedSubCategory != null ? categoryItems[selectedSubCategory!] ?? [] : [];
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Dry Plant Hire")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _formLabel("Upload Image (Optional)"),
//             GestureDetector(
//               onTap: _pickImage,
//               child: Container(
//                 height: 150,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 alignment: Alignment.center,
//                 child: selectedImage != null
//                     ? Image.file(selectedImage!, fit: BoxFit.cover)
//                     : const Text("Tap to choose image"),
//               ),
//             ),
//
//             _formLabel("Company Name*"),
//             _textField(controller: companyNameController, hint: "Enter company name"),
//
//             _formLabel("Machine Sub-Category"),
//             _dropdown(subCategories, selectedSubCategory, (val) {
//               setState(() {
//                 selectedSubCategory = val;
//                 selectedItem = null;
//               });
//             }),
//
//             _formLabel("Machine Item"),
//             _dropdown(items.cast<String>(), selectedItem, (val) {
//               setState(() => selectedItem = val);
//             }),
//
//             _formLabel("Hire Rate"),
//             Column(
//               children: [
//                 _radio("Fixed rate"),
//                 _radio("Negotiable"),
//                 _radio("Rate range"),
//               ],
//             ),
//
//             Row(
//               children: [
//                 Expanded(child: _textField(controller: minRateController, hint: "Min Rate", isNumber: true)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: _textField(
//                     controller: maxRateController,
//                     hint: "Max Rate",
//                     isNumber: true,
//                     enabled: hireRateOption == 'Rate range',
//                   ),
//                 ),
//               ],
//             ),
//
//             _formLabel("Contact Preference (Email Id or Mobile No)"),
//             _textField(controller: contactPrefController, hint: "Enter email or phone number"),
//
//             const SizedBox(height: 16),
//             _formLabel("Use current location or type below"),
//             ElevatedButton(onPressed: _getCurrentLocation, child: const Text("Use current location")),
//
//             const SizedBox(height: 10),
//             Container(
//               height: 200,
//               decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
//               child: selectedLatLng == null
//                   ? const Center(child: Text("Map will show location here"))
//                   : GoogleMap(
//                 initialCameraPosition: CameraPosition(target: selectedLatLng!, zoom: 16),
//                 markers: {
//                   Marker(markerId: const MarkerId("selectedLocation"), position: selectedLatLng!),
//                 },
//                 onMapCreated: (controller) => mapController = controller,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//               ),
//             ),
//
//             _formLabel("Enter Location"),
//             _textField(controller: locationController, hint: "Type address manually"),
//
//             _formLabel("Company Cover Letter (Optional)"),
//             ElevatedButton.icon(
//               onPressed: _pickCoverLetterFile,
//               icon: const Icon(Icons.attach_file),
//               label: const Text("Attach File"),
//             ),
//             if (coverLetterFileName != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 6),
//                 child: Text("Attached: $coverLetterFileName", style: const TextStyle(fontStyle: FontStyle.italic)),
//               ),
//
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Back"))),
//                 const SizedBox(width: 10),
//                 Expanded(child: ElevatedButton(onPressed: _submitForm, child: const Text("Post"))),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _formLabel(String label) => Padding(
//     padding: const EdgeInsets.only(top: 20, bottom: 6),
//     child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//   );
//
//   Widget _textField({
//     required TextEditingController controller,
//     required String hint,
//     bool isNumber = false,
//     bool enabled = true,
//   }) {
//     return TextField(
//       controller: controller,
//       enabled: enabled,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//       inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
//       decoration: InputDecoration(
//         hintText: hint,
//         border: const OutlineInputBorder(),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       ),
//     );
//   }
//
//   Widget _dropdown(List<String> items, String? selected, ValueChanged<String?> onChanged) {
//     return DropdownButtonFormField<String>(
//       value: selected,
//       items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
//       onChanged: onChanged,
//       decoration: const InputDecoration(border: OutlineInputBorder()),
//     );
//   }
//
//   Widget _radio(String value) {
//     return RadioListTile<String>(
//       value: value,
//       groupValue: hireRateOption,
//       onChanged: (val) {
//         setState(() {
//           hireRateOption = val!;
//           if (hireRateOption != 'Rate range') {
//             maxRateController.text = minRateController.text;
//           }
//         });
//       },
//       title: Text(value),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DryPlantHirePage extends StatefulWidget {
  const DryPlantHirePage({super.key});

  @override
  State<DryPlantHirePage> createState() => _DryPlantHirePageState();
}

class _DryPlantHirePageState extends State<DryPlantHirePage> {
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

  String? selectedSubCategory;
  String? selectedItem;

  final Map<String, List<String>> categoryItems = {
    "Construction Equipment": [
      "Excavators",
      "Dozers",
      "Backhoe Loaders",
      "Skid Steer Loaders",
      "Wheel Loaders"
    ],
    "Earthmoving Equipment": [
      "Graders",
      "Trenchers",
      "Dump Trucks",
      "Compactors"
    ]
  };

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() => selectedImage = File(imageFile.path));
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
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final placemark = placemarks.first;
      String address =
          "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}";

      setState(() {
        currentPosition = position;
        selectedLatLng = LatLng(position.latitude, position.longitude);
        locationController.text = address;
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(selectedLatLng!, 16));
      });
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location permission from settings.")),
      );
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

  // data store with image
  // Future<void> _submitForm() async {
  //   final min = int.tryParse(minRateController.text.trim());
  //   final max = int.tryParse(maxRateController.text.trim());
  //
  //   if (min == null || max == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please enter valid Min and Max rates.")),
  //     );
  //     return;
  //   }
  //
  //   if (hireRateOption != 'Rate range' && min != max) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Min and Max should be the SAME.")),
  //     );
  //     return;
  //   }
  //
  //   if (hireRateOption == 'Rate range' && min == max) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Min and Max should be DIFFERENT.")),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     String? imageUrl;
  //     if (selectedImage != null) {
  //       final imageRef = FirebaseStorage.instance
  //           .ref('dry_plant_hire/images/${DateTime.now().millisecondsSinceEpoch}.jpg');
  //       await imageRef.putFile(selectedImage!);
  //       imageUrl = await imageRef.getDownloadURL();
  //     }
  //
  //     String? coverLetterUrl;
  //     if (coverLetterFile != null) {
  //       final fileRef = FirebaseStorage.instance
  //           .ref('dry_plant_hire/cover_letters/${DateTime.now().millisecondsSinceEpoch}_$coverLetterFileName');
  //       await fileRef.putFile(coverLetterFile!);
  //       coverLetterUrl = await fileRef.getDownloadURL();
  //     }
  //
  //     await FirebaseFirestore.instance.collection('dry_plant_hire').add({
  //       'company_name': companyNameController.text.trim(),
  //       'sub_category': selectedSubCategory,
  //       'machine_item': selectedItem,
  //       'hire_rate_option': hireRateOption,
  //       'min_rate': min,
  //       'max_rate': max,
  //       'contact_preference': contactPrefController.text.trim(),
  //       'location': locationController.text.trim(),
  //       'lat': selectedLatLng?.latitude,
  //       'lng': selectedLatLng?.longitude,
  //       'image_url': imageUrl,
  //       'cover_letter_url': coverLetterUrl,
  //       'created_at': FieldValue.serverTimestamp(),
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Data submitted successfully!")),
  //     );
  //
  //     Navigator.pop(context);
  //   } catch (e) {
  //     debugPrint("Error submitting form: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Something went wrong. Please try again.")),
  //     );
  //   }
  // }

  // data store without image

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
      await FirebaseFirestore.instance.collection('dry_plant_hire').add({
        'company_name': companyNameController.text.trim(),
        'sub_category': selectedSubCategory,
        'machine_item': selectedItem,
        'hire_rate_option': hireRateOption,
        'min_rate': min,
        'max_rate': max,
        'contact_preference': contactPrefController.text.trim(),
        'location': locationController.text.trim(),
        'lat': selectedLatLng?.latitude,
        'lng': selectedLatLng?.longitude,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data submitted successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission failed. Try again.")),
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

  @override
  Widget build(BuildContext context) {
    final subCategories = categoryItems.keys.toList();
    final items = selectedSubCategory != null ? categoryItems[selectedSubCategory!] ?? [] : [];

    return Scaffold(
      appBar: AppBar(title: const Text("Dry Plant Hire")),
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
            _formLabel("Machine Sub-Category"),
            _dropdown(subCategories, selectedSubCategory, (val) {
              setState(() {
                selectedSubCategory = val;
                selectedItem = null;
              });
            }),
            _formLabel("Machine Item"),
            _dropdown(items.cast<String>(), selectedItem, (val) {
              setState(() => selectedItem = val);
            }),
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
            _formLabel("Contact Preference (Email Id or Mobile No)"),
            _textField(controller: contactPrefController, hint: "Enter email or phone number"),
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
            _formLabel("Enter Location"),
            _textField(controller: locationController, hint: "Type address manually"),
            _formLabel("Company Cover Letter (Optional)"),
            ElevatedButton.icon(
              onPressed: _pickCoverLetterFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Attach File"),
            ),
            if (coverLetterFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Attached: $coverLetterFileName", style: const TextStyle(fontStyle: FontStyle.italic)),
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
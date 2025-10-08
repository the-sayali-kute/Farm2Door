// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:forms/customer_home_page/appbar.dart';
// import 'package:forms/customer_home_page/cart/inputs.dart';
// import 'package:forms/final_vars.dart';
// import 'package:forms/functions.dart';
// import 'package:forms/widgets/email_widget.dart';
// import 'package:image_picker/image_picker.dart';

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   void _showImageSourceSelector(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Wrap(
//         children: [
//           ListTile(
//             leading: Icon(Icons.camera_alt),
//             title: Text('Take a photo'),
//             onTap: () {
//               Navigator.maybePop(context);

//               _pickImageFromCamera();
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.photo_library),
//             title: Text('Choose from gallery'),
//             onTap: () {
//               Navigator.maybePop(context);

//               _pickImageFromGallery();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickImageFromGallery() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     loadUserData();
//   }

//   Future<void> loadUserData() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     final doc = await FirebaseFirestore.instance
//         .collection("users")
//         .doc(uid)
//         .get();
//     if (doc.exists) {
//       final data = doc.data();
//       setState(() {
//         fullNameController.text = data?["name"] ?? '';
//         emailController.text = data?["email"] ?? '';
//         phoneController.text = data?["phone"]?.toString() ?? '';
//         addressController.text = data?["address"] ?? '';
//       });
//     }
//   }

//   Future<void> saveChanges() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     try {
//       await FirebaseFirestore.instance.collection("users").doc(uid).update({
//         "name": fullNameController.text,
//         "email": emailController.text,
//         "phone": phoneController.text,
//         "address": addressController.text,
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(successBar("Changes saved successfully"));
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(errorBar("Failed to save changes: $e"));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar(context, title: "Edit Profile"),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: () => _showImageSourceSelector(context),
//                   child: Stack(
//                     alignment: Alignment.bottomRight,
//                     children: [
//                       CircleAvatar(
//                         radius: 55,
//                         backgroundColor: Colors.grey[300],
//                         backgroundImage: _selectedImage != null
//                             ? FileImage(_selectedImage!)
//                             : AssetImage('assets/images/user.png')
//                                   as ImageProvider,
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 4,
//                         child: CircleAvatar(
//                           radius: 16,
//                           backgroundColor: Colors.black,
//                           child: Icon(
//                             Icons.edit,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               FullNameWidget(controller: fullNameController),
//               const SizedBox(height: 24),
//               emailWidget(),
//               const SizedBox(height: 24),
//               PhoneWidget(controller: phoneController),
//               const SizedBox(height: 24),
//               AddressWidget(controller: addressController),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     saveChanges();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   backgroundColor: Colors.green,
//                 ),
//                 child: const Text(
//                   'Save Changes',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                     fontFamily: "Nunito",
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/customer_home_page/cart/inputs.dart';
import 'package:forms/farmer_home_page/areaproximity.dart';
import 'package:forms/reusables/final_vars.dart';
import 'package:forms/reusables/functions.dart';
import 'package:forms/widgets/email_widget.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String userRole = "";
  double deliveryRadius = 1;

  void _showImageSourceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a photo'),
            onTap: () {
              Navigator.maybePop(context);
              _pickImageFromCamera();
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choose from gallery'),
            onTap: () {
              Navigator.maybePop(context);
              _pickImageFromGallery();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        fullNameController.text = data?["name"] ?? '';
        emailController.text = data?["email"] ?? '';
        phoneController.text = data?["phone"]?.toString() ?? '';
        addressController.text = data?["address"] ?? '';
        userRole = data?["role"] ?? '';
        if (userRole.toLowerCase() == "farmer") {
          deliveryRadius = (data?["deliveryRadius"] ?? 1).toDouble();
        }
      });
    }
  }

  Future<void> saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      Map<String, dynamic> updateData = {
        "name": fullNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "address": addressController.text,
      };

      if (userRole.toLowerCase() == "farmer") {
        updateData["deliveryRadius"] = deliveryRadius.toInt();
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update(updateData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(successBar("Changes saved successfully"));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(errorBar("Failed to save changes: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Edit Profile"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceSelector(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : AssetImage('assets/images/user.png')
                                  as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              FullNameWidget(controller: fullNameController),
              const SizedBox(height: 24),
              emailWidget(),
              const SizedBox(height: 24),
              PhoneWidget(controller: phoneController),
              const SizedBox(height: 24),

              if (userRole.toLowerCase() == "farmer") ...[
                AreaProximityWidget(
                  radius: deliveryRadius,
                  onChanged: (value) {
                    setState(() {
                      deliveryRadius = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveChanges();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: "Nunito",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

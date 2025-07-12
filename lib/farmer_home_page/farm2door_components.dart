import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

final addressController = TextEditingController();

class ProfileDataCollector {
  static List<String> selectedTypes = [];
  static double radius = 10;
  static String deliveryType = 'Self';
  static File? profilePhoto ; 

  static void collectAndPrintProfileData() {
    if (kDebugMode){
    print("Profile Data:");
    print("Address: ${addressController.text}");
    print("Product Types: $selectedTypes");
    print("Radius: ${radius.round()} km");
    print("Delivery Type: $deliveryType");
    print("Profil photo path: ${profilePhoto?.path  ?? 'no image selected'}");
  }
    }
    
}

AppBar farm2DoorAppBar(String s, IconData home) {
  return AppBar(
    backgroundColor: Colors.green[600],
    title: Row(children: [
      Icon(Icons.local_grocery_store_outlined, color: Colors.white, size: 36),
      Text('   Farm2Door',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Arial',
            fontSize: 25,
            fontWeight: FontWeight.bold,
          )),
    ]),
  );
}

class TitleText extends StatelessWidget {
  final String title;
  const TitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class AddressContainer extends StatelessWidget {
  const AddressContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: addressController,
      onSubmitted: (value) {
        print("Address entered: $value");
      } ,
      keyboardType: TextInputType.streetAddress,
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Enter your address ',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        floatingLabelStyle: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class ProductTypeSelector extends StatefulWidget {
  const ProductTypeSelector({super.key});

  @override
  _ProductTypeSelectorState createState() => _ProductTypeSelectorState();
}

class _ProductTypeSelectorState extends State<ProductTypeSelector> {
  final List<String> productTypes = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Flowers',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: productTypes.map((type) {
        return FilterChip(
          label: Text(type),
          selected: ProfileDataCollector.selectedTypes.contains(type),
          selectedColor: Colors.green.shade400,
          checkmarkColor: Colors.white,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                ProfileDataCollector.selectedTypes.add(type);
              } else {
                ProfileDataCollector.selectedTypes.remove(type);
              }
            });
          },
        );
      }).toList(),
    );
  }
}

class AreaProximitySelector extends StatefulWidget {
  const AreaProximitySelector({super.key});

  @override
  State<AreaProximitySelector> createState() => _AreaProximitySelectorState();
}

class _AreaProximitySelectorState extends State<AreaProximitySelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accept orders within this radius',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: ProfileDataCollector.radius,
                min: 1,
                max: 100,
                divisions: 99,
                label: ProfileDataCollector.radius.round().toString(),
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    ProfileDataCollector.radius = value;
                  });
                },
              ),
            ),
            Text(
              '${ProfileDataCollector.radius.round()} km',
              style: TextStyle(fontSize: 12),
            )
          ],
        )
      ],
    );
  }
}

class TypeOfDeliverySelector extends StatefulWidget {
  const TypeOfDeliverySelector({super.key});

  @override
  State<TypeOfDeliverySelector> createState() => _TypeOfDeliverySelectorState();
}

class _TypeOfDeliverySelectorState extends State<TypeOfDeliverySelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Self-delivery'),
          leading: Radio<String>(
            value: 'Self',
            groupValue: ProfileDataCollector.deliveryType,
            onChanged: (String? value) {
              setState(() {
                ProfileDataCollector.deliveryType = value!;
              });
            },
          ),
        ),
        ListTile(
          title: Text('Delivery partner'),
          leading: Radio<String>(
            value: 'Partner',
            groupValue: ProfileDataCollector.deliveryType,
            onChanged: (String? value) {
              setState(() {
                ProfileDataCollector.deliveryType = value!;
              });
            },
          ),
        )
      ],
    );
  }
}

class CreateProfileButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CreateProfileButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(double.infinity, 50),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Text('Create Profile'),
      ),
    );
  }
}

class SelectProfilePhoto extends StatefulWidget {
  const SelectProfilePhoto({super.key});

  @override
  State<SelectProfilePhoto> createState() => _SelectProfilePhotoState();
}

class _SelectProfilePhotoState extends State<SelectProfilePhoto> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          ProfileDataCollector.profilePhoto = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Image picking failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _pickImageFromGallery,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: ProfileDataCollector.profilePhoto != null
                  ? FileImage(ProfileDataCollector.profilePhoto!)
                  : const AssetImage('assets/images/default_products.png') as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 4,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

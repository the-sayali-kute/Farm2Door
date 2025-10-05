import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/farmer_home_page/farmer_main_page.dart';
import 'package:forms/reusables/final_vars.dart';
import 'package:forms/reusables/functions.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});
  @override
  _AddProductPage createState() => _AddProductPage();
}

class _AddProductPage extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? selectedCategory;
  String? selectedUnit;
  bool harvestedToday = false;
  bool pesticidesUsed = false;
  bool isOrganic = false;
  DateTime? harvestedDate;

  final List<String> categories = ['Vegetables', 'Fruits', 'Grains'];
  final List<String> units = [
    '100 gm',
    '125 gm',
    '250 gm',
    '500 gm',
    'Kg',
    'Dozen',
    'Piece',
    'Bunch',
  ];

  TextEditingController harvestedDateController = TextEditingController();
  final mrpController = TextEditingController();
  final spController = TextEditingController();
  final productNameController = TextEditingController();
  final imageUrlController = TextEditingController();
  final stockController = TextEditingController();
  double discount = 0;

  void updateDiscount() {
    final mrp = double.tryParse(mrpController.text) ?? 0;
    final sp = double.tryParse(spController.text) ?? 0;

    if (mrp > 0 && sp > 0) {
      if (sp <= mrp) {
        setState(() {
          discount = ((mrp - sp) / mrp * 100);
        });
      } else {
        setState(() {
          discount = 0;
        });

        // Show a warning SnackBar or toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selling Price cannot be more than MRP."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      setState(() {
        discount = 0;
      });
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Add a product"),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            : AssetImage('assets/images/default_products.png')
                                  as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.green,
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

              Text(
                "General Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: productNameController,
                cursorColor: Colors.black,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  focusedBorder: border,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),
              TextFormField(
                cursorColor: Colors.black,
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: "Image url",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  focusedBorder: border,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Image url is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),

              // PRODUCT DESCRIPTION

              // TextFormField(
              //   cursorColor: Colors.black,
              //   keyboardType: TextInputType.name,
              //   maxLines: 3,
              //   decoration: InputDecoration(
              //     labelText: 'Product Description',
              //     labelStyle: TextStyle(color: Colors.black, fontSize: 16),
              //     border: OutlineInputBorder(),
              //     isDense: true, // reduces height
              //     contentPadding: EdgeInsets.symmetric(
              //       vertical: 12,
              //       horizontal: 14,
              //     ),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Description Name is required';
              //     }
              //     return null;
              //   },
              // ),

              // drop downs
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Category",
                        labelStyle: TextStyle(color: Colors.black),
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border,
                      ),
                      items: categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (value) => selectedCategory = value,
                      validator: (value) {
                        if (selectedCategory == null ||
                            selectedCategory!.trim().isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16), // Add spacing between dropdowns
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Unit Type",
                        labelStyle: TextStyle(color: Colors.black),
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border,
                      ),
                      items: units
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => selectedUnit = value,
                      validator: (value) {
                        if (selectedCategory == null ||
                            selectedCategory!.trim().isEmpty) {
                          return 'Unit Type is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 35),
              Text(
                "Pricing & Stock",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Stock Available",
                  suffixText: selectedUnit ?? "", // shows "kg", "dozen", etc.
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  focusedBorder: border,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stock is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                      controller: mrpController,
                      decoration: InputDecoration(
                        labelText: "MRP",
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
                        focusedBorder: border,
                      ),
                      onChanged: (value) {
                        updateDiscount();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'MRP is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 25),
                  Expanded(
                    child: TextFormField(
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                      controller: spController,
                      decoration: InputDecoration(
                        labelText: "Selling Price",
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
                        focusedBorder: border,
                      ),
                      onChanged: (value) {
                        updateDiscount();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Selling Price is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Text(
                "Discount: ${discount.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: discount > 0 ? Colors.green : Colors.grey,
                ),
              ),
              SizedBox(height: 35),
              Text(
                "Other Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: harvestedDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Harvested Date",
                  labelStyle: TextStyle(color: Colors.black),
                  suffixIcon: Icon(Icons.calendar_today),
                  focusedBorder: border,
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary:
                                Colors.green, // Header background & OK button
                            onPrimary: Colors.white, // Header text color
                            onSurface: Colors.black, // Body text color
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Colors.green, // CANCEL button text color
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    }, // Prevents selecting future dates
                  );
                  setState(() {
                    harvestedDate = pickedDate;
                    if (pickedDate != null) {
                      setState(() {
                        harvestedDate = pickedDate;
                        harvestedDateController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the harvested date';
                  }
                  return null;
                },
              ),

              SizedBox(height: 15),
              SwitchListTile(
                title: Text("Harvested today?"),
                activeThumbColor: Color(0xFF4CA330),
                value: harvestedToday,
                onChanged: (val) => setState(() => harvestedToday = val),
              ),
              SwitchListTile(
                title: Text("Any pesticides used?"),
                activeThumbColor: Color(0xFF4CA330),
                value: pesticidesUsed,
                onChanged: (val) => setState(() => pesticidesUsed = val),
              ),
              SwitchListTile(
                title: Text("Organically grown?"),
                activeThumbColor: Color(0xFF4CA330),
                value: isOrganic,
                onChanged: (val) => setState(() => isOrganic = val),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: gradient,
                ),
                child: TextButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return; // stop if validation fails
                    }
                    if (selectedCategory == null || selectedUnit == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        errorBar("Please select both category and unit type"),
                      );
                    }
                    if (harvestedDate == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(errorBar("Please select harvested date"));
                      return;
                    }

                    if (pesticidesUsed || !isOrganic) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        warningBar("Please confirm freshness & organic status"),
                      );
                    }

                    bool someThingEmpty =
                        (productNameController.text.isEmpty ||
                        mrpController.text.isEmpty ||
                        spController.text.isEmpty ||
                        stockController.text.isEmpty);

                    if (someThingEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(errorBar("Please enter all the details"));
                      return;
                    }

                    // Store product details
                    try {
                      String? imageUrl;

                      // if (_selectedImage != null) {
                      //   try {
                      //     final imageName = DateTime.now()
                      //         .millisecondsSinceEpoch
                      //         .toString();
                      //     final ref = FirebaseStorage.instance.ref().child(
                      //       'product_images/$imageName.jpg',
                      //     );
                      //     final uploadTask = await ref.putFile(_selectedImage!);
                      //     imageUrl = await uploadTask.ref.getDownloadURL();
                      //     debugPrint("Image uploaded: $imageUrl");
                      //   } catch (e) {
                      //     debugPrint("Image upload failed: $e");
                      //     ScaffoldMessenger.of(
                      //       context,
                      //     ).showSnackBar(errorBar("Image upload failed"));
                      //   }
                      // }

                      final productData = {
                        'productName': productNameController.text.trim(),
                        'category': selectedCategory,
                        'unit': selectedUnit,
                        'mrp': double.parse(mrpController.text),
                        'sellingPrice': double.parse(spController.text),
                        'discountPercent': discount,
                        'originalStock': int.parse(stockController.text),
                        'presentStock':int.parse(stockController.text),
                        'isOrganic': isOrganic,
                        'anyPesticides': pesticidesUsed,
                        'img':imageUrlController.text,
                        'harvestedDate': harvestedDate!.toIso8601String(),
                        'createdAt': Timestamp.now(),
                        'farmerId': FirebaseAuth.instance.currentUser!.uid,
                      };

                      await FirebaseFirestore.instance
                          .collection('products')
                          .add(productData);

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(successBar("Product added successfully!"));

                      Navigator.of(context).maybePop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => FarmerMainPage(),
                        ),
                      );
                    } catch (e) {
                      debugPrint("Error adding product: $e");
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(errorBar("Failed to add product"));
                    }
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    "Add Product",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

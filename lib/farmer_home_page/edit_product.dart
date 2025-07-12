import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/appbar.dart';
import 'package:forms/customer_home_page/cart/inputs.dart';
import 'package:forms/farmer_home_page/farmer_main_page.dart';
import 'package:forms/functions.dart';
import 'package:image_picker/image_picker.dart';

class EditProduct extends StatefulWidget {
  final String productId;
  const EditProduct({super.key, required this.productId});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
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

  final TextEditingController harvestedDateController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController spController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
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

  Future<void> loadProductDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        productNameController.text = data['productName'] ?? '';
        selectedCategory = data['category'];
        selectedUnit = data['unit'];
        mrpController.text = data['mrp'].toString();
        spController.text = data['sellingPrice'].toString();
        stockController.text = data['stock'].toString();
        discount = data['discountPercent'] ?? 0;
        isOrganic = data['isOrganic'] ?? false;
        pesticidesUsed = data['anyPesticides'] ?? false;
        harvestedDate = DateTime.tryParse(data['harvestedDate'] ?? '');
        if (harvestedDate != null) {
          harvestedDateController.text =
              "${harvestedDate!.day}/${harvestedDate!.month}/${harvestedDate!.year}";
        }
        imageUrlController.text = data['img'] ?? '';
      });
    }
  }

  Future<void> saveChanges() async {
    try {
      final productData = {
        'productName': productNameController.text.trim(),
        'category': selectedCategory,
        'unit': selectedUnit,
        'mrp': double.parse(mrpController.text),
        'sellingPrice': double.parse(spController.text),
        'discountPercent': discount,
        'stock': int.parse(stockController.text),
        'isOrganic': isOrganic,
        'anyPesticides': pesticidesUsed,
        'img': imageUrlController.text,
        'harvestedDate': harvestedDate?.toIso8601String(),
        'updatedAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update(productData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(successBar("Product updated successfully!"));
      Navigator.of(context).maybePop();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => FarmerMainPage()));
    } catch (e) {
      debugPrint("Error updating product: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(errorBar("Failed to update product"));
    }
  }

  @override
  void initState() {
    super.initState();
    loadProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Edit Product"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceSelector(context),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : NetworkImage(
                                imageUrlController.text.isNotEmpty
                                    ? imageUrlController.text
                                    : 'https://via.placeholder.com/150',
                              )
                              as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: productNameController,
                cursorColor: Colors.black,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  focusedBorder: border,
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: imageUrlController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Image URL",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  focusedBorder: border,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                style: TextStyle(fontSize: 16, color: Colors.black),
                value: selectedCategory,
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val),
                decoration: InputDecoration(
                  labelText: "Category",
                  labelStyle: TextStyle(color: Colors.black),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                style: TextStyle(fontSize: 16, color: Colors.black),
                value: selectedUnit,
                items: units
                    .map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedUnit = val),
                decoration: InputDecoration(
                  labelText: "Unit Type",
                  labelStyle: TextStyle(color: Colors.black),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: stockController,
                decoration: InputDecoration(
                  labelText: "Stock Available",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  focusedBorder: border,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: mrpController,
                decoration: InputDecoration(
                  labelText: "MRP",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  focusedBorder: border,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => updateDiscount(),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: spController,
                decoration: InputDecoration(
                  labelText: "Selling Price",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  focusedBorder: border,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => updateDiscount(),
              ),
              SizedBox(height: 8),
              Text("Discount: ${discount.toStringAsFixed(1)}%"),
              SizedBox(height: 16),
              TextFormField(
                controller: harvestedDateController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Harvested Date"),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: harvestedDate ?? DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      harvestedDate = picked;
                      harvestedDateController.text =
                          "${picked.day}/${picked.month}/${picked.year}";
                    });
                  }
                },
              ),
              SwitchListTile(
                title: Text("Harvested Today?"),
                value: harvestedToday,
                activeColor: Color(0xFF4CA330),
                onChanged: (val) => setState(() => harvestedToday = val),
              ),
              SwitchListTile(
                title: Text("Any Pesticides Used?"),
                value: pesticidesUsed,
                activeColor: Color(0xFF4CA330),
                onChanged: (val) => setState(() => pesticidesUsed = val),
              ),
              SwitchListTile(
                title: Text("Organically Grown?"),
                value: isOrganic,
                activeColor: Color(0xFF4CA330),
                onChanged: (val) => setState(() => isOrganic = val),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: gradient,
                ),
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveChanges();
                    }
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    "Save Changes",
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

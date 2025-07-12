import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/appbar.dart';
import 'package:forms/customer_home_page/hamburger_menu.dart';
import 'package:forms/farmer_home_page/edit_product.dart';
import 'package:forms/final_vars.dart';
import 'package:forms/functions.dart';

class FarmerHomePage extends StatefulWidget {
  const FarmerHomePage({super.key});

  @override
  State<FarmerHomePage> createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _orders = [];

  bool _isLoading = true;
  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    final products = await loadProducts();
    final users = await loadUsers();
    final orders = await loadOrders();

    setState(() {
      _products = products;
      _users = users;
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, logo: true, hamburger: true, add: true),
      drawer: HamburgerMenu(),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : buildHomePage(), // You can pass _products/_users/_orders to buildHomePage if needed
      ),
    );
  }
}

Future<List<QueryDocumentSnapshot>> fetchMyProducts() async {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('products')
      .where('farmerId', isEqualTo: uid)
      .get();

  return snapshot.docs; // Each doc is a QueryDocumentSnapshot
}

Widget buildHomePage() {
  final String farmerId = FirebaseAuth.instance.currentUser!.uid;

  return FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return const Center(child: Text("Something went wrong"));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            greetingCard(),
            const SizedBox(height: 16),
            const Text(
              'My Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            FutureBuilder(
              future: fetchMyProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No products added yet.");
                }
                return Column(
                  children: snapshot.data!
                      .map<Widget>(
                        (productDoc) => productCard(productDoc, context),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget greetingCard() {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(18),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder<String>(
              future: loadUserData("name"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "Hello, Farmer!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text(
                    "Hello, Farmer!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    "Hello, Farmer!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return Text(
                    "Hello, ${snapshot.data!}!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            CircleAvatar(
              radius: 24,
              backgroundImage:
                  const AssetImage("assets/images/user.png") as ImageProvider,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FutureBuilder<String>(
              future: loadUserData("revenue"),
              builder: (context, snapshot) {
                final value = snapshot.data ?? "0";

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return dashboardStat(
                    Icons.currency_rupee,
                    "Loading...",
                    "Revenue",
                  );
                } else if (snapshot.hasError) {
                  return dashboardStat(
                    Icons.currency_rupee,
                    "Error",
                    "Revenue",
                  );
                } else {
                  return dashboardStat(
                    Icons.currency_rupee,
                    "₹ $value",
                    "Revenue",
                  );
                }
              },
            ),
            FutureBuilder<String>(
              future: loadUserData("orders"),
              builder: (context, snapshot) {
                final value = snapshot.data ?? "0";

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return dashboardStat(
                    Icons.shopping_bag,
                    "Loading...",
                    "orders",
                  );
                } else if (snapshot.hasError) {
                  return dashboardStat(Icons.shopping_bag, "Error", "orders");
                } else {
                  return dashboardStat(Icons.shopping_bag, value, "Orders");
                }
              },
            ),
            FutureBuilder<String>(
              future: loadUserData("totalStock"),
              builder: (context, snapshot) {
                final value = snapshot.data ?? "0";

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return dashboardStat(
                    Icons.store,
                    "Loading...",
                    "Total stock",
                  );
                } else if (snapshot.hasError) {
                  return dashboardStat(Icons.store, "Error", "Total stock");
                } else {
                  return dashboardStat(Icons.store, value, "Total stock");
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}

// Utility widgets
Widget dashboardStat(IconData icon, final value, String label) {
  return Column(
    children: [
      Icon(icon, color: Colors.white, size: 30),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
    ],
  );
}

Future<String> loadUserData(String requiredField) async {
  final userDetails = await getCurrentUserDetails();
  if (userDetails != null) {
    final value = userDetails[requiredField];
    return value != null ? value.toString() : "0"; // or "Not available"
  } else {
    return "Invalid user";
  }
}

Widget productCard(DocumentSnapshot productDoc, BuildContext context) {
  final data = productDoc.data() as Map<String, dynamic>;

  void deleteProduct() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Product"),
        content: Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection("products")
            .doc(productDoc.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Product deleted successfully."),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete product."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: data['img'] != null && data['img'].isNotEmpty
            ? NetworkImage(data['img'])
            : AssetImage('assets/images/default_products.png') as ImageProvider,
      ),
      title: Text(
        data['productName'],
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stock: ${displayStock(data['stock'], data['unit'])}",
            style: TextStyle(fontSize: 13),
          ),
          Text(
            "₹ ${data['sellingPrice']} / ${data['unit']}",
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 'edit') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(productId: productDoc.id),
              ),
            );
          } else if (value == 'delete') {
            deleteProduct();
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.black),
                SizedBox(width: 8),
                Text("Edit"),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text("Delete"),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget placeholderBox(String text) {
  return Container(
    width: double.infinity,
    height: 120,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.center,
    child: Text(text, style: const TextStyle(color: Colors.grey)),
  );
}

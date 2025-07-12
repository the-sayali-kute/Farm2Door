// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:forms/customer_home_page/appbar.dart';
// import 'package:forms/customer_home_page/hamburger_menu.dart';
// import 'package:forms/customer_home_page/product_card.dart';
// import 'package:forms/customer_home_page/carousal.dart';

// class ProductList extends StatefulWidget {
//   const ProductList({super.key});

//   @override
//   State<ProductList> createState() => _ProductListState();
// }

// class _ProductListState extends State<ProductList> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar(context,logo: true,hamburger: true,search: true),
//       drawer: HamburgerMenu(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 20),
//               CustomCarousel(
//                 imagePaths: [
//                   'assets/images/p4.jpeg',
//                   'assets/images/p1.jpeg',
//                   'assets/images/p6.jpeg',
//                   'assets/images/p7.jpeg',
//                   'assets/images/p9.jpeg',
//                 ],
//               ),
//               SizedBox(height: 20),
//               FutureBuilder(
//                 future: FirebaseFirestore.instance.collection("products").get(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return Center(child: Text("No data found"));
//                   }

//                   return GridView.builder(
//                     shrinkWrap: true,// ✅ Allow ListView to size itself
//                     physics:
//                         NeverScrollableScrollPhysics(), // ✅ Prevent nested scroll
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3, // 3 cards per row
//                       crossAxisSpacing: 7, // space between cards
//                       mainAxisSpacing: 10, // space between rows
//                       childAspectRatio: 0.44, // aspect ratio of cards
//                     ),
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (context, index) {
//                       final product = snapshot.data!.docs[index];
//                       return ProductCard(
//                         path: product["img"],
//                         productId:product.id,
//                         unit: "${product["unit"]}",
//                         farmerId: product["farmerId"],
//                         harvestedDate: product["harvestedDate"],
//                         // isOrganic: product["isOrganic"],
//                         productName: product["productName"],
//                         sellingPrice: product["sellingPrice"].toString(),
//                         mrp: product["mrp"].toString(),
//                         discountPercent:product["discountPercent"].toString(),
//                         stock:product["stock"].toString()
//                       );
//                     },
//                   );
//                 },
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:forms/customer_home_page/appbar.dart';
// import 'package:forms/customer_home_page/hamburger_menu.dart';
// import 'package:forms/customer_home_page/product_card.dart';
// import 'package:forms/customer_home_page/carousal.dart';

// class ProductList extends StatefulWidget {
//   const ProductList({super.key});

//   @override
//   State<ProductList> createState() => _ProductListState();
// }

// class _ProductListState extends State<ProductList> {
//   List<Map<String, dynamic>> _nearbyProducts = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchNearbyProducts();
//   }

//   Future<void> fetchNearbyProducts() async {
//     // 🔁 Step 1: Get current user ID
//     final userId = FirebaseFirestore.instance.collection('users').doc().id;

//     // 🔁 Step 2: Get current user location
//     final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     final userData = userDoc.data();
//     if (userData == null) return;

//     final userLat = userData['latitude'];
//     final userLng = userData['longitude'];

//     final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
//     final List<Map<String, dynamic>> filteredProducts = [];

//     for (var doc in productsSnapshot.docs) {
//       final productData = doc.data();
//       final farmerId = productData['farmerId'];

//       final farmerDoc = await FirebaseFirestore.instance.collection('users').doc(farmerId).get();
//       final farmerData = farmerDoc.data();

//       if (farmerData != null &&
//           farmerData['latitude'] != null &&
//           farmerData['longitude'] != null) {
//         final distance = calculateDistance(
//           userLat,
//           userLng,
//           farmerData['latitude'],
//           farmerData['longitude'],
//         );

//         if (distance <= 5.0) {
//           productData['id'] = doc.id;
//           filteredProducts.add(productData);
//         }
//       }
//     }

//     setState(() {
//       _nearbyProducts = filteredProducts;
//       _loading = false;
//     });
//   }

//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const R = 6371;
//     final dLat = _degToRad(lat2 - lat1);
//     final dLon = _degToRad(lon2 - lon1);
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
//             sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _degToRad(double deg) => deg * (pi / 180);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar(context, logo: true, hamburger: true, search: true),
//       drawer: HamburgerMenu(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               CustomCarousel(
//                 imagePaths: [
//                   'assets/images/p4.jpeg',
//                   'assets/images/p1.jpeg',
//                   'assets/images/p6.jpeg',
//                   'assets/images/p7.jpeg',
//                   'assets/images/p9.jpeg',
//                 ],
//               ),
//               const SizedBox(height: 20),
//               if (_loading)
//                 const Center(child: CircularProgressIndicator())
//               else if (_nearbyProducts.isEmpty)
//                 const Center(child: Text("No nearby products found"))
//               else
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 7,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.44,
//                   ),
//                   itemCount: _nearbyProducts.length,
//                   itemBuilder: (context, index) {
//                     final product = _nearbyProducts[index];
//                     return ProductCard(
//                       path: product["img"],
//                       productId: product['id'],
//                       unit: "${product["unit"]}",
//                       farmerId: product["farmerId"],
//                       harvestedDate: product["harvestedDate"],
//                       productName: product["productName"],
//                       sellingPrice: product["sellingPrice"].toString(),
//                       mrp: product["mrp"].toString(),
//                       discountPercent: product["discountPercent"].toString(),
//                       stock: product["stock"].toString(),
//                     );
//                   },
//                 ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/appbar.dart';
import 'package:forms/customer_home_page/hamburger_menu.dart';
import 'package:forms/customer_home_page/product_card.dart';
import 'package:forms/customer_home_page/carousal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'package:geolocator/geolocator.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<QueryDocumentSnapshot> filteredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductsWithinRadius();
  }

  Future<void> _loadProductsWithinRadius() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      debugPrint("Finding current user");

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      final userData = userDoc.data();
      debugPrint("found user");

      if (userData == null ||
          userData['latitude'] == null ||
          userData['longitude'] == null) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }

      final double userLat = userData['latitude'];
      final double userLng = userData['longitude'];
      debugPrint("📍 Customer location: lat=$userLat, lng=$userLng");

      final productSnapshot = await FirebaseFirestore.instance
          .collection("products")
          .get();
      final allProducts = productSnapshot.docs;

      List<QueryDocumentSnapshot> nearbyProducts = [];

      for (final product in allProducts) {
        final data = product.data(); // Add casting

        final farmerId = data['farmerId'];
        if (farmerId == null) continue;

        final farmerDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(farmerId)
            .get();
        final farmerData = farmerDoc.data();

        if (farmerData == null ||
            farmerData['latitude'] == null ||
            farmerData['longitude'] == null) {
          continue;
        }

        final double farmerLat = farmerData['latitude'];
        final double farmerLng = farmerData['longitude'];

        final distance = _calculateDistance(
          userLat,
          userLng,
          farmerLat,
          farmerLng,
        );

        if (distance <= 5.0) {
          nearbyProducts.add(product);
        }
      }
      if (!mounted) return;
      setState(() {
        filteredProducts = nearbyProducts;
        isLoading = false;
      });
    } catch (e, stacktrace) {
      debugPrint("🔥 ERROR: $e");
      debugPrint("🔍 Stacktrace: $stacktrace");
      if (!mounted) return;
      // Ensure the loading spinner stops even on error
      setState(() {
        isLoading = false;
      });
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Location request timed out"),
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getNearbyProducts() async {
    final position = await getCurrentLocation();
    if (position == null) return [];

    final query = await FirebaseFirestore.instance.collection("products").get();
    return query.docs.where((doc) {
      final data = doc.data();
      final lat = data['latitude'];
      final lng = data['longitude'];
      if (lat == null || lng == null) return false;

      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );
      return distance <= 5.0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        logo: true,
        hamburger: true,
        search: true,
        wishlist: true,
      ),
      drawer: HamburgerMenu(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 20),
                CustomCarousel(
                  imagePaths: [
                    'assets/images/p4.jpeg',
                    'assets/images/p1.jpeg',
                    'assets/images/p6.jpeg',
                    'assets/images/p7.jpeg',
                    'assets/images/p9.jpeg',
                  ],
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // so ListView handles scrolling
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 7,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.44,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final data = product.data() as Map<String, dynamic>;
                    return ProductCard(
                      path: data["img"] ?? "https://i.pinimg.com/736x/9c/56/8e/9c568ee61b9dd67e9dc61a77f1b1dbcd.jpg",
                      productId: product.id,
                      unit: "${data["unit"]}",
                      farmerId: data["farmerId"],
                      harvestedDate: data["harvestedDate"],
                      productName: data["productName"],
                      sellingPrice: data["sellingPrice"].toString(),
                      mrp: data["mrp"].toString(),
                      discountPercent: data["discountPercent"].toString(),
                      stock: data["stock"].toString(),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

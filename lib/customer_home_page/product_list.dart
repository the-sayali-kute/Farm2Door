import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/hamburger_menu_items/hamburger_menu.dart';
import 'package:forms/customer_home_page/product_card.dart';
import 'package:forms/customer_home_page/carousal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forms/reusables/functions.dart';

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
              debugPrint("⛔ Skipping $farmerId: missing lat/lng");
          continue;
        }

        final double farmerLat = farmerData['latitude'];
        final double farmerLng = farmerData['longitude'];

        final distance = calculateDistance(
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

  // Future<List<DocumentSnapshot>> getNearbyProducts() async {
  //   final position = await getCurrentLocation();
  //   if (position == null) return [];

  //   final query = await FirebaseFirestore.instance.collection("products").get();
  //   return query.docs.where((doc) {
  //     final data = doc.data();
  //     final lat = data['latitude'];
  //     final lng = data['longitude'];
  //     if (lat == null || lng == null) return false;

  //     final distance = calculateDistance(
  //       position.latitude,
  //       position.longitude,
  //       lat,
  //       lng,
  //     );
  //     return distance <= 5.0;
  //   }).toList();
  // }

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
                      presentStock: data["presentStock"].toString(),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/hamburger_menu_items/hamburger_menu.dart';
import 'package:forms/customer_home_page/product_card.dart';
import 'package:forms/customer_home_page/carousal.dart';
import 'package:forms/reusables/functions.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Map<String, dynamic>> productsWithDistance = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  final int _limit = 10;
  DocumentSnapshot? _lastDoc;

  double? userLat;
  double? userLng;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initUserLocationAndLoad();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoadingMore &&
        hasMore) {
      _loadMoreProducts();
    }
  }

  Future<void> _initUserLocationAndLoad() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(userId).get();

      if (userDoc.exists) {
        userLat = userDoc["latitude"];
        userLng = userDoc["longitude"];
      }

      await _loadProducts(); // initial batch
    } catch (e) {
      debugPrint("Error loading user location: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadProducts() async {
    if (userLat == null || userLng == null) {
      debugPrint("⚠️ No location found for user.");
      setState(() => isLoading = false);
      return;
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection("products")
          .orderBy(FieldPath.documentId)
          .limit(_limit);

      final snapshot = await query.get();
      _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      final fetched = await _calculateDistances(snapshot.docs);

      setState(() {
        productsWithDistance = fetched;
        hasMore = true;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading products: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_lastDoc == null || !hasMore) return;

    setState(() => isLoadingMore = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection("products")
          .orderBy(FieldPath.documentId)
          .startAfterDocument(_lastDoc!)
          .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        hasMore = false;
        setState(() => isLoadingMore = false);
        return;
      }

      _lastDoc = snapshot.docs.last;

      final fetched = await _calculateDistances(snapshot.docs);

      setState(() {
        productsWithDistance.addAll(fetched);
        productsWithDistance.sort(
          (a, b) =>
              (a["distance"] as double).compareTo(b["distance"] as double),
        );
        isLoadingMore = false;
      });
    } catch (e) {
      debugPrint("Error loading more products: $e");
      setState(() => isLoadingMore = false);
    }
  }

  Future<List<Map<String, dynamic>>> _calculateDistances(
      List<QueryDocumentSnapshot> docs) async {
    List<Map<String, dynamic>> tempList = [];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final farmerId = data["farmerId"];

      if (farmerId == null) continue;

      final farmerDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(farmerId)
          .get();

      if (!farmerDoc.exists ||
          farmerDoc["latitude"] == null ||
          farmerDoc["longitude"] == null) {
        continue;
      }

      final double farmerLat = farmerDoc["latitude"];
      final double farmerLng = farmerDoc["longitude"];

      final distance =
          calculateDistance(userLat!, userLng!, farmerLat, farmerLng);

      tempList.add({
        "doc": doc,
        "distance": distance,
      });
    }

    // Sort by distance ascending before returning
    tempList.sort(
        (a, b) => (a["distance"] as double).compareTo(b["distance"] as double));

    return tempList;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 🔄 REFRESH FUNCTIONALITY
  Future<void> _refreshProducts() async {
    setState(() {
      isLoading = true;
      hasMore = true;
      _lastDoc = null;
    });
    await _loadProducts();
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
      drawer: const HamburgerMenu(),
      body: RefreshIndicator(
        onRefresh: _refreshProducts, // 👈 swipe down to reload
        color: Colors.green,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(), // 👈 important
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 20),
                  const CustomCarousel(
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
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 7,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.44,
                    ),
                    itemCount: productsWithDistance.length,
                    itemBuilder: (context, index) {
                      final productDoc = productsWithDistance[index]["doc"];
                      final data = productDoc.data() as Map<String, dynamic>;

                      return ProductCard(
                        path: data["img"] ??
                            "https://i.pinimg.com/736x/9c/56/8e/9c568ee61b9dd67e9dc61a77f1b1dbcd.jpg",
                        productId: productDoc.id,
                        unit: "${data["unit"]}",
                        farmerId: data["farmerId"],
                        harvestedDate: data["harvestedDate"],
                        productName: "${data["productName"]}",
                        sellingPrice: data["sellingPrice"].toString(),
                        mrp: data["mrp"].toString(),
                        discountPercent: data["discountPercent"].toString(),
                        presentStock: data["presentStock"].toString(),
                      );
                    },
                  ),
                  if (isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
      ),
    );
  }
}

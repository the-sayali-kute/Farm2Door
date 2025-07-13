import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/customer_home_page/wishlist/wishlist_empty.dart';
import 'package:forms/reusables/functions.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final List<dynamic> wishlist = userDoc.data()?['wishlist'] ?? [];

      List<Map<String, dynamic>> items = [];

      for (var productId in wishlist) {
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();
        if (productDoc.exists) {
          items.add(productDoc.data()!..['id'] = productId);
        }
      }

      setState(() {
        wishlistItems = items;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching wishlist: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    await userRef.update({
      'wishlist': FieldValue.arrayRemove([productId]),
    });

    setState(() {
      wishlistItems.removeWhere((item) => item['id'] == productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Wishlist", backBtn: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistItems.isEmpty
          ? const WishlistEmpty()
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return ListTile(
                  title: Text(
                    item['productName'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Image.network(item['img'], width: 80, height: 80),
                  subtitle: Text(
                    "₹${item['sellingPrice']}/${item['unit']}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_outlined,
                          size: 20,
                        ),
                        onPressed: () => removeFromWishlist(item['id']),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          addToCart(
                            context,
                            farmerId: item['farmerId'],
                            productId: item['id'],
                            productName: item['productName'],
                            path: item['img'], // <-- was item['img']
                            mrp: item['mrp'].toString(),
                            sellingPrice: item['sellingPrice'].toString(),
                            unit: item['unit'],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

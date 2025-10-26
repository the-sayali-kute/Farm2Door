import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/cart/cart_empty.dart';
import 'package:forms/customer_home_page/cart/cart_with_items.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Stream<QuerySnapshot> _cartStream;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    final buyerId = FirebaseAuth.instance.currentUser!.uid;
    _cartStream = FirebaseFirestore.instance
        .collection('cart')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots();
  }

  Future<void> _refreshCart() async {
    // Trigger a rebuild by reloading the stream
    setState(() {
      _loadCart();
    });
    await Future.delayed(const Duration(milliseconds: 1000)); // smooth effect
  }

  @override
  Widget build(BuildContext context) {
    final buyerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: _refreshCart,
        child: StreamBuilder<QuerySnapshot>(
          stream: _cartStream,
          builder: (context, snapshot) {
            // 🔄 While loading data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ❌ If error occurs
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            // 📦 If no items in cart
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const CartEmpty();
            }

            // ✅ If items exist
            return CartWithItems(buyerId: buyerId);
          },
        ),
      ),
    );
  }
}

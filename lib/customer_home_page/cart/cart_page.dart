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
  @override
  Widget build(BuildContext context) {
    final String buyerId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('buyerId', isEqualTo: buyerId)
            .snapshots(),
        builder: (context, snapshot) {
          // 🔄 While loading data
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // ❌ If error occurs
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          // 📦 If no items in cart
          if (snapshot.data!.docs.isEmpty) {
            return const CartEmpty();
          }
          // ✅ If items exist
          return CartWithItems(buyerId:buyerId);
        },
      ),
    );
  }
}

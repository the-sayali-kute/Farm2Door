import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/reusables/functions.dart';

class WishlistButton extends StatefulWidget {
  final String productId;

  const WishlistButton({required this.productId, super.key});

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  IconData _icon = Icons.favorite_border;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistStatus();
  }

  Future<void> _loadWishlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final wishlist = List<String>.from(doc.data()?['wishlist'] ?? []);
      setState(() {
        _icon = wishlist.contains(widget.productId)
            ? Icons.favorite
            : Icons.favorite_border;
        _loading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(errorBar("User not found"));
    }
  }

  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userDocRef.get();
    final wishlist = List<String>.from(doc.data()?['wishlist'] ?? []);

    setState(() => _loading = true);

    if (wishlist.contains(widget.productId)) {
      wishlist.remove(widget.productId);
    } else {
      wishlist.add(widget.productId);
    }

    await userDocRef.set({'wishlist': wishlist}, SetOptions(merge: true));
    await _loadWishlistStatus(); // Refresh icon
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator(color: Colors.black,);
    }

    return IconButton(
      icon: Icon(_icon),
      onPressed: _toggleWishlist,
    );
  }
}

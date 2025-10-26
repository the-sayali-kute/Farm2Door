import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/cart/inputs.dart';
import 'package:forms/customer_home_page/product_details.dart';
import 'package:forms/reusables/functions.dart';

class ProductCard extends StatefulWidget {
  final String path;
  final String productId;
  final String productName;
  final String harvestedDate;
  final String farmerId;
  final String presentStock;
  final String sellingPrice;
  final String discountPercent;
  final String unit;
  final String mrp;

  const ProductCard({
    super.key,
    required this.path,
    required this.productId,
    required this.productName,
    required this.harvestedDate,
    required this.farmerId,
    required this.presentStock,
    required this.sellingPrice,
    required this.discountPercent,
    required this.unit,
    required this.mrp,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double? distanceKm;

  @override
  void initState() {
    super.initState();
    _calculateDistanceToFarmer();
  }

  Future<void> _calculateDistanceToFarmer() async {
    final position = await getCurrentLocation();
    if (position == null) return;

    final farmerDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.farmerId)
        .get();

    final farmerData = farmerDoc.data();
    if (farmerData == null ||
        farmerData['latitude'] == null ||
        farmerData['longitude'] == null) {
      return;
    }

    final double lat = farmerData['latitude'];
    final double lng = farmerData['longitude'];

    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      lat,
      lng,
    );

    if (mounted) {
      setState(() {
        distanceKm = distance;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productName: widget.productName,
              productId: widget.productId,
              path: widget.path,
              sellingPrice: widget.sellingPrice,
              mrp: widget.mrp,
              unit: widget.unit,
              farmerId: widget.farmerId,
              harvestedDate: widget.harvestedDate,
              discountPercent: widget.discountPercent,
              presentStock: widget.presentStock,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            height: 250,
            width: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildImgStack(
                  widget.path,
                  context,
                  widget.productId,
                  widget.productName,
                  widget.unit,
                  widget.sellingPrice,
                  widget.farmerId,
                  widget.mrp,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "₹${widget.sellingPrice}",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "₹${widget.mrp}",
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Text(widget.unit.contains("gm")
                    ? widget.unit
                    : "1 ${widget.unit}"),
                Text(
                  widget.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "SAVE ₹${double.parse(widget.mrp).toInt() - double.parse(widget.sellingPrice).toInt()}",
                  style: const TextStyle(
                    color: Color.fromRGBO(80, 140, 86, 1),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          // ✅ Distance Badge (only visible badge, not text)
          if (distanceKm != null)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${distanceKm!.toStringAsFixed(1)} km away",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:forms/customer_home_page/cart/inputs.dart';
// import 'package:forms/customer_home_page/product_details.dart';
// import 'package:forms/functions.dart';

// class ProductCard extends StatefulWidget {
//   final String path;
//   final String productId;
//   final String productName;
//   final String harvestedDate;
//   final String farmerId;
//   final String sellingPrice;
//   final String stock;
//   final String mrp;
//   final String discountPercent;
//   final String unit;
//   // final bool isunder500meters;
//   const ProductCard({
//     super.key,
//     required this.path,
//     required this.productId,
//     required this.productName,
//     required this.harvestedDate,
//     required this.farmerId,
//     required this.stock,
//     required this.sellingPrice,
//     required this.discountPercent,
//     required this.unit,
//     required this.mrp,
//     // required this.isunder500meters,
//   });

//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {

//   Future<bool> validateIsNearestFor(String farmerId) async {
//   final position = await getCurrentLocation();
//   if (position == null) return false;

//   // Fetch the farmer's user document
//   final farmerDoc = await FirebaseFirestore.instance.collection("users").doc(farmerId).get();
//   final farmerData = farmerDoc.data();
//   if (farmerData == null || farmerData['latitude'] == null || farmerData['longitude'] == null) {
//     return false;
//   }

//   final double lat = farmerData['latitude'];
//   final double lng = farmerData['longitude'];

//   final distance = calculateDistance(
//     position.latitude,
//     position.longitude,
//     lat,
//     lng,
//   );

//   return distance <= 0.5;
// }

 
//   @override
// Widget build(BuildContext context) {
//   return GestureDetector(
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ProductDetailsPage(
//             productName: widget.productName,
//             productId: widget.productId,
//             path: widget.path,
//             sellingPrice: widget.sellingPrice,
//             mrp: widget.mrp,
//             unit: widget.unit,
//             farmerId: widget.farmerId,
//             harvestedDate: widget.harvestedDate,
//             discountPercent: widget.discountPercent,
//             stock: widget.stock,
//           ),
//         ),
//       );
//     },
//     child: Container(
//         // aspect ratio =  width/height = 110/250 = 0.44
//         height: 250,
//         width: 110,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             // stack allows widgets to be stacked/placed on top of each other
//             buildImgStack(widget.path, context, widget.productId,widget.productName,widget.unit,widget.sellingPrice,widget.farmerId,widget.mrp),

//             SizedBox(height: 10),
//             Row(
//               children: [
//                 Text(
//                   "₹${widget.sellingPrice}",
//                   style: TextStyle(fontWeight: FontWeight.w900),
//                 ),
//                 SizedBox(width: 5),
//                 Text(
//                   "₹${widget.mrp}",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     decoration: TextDecoration.lineThrough,
//                     decorationColor: Colors.grey,
//                     fontSize: 10,
//                   ),
//                 ),
//               ],
//             ),
//             Text(widget.unit.contains("gm") ? widget.unit : "1 ${widget.unit}"),
//             Text(
//               widget.productName,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               "SAVE ₹${double.parse(widget.mrp).toInt() - double.parse(widget.sellingPrice).toInt()}",
//               style: TextStyle(
//                 color: Color.fromRGBO(80, 140, 86, 1),
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             // Container(
//             //   padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
//             //   decoration: BoxDecoration(
//             //     borderRadius: BorderRadius.circular(10),
//             //     color: const Color.fromARGB(255, 212, 234, 185),
//             //   ),
//             //   child: Row(
//             //     mainAxisSize: MainAxisSize.min,
//             //     children: [
//             //       Icon(Icons.star, color: Colors.green, size: 15),
//             //       Text("rating"),
//             //     ],
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//   );
// }

// }


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
  final String sellingPrice;
  final String stock;
  final String mrp;
  final String discountPercent;
  final String unit;

  const ProductCard({
    super.key,
    required this.path,
    required this.productId,
    required this.productName,
    required this.harvestedDate,
    required this.farmerId,
    required this.stock,
    required this.sellingPrice,
    required this.discountPercent,
    required this.unit,
    required this.mrp,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isNearest = false;

  @override
  void initState() {
    super.initState();
    _checkIfNearest();
  }

  Future<void> _checkIfNearest() async {
    final position = await getCurrentLocation();
    if (position == null) return;

    final farmerDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.farmerId)
        .get();
    final farmerData = farmerDoc.data();
    if (farmerData == null ||
        farmerData['latitude'] == null ||
        farmerData['longitude'] == null) return;

    final double lat = farmerData['latitude'];
    final double lng = farmerData['longitude'];

    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      lat,
      lng,
    );

    if (distance <= 1.0) {
      if (mounted) {
        setState(() {
          isNearest = true;
        });
      }
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
              stock: widget.stock,
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
                      style: TextStyle(
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
          if (isNearest)
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
                child: const Text(
                  'Nearest Here',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

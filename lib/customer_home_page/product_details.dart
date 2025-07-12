import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/appbar.dart';
import 'package:forms/customer_home_page/review_bottom_sheet.dart';
import 'package:forms/customer_home_page/wishlist/wishlist_button.dart';
import 'package:forms/final_vars.dart';
import 'package:forms/functions.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

String formatDateToDayMonth(DateTime date) {
  int day = date.day;
  int year = date.year;
  String month = _monthName(date.month);
  String suffix = _getDaySuffix(day);

  return '$day$suffix $month $year';
}

String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String _monthName(int month) {
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month];
}

Future<String> getFarmerNameById(String farmerId) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(farmerId)
        .get();

    if (doc.exists) {
      return doc['name'] ?? 'Unknown Farmer';
    } else {
      return 'Farmer not found';
    }
  } catch (e) {
    debugPrint('Error fetching farmer name: $e');
    return 'Error fetching name';
  }
}

Future<IconData> manageWishlist(BuildContext context, String productId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      List wishlist = await userDoc.get("wishlist");
      final userDocRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid);
      debugPrint(wishlist.toString());
      if (wishlist.contains(productId)) {
        wishlist.remove(productId);
        await userDocRef.set({"wishlist": wishlist,},SetOptions(merge: true));
        return Icons.favorite_border;
      } else {
        wishlist.add(productId);
        await userDocRef.set({"wishlist": wishlist},SetOptions(merge: true));
        return Icons.favorite;
      }
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(errorBar("user not fount"));
  }
  return Icons.favorite_border;
}



class ProductDetailsPage extends StatefulWidget {
  final String path;
  final String productName;
  final String productId;
  final String harvestedDate;
  final String farmerId;
  final String sellingPrice;
  final String stock;
  final String mrp;
  final String discountPercent;
  final String unit;
  const ProductDetailsPage({
    super.key,
    required this.path, //u
    required this.productId, //u
    required this.productName, //u
    required this.harvestedDate, //u
    required this.farmerId,
    required this.stock, //u
    required this.sellingPrice, //u
    required this.discountPercent, //u
    required this.unit, //u
    required this.mrp, //u
  });
  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Product Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 233, 247, 234),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(widget.path),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WishlistButton(productId: widget.productId),

                    IconButton(
                      icon: const Icon(Icons.ios_share_rounded),
                      onPressed: () {
                        Share.share(
                          "Check out this farm-fresh product: ${widget.productName}!\n\n @ ",
                          subject:
                              "Fresh from the Farm - ${widget.productName}",
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.productName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Row(
                  children: [
                    Text(
                      'Net Qty: ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 128, 127, 127),
                      ),
                    ),
                    Text(
                      widget.unit.contains("gm")
                          ? widget.unit
                          : "1 ${widget.unit}",
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${widget.sellingPrice}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "₹${widget.mrp}",
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Color.fromARGB(255, 128, 127, 127),
                          ),
                        ),
                        Text(
                          "(incl. of all taxes)",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 128, 127, 127),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Product Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Harvested Date"),
                    Text(
                      formatDateToDayMonth(
                        DateTime.parse(widget.harvestedDate),
                      ),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Grown By"),
                    FutureBuilder(
                      future: getFarmerNameById(widget.farmerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        } else if (snapshot.hasError) {
                          return Text("Error");
                        } else {
                          return Text(
                            "${snapshot.data}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Highlights',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Lottie.asset(
                      "assets/animations/discount.json",
                      height: 120,
                      // repeat: true,
                      reverse: false,
                      animate: true,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${double.parse(widget.discountPercent).toStringAsFixed(2)}% off",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Lottie.asset(
                      "assets/animations/stock.json",
                      height: 120,
                      repeat: true,
                      reverse: false,
                      animate: true,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${displayStock(int.parse(widget.stock), widget.unit)} left",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 25),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text(
                      'Reviews',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    //print('Review button pressed');
                    
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => ReviewBottomSheet(productId: widget.productId),
                );
              },
              ),//revised review button
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: gradient,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        await FirebaseFirestore.instance.collection('cart').add({
                          'buyerId': user!.uid,
                          'farmerId': widget.farmerId,
                          'productName': widget.productName,
                          'productId':
                              widget.productId, // Pass product ID to widget
                          'img': widget.path,
                          'sellingPrice': widget.sellingPrice,
                          'mrp': widget.mrp,
                          'unit': widget.unit,
                          'quantity':
                              "1 ${widget.unit}", // default, you can allow updates
                          'addedAt': Timestamp.now(),
                        });

                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          successBar("${widget.productName} added to cart!"),
                        );
                      } catch (e) {
                        debugPrint("Error adding to cart: $e");
                        ScaffoldMessenger.of(
                          // ignore: use_build_context_synchronously
                          context,
                        ).showSnackBar(errorBar("Something went wrong."));
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

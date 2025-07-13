import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/farmer_home_page/orders/order_action_buttons.dart';
import 'package:forms/reusables/functions.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> item;
  final orderId;

  const OrderDetailsPage({
    super.key,
    required this.item,
    required this.orderId,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Future<void> handleAccept(
    String orderId,
    Map<String, dynamic> product, {
    required String farmerId,
    required String productName,
    required int orderedQuantity,
    required double total,
  }) async {
    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId);
    final snapshot = await orderRef.get();
    final data = snapshot.data();
    if (data == null) return;

    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      data['items'],
    );
    final index = items.indexWhere(
      (i) =>
          i['productName'] == product['productName'] &&
          i['farmerId'] == product['farmerId'],
    );

    if (index != -1) {
      items[index]['status'] = 'accepted';
      updateProductQuantityAfterOrder(
        farmerId: farmerId,
        productName: productName,
        orderedQuantity: orderedQuantity,
      );
      final userDetails = await getCurrentUserDetails();
      if (userDetails != null) {
        double revenue = (userDetails['revenue'] ?? 0).toDouble() + total;
        int orders = (userDetails['orders'] ?? 0).toInt() + 1;

        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(farmerId);
        await userDocRef.update({'revenue': revenue, 'orders': orders});
      }

      await orderRef.update({'items': items});
    }
  }

  Future<void> handleReject(
    String orderId,
    Map<String, dynamic> product,
  ) async {
    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId);
    final snapshot = await orderRef.get();
    final data = snapshot.data();
    if (data == null) return;

    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      data['items'],
    );
    final index = items.indexWhere(
      (i) =>
          i['productName'] == product['productName'] &&
          i['farmerId'] == product['farmerId'],
    );

    if (index != -1) {
      items[index]['status'] = 'rejected';
      await orderRef.update({'items': items});
    }
    if (index != -1) {
      items[index]['status'] = 'rejected';
      await orderRef.update({'items': items});

      // Send message logic (here it's a snackbar as a placeholder)
      final userPhone = await getPhoneNumber(orderId);
      if (userPhone != null) {
        final message = Uri.encodeComponent(
          "Hello,\n\nWe're sorry to inform you that your order for *${product['productName']}* has been *rejected* ❌ by the farmer, possibly due to low stock or unavailability.\n\nPlease feel free to explore other fresh items on Farm2Door. 🛒🌿",
        );

        final whatsappUrl = Uri.parse("https://wa.me/$userPhone?text=$message");

        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open WhatsApp")),
          );
        }
      }
    }
  }

  Future<void> handleCompleted(
    String orderId,
    Map<String, dynamic> product,
    BuildContext context,
  ) async {
    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId);
    final snapshot = await orderRef.get();
    final data = snapshot.data();
    if (data == null) return;

    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      data['items'],
    );
    final index = items.indexWhere(
      (i) =>
          i['productName'] == product['productName'] &&
          i['farmerId'] == product['farmerId'],
    );

    if (index != -1) {
      items[index]['status'] = 'completed';
      await orderRef.update({'items': items});

      // Send message logic (here it's a snackbar as a placeholder)
      final userPhone = await getPhoneNumber(orderId);
      if (userPhone != null) {
        final message = Uri.encodeComponent(
          "Hi there! 🧑‍🌾\n\nYour order for *${product['productName']}* has been *successfully delivered* 📦✅.\n\nWe hope you enjoy the fresh produce! Thank you for supporting local farmers with Farm2Door. 🌿",
        );

        final whatsappUrl = Uri.parse("https://wa.me/$userPhone?text=$message");

        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open WhatsApp")),
          );
        }
      }
    }
  }

  Future<void> showBuyerLocation(BuildContext context, String userId) async {
    try {
      // Step 1: Get user's location from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final data = userDoc.data();

      if (data == null ||
          data['latitude'] == null ||
          data['longitude'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not available for this buyer.'),
          ),
        );
        return;
      }

      final double lat = data['latitude'];
      final double lng = data['longitude'];

      final Uri googleMapUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );

      // Step 2: Show dialog before opening
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Open Location"),
          content: Text(
            "Do you want to open the location?\n\nLat: $lat\nLng: $lng",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // cancel
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).maybePop(); // Close dialog first

                if (await canLaunchUrl(googleMapUrl)) {
                  await launchUrl(
                    googleMapUrl,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Could not launch Google Maps"),
                    ),
                  );
                }
              },
              child: const Text(
                "Open Maps",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error fetching location: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching location: $e")));
    }
  }

  Future<String?> getPhoneNumber(String orderId) async {
    final userId = await getUserIdFromOrder(orderId);

    if (userId == null) {
      debugPrint("User ID not found for order: $orderId");
      return null;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final phone = data?['phone'];
        return phone?.toString(); // Safely convert to String
      } else {
        debugPrint('User not found');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting phone number: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Order Details"),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.item.length,
        itemBuilder: (context, index) {
          final product = widget.item[index];

          // ✅ Extract orderId from the current product
          final String orderId = product['orderId'];
          final quantity = product['quantity'];
          final unit = product['unit'];
          final price =
              double.tryParse(product['sellingPrice'].toString()) ?? 0;
          final total = price * quantity;

          return Card(
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(19),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product['img'] != null &&
                      product['img'].toString().isNotEmpty)
                    Center(
                      child: Image.network(
                        product['img'],
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 80),
                      ),
                    ),
                  const SizedBox(height: 20),
                  infoRow(
                    Icons.shopping_bag,
                    "Product",
                    product['productName'],
                  ),
                  const SizedBox(height: 12),
                  infoRow(
                    Icons.format_list_numbered,
                    "Quantity",
                    displayStock(quantity, unit),
                  ),
                  const SizedBox(height: 12),
                  infoRow(Icons.price_change, "Price per Unit", "₹$price"),
                  const SizedBox(height: 12),
                  FutureBuilder<String?>(
                    future: getPhoneNumber(orderId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return infoRow(Icons.call, "Contact no", "Loading...");
                      } else if (snapshot.hasError) {
                        return infoRow(
                          Icons.call,
                          "Contact no",
                          "Error fetching",
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return infoRow(
                          Icons.call,
                          "Contact no",
                          "Not available",
                        );
                      } else {
                        return infoRow(
                          Icons.call,
                          "Contact no",
                          snapshot.data!,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  infoRow(
                    Icons.assignment_turned_in,
                    "Status",
                    product['status'],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 30),
                  infoRow(
                    Icons.attach_money,
                    "Total Price",
                    "₹${total.toStringAsFixed(2)}",
                    isBold: true,
                  ),
                  const Divider(height: 30),

                  /// ✅ Order Action Buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: OrderActionButtons(
                      status: product['status'],
                      onAccept: () async => await handleAccept(
                        orderId,
                        product,
                        farmerId: product['farmerId'],
                        productName: product['productName'],
                        orderedQuantity: product['quantity'],
                        total: total,
                      ),
                      onReject: () async =>
                          await handleReject(orderId, product),
                      onGetLocation: () async =>
                          showBuyerLocation(context, product['userId']),
                      onCompleted: () async =>
                          await handleCompleted(orderId, product, context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget infoRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "$label:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.green[800] : Colors.black,
          ),
        ),
      ],
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:forms/widgets/appbar.dart';
// import 'package:forms/farmer_home_page/orders/order_action_buttons.dart';
// import 'package:forms/reusables/functions.dart';
// import 'package:url_launcher/url_launcher.dart';

// class OrderDetailsPage extends StatefulWidget {
//   final List<Map<String, dynamic>> item;
//   final String orderId;

//   const OrderDetailsPage({
//     super.key,
//     required this.item,
//     required this.orderId,
//   });

//   @override
//   State<OrderDetailsPage> createState() => _OrderDetailsPageState();
// }

// class _OrderDetailsPageState extends State<OrderDetailsPage> {
//   late List<Map<String, dynamic>> item;
//   Future<void> showBuyerLocation(BuildContext context, String userId) async {
//     try {
//       // Step 1: Get user's location from Firestore
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();
//       final data = userDoc.data();

//       if (data == null ||
//           data['latitude'] == null ||
//           data['longitude'] == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Location not available for this buyer.'),
//           ),
//         );
//         return;
//       }

//       final double lat = data['latitude'];
//       final double lng = data['longitude'];

//       final Uri googleMapUrl = Uri.parse(
//         'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
//       );

//       // Step 2: Show dialog before opening
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Open Location"),
//           content: Text(
//             "Do you want to open the location?\n\nLat: $lat\nLng: $lng",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(), // cancel
//               child: const Text(
//                 "Cancel",
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).maybePop(); // Close dialog first

//                 if (await canLaunchUrl(googleMapUrl)) {
//                   await launchUrl(
//                     googleMapUrl,
//                     mode: LaunchMode.externalApplication,
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Could not launch Google Maps"),
//                     ),
//                   );
//                 }
//               },
//               child: const Text(
//                 "Open Maps",
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error fetching location: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error fetching location: $e")));
//     }
//   }

//   Future<String?> getPhoneNumber(String orderId) async {
//     final userId = await getUserIdFromOrder(orderId);

//     if (userId == null) {
//       debugPrint("User ID not found for order: $orderId");
//       return null;
//     }

//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();

//       if (doc.exists) {
//         final data = doc.data();
//         final phone = data?['phone'];
//         return phone?.toString(); // Safely convert to String
//       } else {
//         debugPrint('User not found');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('Error getting phone number: $e');
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     item = List<Map<String, dynamic>>.from(widget.item);
//   }

//   Future<void> handleAccept(
//     String orderId,
//     Map<String, dynamic> product, {
//     required String farmerId,
//     required String productName,
//     required int orderedQuantity,
//     required double total,
//   }) async {
//     final orderRef = FirebaseFirestore.instance
//         .collection('orders')
//         .doc(orderId);
//     final snapshot = await orderRef.get();
//     final data = snapshot.data();
//     if (data == null) return;

//     List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
//       data['items'],
//     );
//     final index = items.indexWhere(
//       (i) =>
//           i['productName'] == product['productName'] &&
//           i['farmerId'] == product['farmerId'],
//     );

//     if (index != -1) {
//       items[index]['status'] = 'accepted';
//       updateProductQuantityAfterOrder(
//         farmerId: farmerId,
//         productName: productName,
//         orderedQuantity: orderedQuantity,
//       );
//       final userDetails = await getCurrentUserDetails();
//       if (userDetails != null) {
//         double revenue = (userDetails['revenue'] ?? 0).toDouble() + total;
//         int orders = (userDetails['orders'] ?? 0).toInt() + 1;

//         final userDocRef = FirebaseFirestore.instance
//             .collection('users')
//             .doc(farmerId);
//         await userDocRef.update({'revenue': revenue, 'orders': orders});
//       }

//       await orderRef.update({'items': items});
//       setState(() => item[index]['status'] = 'accepted');
//     }
//   }

//   Future<void> handleReject(
//     String orderId,
//     Map<String, dynamic> product,
//   ) async {
//     final orderRef = FirebaseFirestore.instance
//         .collection('orders')
//         .doc(orderId);
//     final snapshot = await orderRef.get();
//     final data = snapshot.data();
//     if (data == null) return;

//     List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
//       data['items'],
//     );
//     final index = items.indexWhere(
//       (i) =>
//           i['productName'] == product['productName'] &&
//           i['farmerId'] == product['farmerId'],
//     );

//     if (index != -1) {
//       items[index]['status'] = 'rejected';
//       await orderRef.update({'items': items});
//       setState(() => item[index]['status'] = 'rejected');
//     }
//   }

//   Future<void> handleCompleted(
//     String orderId,
//     Map<String, dynamic> product,
//     BuildContext context,
//   ) async {
//     final orderRef = FirebaseFirestore.instance
//         .collection('orders')
//         .doc(orderId);
//     final snapshot = await orderRef.get();
//     final data = snapshot.data();
//     if (data == null) return;

//     List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
//       data['items'],
//     );
//     final index = items.indexWhere(
//       (i) =>
//           i['productName'] == product['productName'] &&
//           i['farmerId'] == product['farmerId'],
//     );

//     if (index != -1) {
//       items[index]['status'] = 'completed';
//       await orderRef.update({'items': items});
//       setState(() => item[index]['status'] = 'completed');

//       final userPhone = await getPhoneNumber(orderId);
//       if (userPhone != null) {
//         final message = Uri.encodeComponent(
//           "Hello! Your order for ${product['productName']} has been delivered. Thank you for shopping with us!",
//         );
//         final whatsappUrl = Uri.parse("https://wa.me/$userPhone?text=$message");

//         if (await canLaunchUrl(whatsappUrl)) {
//           await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Could not open WhatsApp")),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar(context, title: "Order Details"),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16.0),
//         itemCount: item.length,
//         itemBuilder: (context, index) {
//           final product = item[index];
//           final quantity = product['quantity'];
//           final unit = product['unit'];
//           final price =
//               double.tryParse(product['sellingPrice'].toString()) ?? 0;
//           final total = price * quantity;
//           final orderId = product['orderId'];

//           return Card(
//             elevation: 6,
//             margin: const EdgeInsets.only(bottom: 20),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(19),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (product['img'] != null &&
//                       product['img'].toString().isNotEmpty)
//                     Center(
//                       child: Image.network(
//                         product['img'],
//                         height: 120,
//                         width: 120,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) =>
//                             const Icon(Icons.image_not_supported, size: 80),
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                   infoRow(
//                     Icons.shopping_bag,
//                     "Product",
//                     product['productName'],
//                   ),
//                   const SizedBox(height: 12),
//                   infoRow(
//                     Icons.format_list_numbered,
//                     "Quantity",
//                     displayStock(quantity, unit),
//                   ),
//                   const SizedBox(height: 12),
//                   infoRow(Icons.price_change, "Price per Unit", "₹$price"),
//                   const SizedBox(height: 12),
//                   FutureBuilder<String?>(
//                     future: getPhoneNumber(orderId),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return infoRow(Icons.call, "Contact no", "Loading...");
//                       } else if (snapshot.hasError || !snapshot.hasData) {
//                         return infoRow(Icons.call, "Contact no", "Unavailable");
//                       } else {
//                         return infoRow(
//                           Icons.call,
//                           "Contact no",
//                           snapshot.data!,
//                         );
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   infoRow(
//                     Icons.assignment_turned_in,
//                     "Status",
//                     product['status'],
//                   ),
//                   const SizedBox(height: 12),
//                   const Divider(height: 30),
//                   infoRow(
//                     Icons.attach_money,
//                     "Total Price",
//                     "₹${total.toStringAsFixed(2)}",
//                     isBold: true,
//                   ),
//                   const Divider(height: 30),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16),
//                     child: OrderActionButtons(
//                       status: product['status'],
//                       onAccept: () async => await handleAccept(
//                         orderId,
//                         product,
//                         farmerId: product['farmerId'],
//                         productName: product['productName'],
//                         orderedQuantity: product['quantity'],
//                         total: total,
//                       ),
//                       onReject: () async =>
//                           await handleReject(orderId, product),
//                       onGetLocation: () async =>
//                           showBuyerLocation(context, product['userId']),
//                       onCompleted: () async =>
//                           await handleCompleted(orderId, product, context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget infoRow(
//     IconData icon,
//     String label,
//     String value, {
//     bool isBold = false,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.green[700], size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             "$label:",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: isBold ? Colors.green[800] : Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }

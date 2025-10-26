// ignore: depend_on_referenced_packages
import 'package:forms/customer_home_page/cart/cart_empty.dart';
import 'package:forms/customer_home_page/orders/delivery_address_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/reusables/functions.dart';

class CartWithItems extends StatefulWidget {
  final String buyerId;
  const CartWithItems({super.key, required this.buyerId});

  @override
  State<CartWithItems> createState() => _CartWithItemsState();
}

class _CartWithItemsState extends State<CartWithItems> {
  bool _isDeleting = false;

  num _getTotalItems(List<QueryDocumentSnapshot> items) =>
      items.fold(0, (sum, item) {
        final quantity = num.tryParse(item['quantity'].toString()) ?? 1;
        return sum + quantity;
      });

  num _getOriginalPrice(List<QueryDocumentSnapshot> items) =>
      items.fold(0, (sum, item) {
        final mrp = num.tryParse(item['mrp'].toString()) ?? 0;
        final quantity = num.tryParse(item['quantity'].toString()) ?? 1;
        return sum + (mrp * quantity);
      });

  num _getFinalPrice(List<QueryDocumentSnapshot> items) =>
      items.fold(0, (sum, item) {
        final sp = num.tryParse(item['sellingPrice'].toString()) ?? 0;
        final quantity = num.tryParse(item['quantity'].toString()) ?? 1;
        return sum + (sp * quantity);
      });

  num _getDiscount(List<QueryDocumentSnapshot> items) =>
      _getOriginalPrice(items) - _getFinalPrice(items);

  Future<void> _updateQuantity(String docId, int newQuantity) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).update({
      'quantity': newQuantity,
    });
  }

  Future<void> _placeOrder(List<QueryDocumentSnapshot> cartItems) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final timestamp = Timestamp.now();
      final totalAmount = _getFinalPrice(cartItems);
      List<Map<String, dynamic>> items = [];

      final orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add({
            'userId': userId,
            'items': items,
            'totalAmount': totalAmount,
            'timestamp': timestamp,
          });
      final orderId = orderRef.id;

      items = cartItems.map((item) {
        final String rawQty = item['quantity'].toString();
        final int cleanQty =
            int.tryParse(RegExp(r'\d+').stringMatch(rawQty) ?? '1') ?? 1;

        return {
          'productName': item['productName'],
          'quantity': cleanQty,
          'sellingPrice': item['sellingPrice'],
          'img': item['img'],
          'unit': item['unit'],
          'status': 'pending',
          'timestamp': timestamp,
          'farmerId': item['farmerId'],
          'userId': userId,
          'orderId': orderId,
        };
      }).toList();

      await orderRef.update({'items': items});

      debugPrint("Attempting to navigate to OrderSuccessPage...");
      // Notify all unique farmers
      final notifiedFarmers = <String>{};

      for (var item in cartItems) {
        final farmerId = item['farmerId'];

        if (!notifiedFarmers.contains(farmerId)) {}
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const DeliveryAddressModal(),
      );

      final batch = FirebaseFirestore.instance.batch();
      for (var item in cartItems) {
        batch.delete(item.reference);
      }
      await batch.commit();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(errorBar("Order failed: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cart')
          .where('buyerId', isEqualTo: widget.buyerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (_isDeleting ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CartEmpty();
        }

        final cartItems = snapshot.data!.docs;

        return Stack(
          children: [
            Scaffold(
              appBar: appBar(context, title: "My Cart"),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final String productName =
                            cartItem['productName'] ?? '';
                        // final int price =
                        //     int.tryParse(cartItem['sellingPrice'].toString()) ??
                        //     0;
                        final String path = cartItem['img'] ?? '';
                        final int quantity =
                            int.tryParse(cartItem['quantity'].toString()) ?? 1;
                        final String unit = cartItem['unit'] ?? 'unit';

                        return Column(
                          children: [
                            ListTile(
                              leading: path.isNotEmpty
                                  ? Image.network(path, width: 80, height: 80)
                                  : Icon(Icons.image_not_supported, size: 40),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    unit.contains("gm") ? unit : "1 $unit",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 14,
                                        ),
                                        onPressed: quantity > 1
                                            ? () => _updateQuantity(
                                                cartItem.id,
                                                quantity - 1,
                                              )
                                            : null,
                                      ),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 14),
                                        onPressed: () => _updateQuantity(
                                          cartItem.id,
                                          quantity + 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() => _isDeleting = true);
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('cart')
                                            .doc(cartItem.id)
                                            .delete();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          successBar(
                                            '$productName removed from cart',
                                          ),
                                        );
                                        setState(() => _isDeleting = false);
                                      } catch (e) {
                                        setState(() => _isDeleting = false);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          errorBar('Failed to remove item'),
                                        );
                                      }
                                    },
                                    child: Icon(Icons.delete_outline, size: 18),
                                  ),
                                ],
                              ),
                            ),
                            if (index < cartItems.length - 1)
                              const Divider(height: 1, thickness: 0.4),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 215, 248, 215),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 188, 188, 188),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Add Coupon',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: 'Enter Coupon Code',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(100, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        summaryRow(
                          label: 'Total Items',
                          value: '${_getTotalItems(cartItems)}',
                        ),
                        summaryRow(
                          label: 'Original Price',
                          value:
                              '₹ ${_getOriginalPrice(cartItems).toStringAsFixed(2)}',
                        ),
                        summaryRow(
                          label: 'Discount',
                          value:
                              '₹ ${_getDiscount(cartItems).toStringAsFixed(2)}',
                        ),
                        const Divider(color: Color.fromARGB(31, 2, 2, 2)),
                        summaryRow(
                          label: 'Final Price',
                          value:
                              '₹ ${_getFinalPrice(cartItems).toStringAsFixed(2)}',
                          isBold: true,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _placeOrder(cartItems);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Future<void> sendNotificationToFarmer(
//   String token,
//   String title,
//   String body, {required String title},
// ) async {
//   const serverKey = 'YOUR_SERVER_KEY';

//   final response = await http.post(
//     Uri.parse('https://fcm.googleapis.com/fcm/send'),
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'key=$serverKey',
//     },
//     body: jsonEncode({
//       'to': token,
//       'notification': {'title': title, 'body': body},
//     }),
//   );

//   debugPrint("FCM Response Status: ${response.statusCode}");
//   debugPrint("FCM Response Body: ${response.body}");
// }

Widget summaryRow({
  required String label,
  required String value,
  bool isBold = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

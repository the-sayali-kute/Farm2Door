import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/farmer_home_page/orders/order_details_page.dart';
import 'package:forms/final_vars.dart';
import 'package:forms/functions.dart';
import 'package:intl/intl.dart';
import 'package:forms/customer_home_page/appbar.dart';
import 'package:forms/customer_home_page/orders/no_orders.dart';

class FarmerOrderPage extends StatelessWidget {
  const FarmerOrderPage({super.key});
  Color statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.lightBlueAccent;
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return const Color.fromARGB(255, 52, 23, 180);
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),

      builder: (context, snapshot) {
        final currentFarmerId = FirebaseAuth.instance.currentUser!.uid;
        final allOrders = snapshot.data!.docs;

        final relevantOrders = allOrders.where((order) {
          final items = List<Map<String, dynamic>>.from(order['items']);
          return items.any((item) => item['farmerId'] == currentFarmerId);
        }).toList();

        if (relevantOrders.isEmpty) {
          return NoOrders(msg: "No orders yet!",showOption:false);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return NoOrders(msg: "No orders yet!",showOption: false,);
        }

        return Scaffold(
          appBar: appBar(context, title: "My Orders"),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: relevantOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = relevantOrders[index];
              final allItems = List<Map<String, dynamic>>.from(order['items']);
              final currentFarmerId = FirebaseAuth.instance.currentUser!.uid;
              final farmerItems = allItems
                  .where((item) => item['farmerId'] == currentFarmerId)
                  .toList();
              final timestamp = order['items'][0]['timestamp'] as Timestamp;
              // debugPrint(order.data().toString());

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID
                      Row(
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Timestamp of order
                      Text(
                        'Placed on: ${formatTimestamp(timestamp)}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<String?>(
                        future: getUserNameFromOrder(
                          order.id,
                        ), // <-- Call your async function here
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Loading...");
                          } else if (snapshot.hasError) {
                            return const Text("Error loading user");
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text("Unknown user");
                          } else {
                            return Row(
                              children: [
                                Text(
                                  'Placed by: ',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: gradient,
                          ),
                          child: TextButton(
                            onPressed: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return OrderDetailsPage(item: farmerItems,orderId:order.id);
                                  },
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(150, 50),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                              "View Details",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


// Row(
                      //   children: [
                      //     const Text(
                      //       'Total:',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 15,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //     Text(
                      //       '₹ ${(order['totalAmount'] as num).toStringAsFixed(2)}',
                      //       style: const TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 16,
                      //         color: Colors.green,
                      //       ),
                      //     ),
                      //   ],
                      // ),
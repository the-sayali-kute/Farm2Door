import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/reusables/functions.dart';
import 'package:intl/intl.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/customer_home_page/orders/no_orders.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Stream<QuerySnapshot> _orderStream;
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        
        .snapshots();
  }

  Future<void> _refreshOrders() async {
    // Force refresh by reassigning the stream and triggering rebuild
    setState(() {
      _loadOrders();
    });
    await Future.delayed(const Duration(seconds: 1)); // Smooth pull effect
  }

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
    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _refreshOrders,
      child: StreamBuilder<QuerySnapshot>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return NoOrders(msg: "You've no orders yet!", showOption: true);
          }

          final orders = snapshot.data!.docs;
          return Scaffold(
            appBar: appBar(context, title: "My Orders"),
            body: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Placed on: ${formatTimestamp(order['timestamp'])}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),
                        ...List.generate((order['items'] as List).length, (i) {
                          final item =
                              (order['items'] as List)[i]
                                  as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['productName'] as String,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  getDisplayUnit(
                                    item['unit'] as String,
                                    item['quantity'],
                                  ),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(
                                      (item['status'] as String)
                                          .trim()
                                          .toLowerCase(),
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (item['status'] as String).trim(),
                                    style: TextStyle(
                                      color: statusColor(
                                        (item['status'] as String)
                                            .trim()
                                            .toLowerCase(),
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹ ${(order['totalAmount'] as num).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

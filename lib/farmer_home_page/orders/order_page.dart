//order_page.dart

import 'package:forms/farmer_home_page/farm2door_components.dart';
import 'package:flutter/material.dart';
import 'package:forms/farmer_home_page/order_screen_components.dart';
import 'package:forms/farmer_home_page/orders/order_screen_components.dart';
import 'package:forms/farmer_home_page/orders/sorting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _sortCriteria = 'Time'; // or 'Distance'
  bool _ascending = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: farm2DoorAppBar('Orders', Icons.online_prediction_rounded),
        body: Column(
          children: [
            _buildSortControls(), // 👈 new widget
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrderList(),
                  _buildOrderList(),
                  _buildOrderList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: _sortCriteria,
            items: const [
              DropdownMenuItem(value: 'Time', child: Text('Sort by Time')),
              DropdownMenuItem(value: 'Distance', child: Text('Sort by Distance')),
            ],
            onChanged: (value) {
              setState(() {
                _sortCriteria = value!;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _ascending = !_ascending;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    Future<List<DocumentSnapshot>> future;

    if (_sortCriteria == 'Time') {
      future = getOrdersSortedByTime(ascending: _ascending);
    } else {
      future = getOrdersSortedByDistance(ascending: _ascending);
    }

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data = orders[index].data() as Map<String, dynamic>;
            return OrderStatusCard(
              orderId: data['orderId'] ?? 'N/A',
              date: formatTimestamp(data['timestamp']),
              statusText: data['status'] ?? '',
              statusColor: getStatusColor(data['status']),
              currentStep: getCurrentStep(data['status']),
            );
          },
        );
      },
    );
  }
}
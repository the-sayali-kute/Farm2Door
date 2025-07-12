
import 'package:forms/farmer_home_page/farm2door_components.dart';
import 'package:flutter/material.dart';
import 'order_screen_components.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: farm2DoorAppBar('Orders', Icons.online_prediction_rounded),
        body: TabBarView(
          children: [
            _buildOrderList(),
            _buildOrderList(),
            _buildOrderList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: const [
        OrderStatusCard(
          orderId: '2324252627',
          date: '25 Nov',
          statusText: 'Confirmed',
          statusColor: Colors.blue,
          currentStep: 1,
        ),
        OrderStatusCard(
          orderId: '2324252627',
          date: '25 Nov',
          statusText: 'Processing',
          statusColor: Colors.green,
          currentStep: 2,
        ),
        OrderStatusCard(
          orderId: '2324252627',
          date: '25 Nov',
          statusText: 'Shipped',
          statusColor: Colors.orange,
          currentStep: 3,
        ),
        OrderStatusCard(
          orderId: '2324252627',
          date: '25 Nov',
          statusText: 'Delivery',
          statusColor: Colors.green,
          currentStep: 4,
        ),
        OrderStatusCard(
          orderId: '2324252627',
          date: '25 Nov',
          statusText: 'Cancelled',
          statusColor: Colors.red,
          currentStep: 4,
        ),
      ],
    );
  }
}

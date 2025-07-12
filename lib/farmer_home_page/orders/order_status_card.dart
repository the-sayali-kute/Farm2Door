import 'package:flutter/material.dart';

class OrderStatusCard extends StatelessWidget {
  final String orderId;
  final String date;
  final String statusText;
  final Color statusColor;
  final int currentStep;

  const OrderStatusCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.statusText,
    required this.statusColor,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Order ID: ',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    children: [
                      TextSpan(
                        text: orderId,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status Slider Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: currentStep / 4,
                  color: statusColor,
                  backgroundColor: statusColor.withOpacity(0.3),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 12),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
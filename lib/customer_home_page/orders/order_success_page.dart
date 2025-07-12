import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/customer_home_page.dart';
import 'package:lottie/lottie.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    // 1. Send notification to farmer
    _sendNotificationToFarmer();

    // 2. Delay to show loading → tick
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showSuccess = true);
      }
    });
  }

  Future<void> _sendNotificationToFarmer() async {
    // Example: You can loop through each item if you want to notify multiple farmers
    await FirebaseFirestore.instance.collection('notifications').add({
      'type': 'order',
      'title': 'New Order Received!',
      'message': 'You have a new order from a buyer.',
      'timestamp': Timestamp.now(),
      'status': 'unread',
      // Add your targeting mechanism
      'farmerId': 'FARMER_ID_HERE',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _showSuccess
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "assets/animations/order_success.json",
                      height: 200,
                      repeat: true,
                      reverse: false,
                      animate: true,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Farmer has been notified with your order!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.maybePop(context);
                        Navigator.push(context,MaterialPageRoute(builder: (context){
                          return CustomerHomePage(snackBarMsg: "");
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Back to Home"),
                    ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      "Placing your order...",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

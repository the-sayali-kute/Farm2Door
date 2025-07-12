// order_screen_components.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestamp) {
  final date = timestamp.toDate();
  return DateFormat('dd MMM yyyy, hh:mm a').format(date); // e.g., "10 Jul 2025, 03:30 PM"
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return Colors.blue;
    case 'processing':
      return Colors.green;
    case 'shipped':
      return Colors.orange;
    case 'delivery':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

int getCurrentStep(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return 1;
    case 'processing':
      return 2;
    case 'shipped':
      return 3;
    case 'delivery':
    case 'delivered':
      return 4;
    case 'cancelled':
      return 4;
    default:
      return 0;
  }
}
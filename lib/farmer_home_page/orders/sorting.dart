//code to fetch orders sorted by timestamp or distance based on user preference
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts degrees to radians
double _deg2rad(double deg) => deg * (pi / 180.0);

/// Calculates distance (in km) between two geo points
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Radius of the earth in km
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

/// 📦 Sort orders by Timestamp
Future<List<DocumentSnapshot>> getOrdersSortedByTime({bool ascending = false}) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .orderBy('timestamp', descending: !ascending)
      .get();

  return snapshot.docs;
}

/// 📦 Sort orders by Distance from farmer (current user) to buyer
Future<List<DocumentSnapshot>> getOrdersSortedByDistance({bool ascending = false}) async {
  final currentUser = FirebaseFirestore.instance.collection('users').doc(
      FirebaseFirestore.instance.app.options.projectId); // replace with actual farmer ID logic
  final currentUserDoc = await currentUser.get();
  final userData = currentUserDoc.data();

  if (userData == null || userData['latitude'] == null || userData['longitude'] == null) {
    return [];
  }

  final farmerLat = userData['latitude'];
  final farmerLng = userData['longitude'];

  final snapshot = await FirebaseFirestore.instance.collection('orders').get();
  final List<DocumentSnapshot> orders = snapshot.docs;

  // Build order list with distance
  final List<MapEntry<DocumentSnapshot, double>> orderDistances = [];

  for (final order in orders) {
    final data = order.data() as Map<String, dynamic>;
    final buyerId = data['buyerId'];

    if (buyerId == null) continue;

    final buyerDoc = await FirebaseFirestore.instance.collection('users').doc(buyerId).get();
    final buyerData = buyerDoc.data();
    if (buyerData == null || buyerData['latitude'] == null || buyerData['longitude'] == null) {
      continue;
    }

    final buyerLat = buyerData['latitude'];
    final buyerLng = buyerData['longitude'];
    final distance = _calculateDistance(farmerLat, farmerLng, buyerLat, buyerLng);

    orderDistances.add(MapEntry(order, distance));
  }

  // Sort by distance
  orderDistances.sort((a, b) =>
      ascending ? a.value.compareTo(b.value) : b.value.compareTo(a.value));

  return orderDistances.map((entry) => entry.key).toList();
}
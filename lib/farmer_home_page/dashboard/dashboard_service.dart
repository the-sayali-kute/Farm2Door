// lib/farmer_dashboard/dashboard_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardData {
  final double revenue;
  final int totalOrders;
  final int pendingItems; // number of pending items for this farmer
  final double avgOrderValue;
  final int activeProducts;
  final int outOfStockProducts;

  DashboardData({
    required this.revenue,
    required this.totalOrders,
    required this.pendingItems,
    required this.avgOrderValue,
    required this.activeProducts,
    required this.outOfStockProducts,
  });
}

/// Fetches dashboard data for the current farmer.
/// NOTE: This does client-side filtering of orders by looking into each order's items array
/// and selecting items where item['farmerId'] == farmerId.
Future<DashboardData> fetchDashboardData({int orderLimit = 1000}) async {
  final farmer = FirebaseAuth.instance.currentUser;
  if (farmer == null) {
    return DashboardData(
      revenue: 0,
      totalOrders: 0,
      pendingItems: 0,
      avgOrderValue: 0,
      activeProducts: 0,
      outOfStockProducts: 0,
    );
  }

  final farmerId = farmer.uid;
  final firestore = FirebaseFirestore.instance;

  // 1) Fetch orders (we fetch all orders and filter client-side)
  //    If you have many orders in prod, consider adding an index or a farmer-specific orders collection.
  final ordersSnapshot = await firestore.collection('orders').get();

  double revenue = 0.0;
  int ordersCount = 0;
  int pendingItemCount = 0;

  final Set<String> ordersThatIncludeFarmer = {};

  for (final doc in ordersSnapshot.docs) {
    final data = doc.data();
    final items = (data['items'] as List?) ?? [];

    bool orderHasFarmerItem = false;
    double orderRevenueForFarmer = 0.0;

    for (final rawItem in items) {
      if (rawItem is Map) {
        final itemFarmerId = rawItem['farmerId'];
        if (itemFarmerId == farmerId) {
          orderHasFarmerItem = true;

          // Status per item
          final status = (rawItem['status'] as String?)?.toLowerCase() ?? '';

          if (status == 'pending') {
            pendingItemCount++;
          }

          // Compute per-item revenue: quantity * sellingPrice (sellingPrice may be string)
          final quantity = (rawItem['quantity'] is num)
              ? (rawItem['quantity'] as num).toDouble()
              : double.tryParse(rawItem['quantity']?.toString() ?? '0') ?? 0.0;

          final sellingPrice = (rawItem['sellingPrice'] is num)
              ? (rawItem['sellingPrice'] as num).toDouble()
              : double.tryParse(rawItem['sellingPrice']?.toString() ?? '0') ?? 0.0;

          // Only count revenue for items where status == completed (or you can count all)
          if (status == 'completed' || status == 'delivered' || status == '') {
            orderRevenueForFarmer += quantity * sellingPrice;
          }
        }
      }
    }

    if (orderHasFarmerItem) {
      ordersThatIncludeFarmer.add(doc.id);
      revenue += orderRevenueForFarmer;
    }
  }

  ordersCount = ordersThatIncludeFarmer.length;

  final avgOrderValue = ordersCount > 0 ? (revenue / ordersCount) : 0.0;

  // 2) Fetch products for this farmer
  final productsSnapshot = await firestore
      .collection('products')
      .where('farmerId', isEqualTo: farmerId)
      .get();

  int activeProducts = 0;
  int outOfStockProducts = 0;

  for (final doc in productsSnapshot.docs) {
    final data = doc.data();
    final presentStock = (data['presentStock'] is num)
        ? (data['presentStock'] as num).toDouble()
        : double.tryParse(data['presentStock']?.toString() ?? '0') ?? 0.0;

    if (presentStock > 0) {
      activeProducts++;
    } else {
      outOfStockProducts++;
    }
  }

  return DashboardData(
    revenue: revenue,
    totalOrders: ordersCount,
    pendingItems: pendingItemCount,
    avgOrderValue: avgOrderValue,
    activeProducts: activeProducts,
    outOfStockProducts: outOfStockProducts,
  );
}

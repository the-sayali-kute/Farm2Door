// lib/farmer_dashboard/business_analytics.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:intl/intl.dart';

/// Usage:
/// - Instantiate RecentActivities() inside your MyBusinessPage body.
/// - Requires fl_chart and intl in pubspec.yaml.

class RecentActivities extends StatefulWidget {
  /// daysToShow determines the window for time-series charts (e.g., 14 for 2 weeks).
  final int daysToShow;
  const RecentActivities({super.key, this.daysToShow = 14});

  @override
  State<RecentActivities> createState() =>
      _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities> {
  bool _loading = true;

  // Aggregated results
  Map<String, double> revenueByDay = {}; // label -> ₹ amount
  Map<String, int> ordersByDay = {}; // label -> number of items (or orders)
  List<_TopProduct> topProductsByRevenue = []; // top 5
  List<_TopProduct> topProductsByQuantity = []; // top 5 by qty
  List<_LowStock> lowStockProducts = [];
  Map<String, double> categoryRevenue = {}; // category -> revenue
  List<_ActivityItem> recentActivity = []; // latest N activity items

  // config
  final int recentActivityLimit = 30;
  final int lowStockThreshold = 5;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      // Prepare day labels (last N days)
      final now = DateTime.now();
      final days = widget.daysToShow;
      final List<DateTime> dayPoints = List.generate(days, (i) {
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: days - 1 - i));
      });
      final List<String> dayLabels = dayPoints
          .map((d) => DateFormat('dd MMM').format(d))
          .toList();

      // Initialize maps with zeros to guarantee axis labels consistent
      final Map<String, double> revByDay = {for (var l in dayLabels) l: 0.0};
      Map<String, int> ordersByDay = {for (var l in dayLabels) l: 0};

      // We'll need product metadata: productName -> {category, presentStock}
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('farmerId', isEqualTo: uid)
          .get();

      final Map<String, Map<String, dynamic>> productMeta = {};
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final name = (data['productName'] ?? '').toString();
        productMeta[name] = {
          'category': data['category'] ?? 'Uncategorized',
          'presentStock': (data['presentStock'] is num)
              ? data['presentStock']
              : double.tryParse('${data['presentStock'] ?? 0}') ?? 0,
          'img': data['img'],
          'productId': doc.id,
        };
      }

      // Prepare aggregators
      final Map<String, double> productRevenueAggregator = {};
      final Map<String, double> productQuantityAggregator = {};
      final Map<String, double> categoryRevenueAgg = {};
      final List<_ActivityItem> activities = [];

      // Fetch orders - client-side aggregate
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        final List<dynamic> items = (data['items'] ?? []) as List<dynamic>;

        // order-level timestamp fallback
        final orderTimestamp = (data['timestamp'] is Timestamp)
            ? (data['timestamp'] as Timestamp).toDate()
            : null;

        for (var rawItem in items) {
          if (rawItem is! Map) continue;
          if (rawItem['farmerId'] != uid) continue;

          // Determine timestamp for this item (item-level preferred)
          DateTime itemTs;
          if (rawItem['timestamp'] is Timestamp) {
            itemTs = (rawItem['timestamp'] as Timestamp).toDate();
          } else if (orderTimestamp != null) {
            itemTs = orderTimestamp;
          } else {
            itemTs = DateTime.now();
          }

          final dayLabel = DateFormat(
            'dd MMM',
          ).format(DateTime(itemTs.year, itemTs.month, itemTs.day));
          if (revByDay.containsKey(dayLabel)) {
            // accumulate revenue for day
            final price =
                double.tryParse(rawItem['sellingPrice']?.toString() ?? '0') ??
                0.0;
            final qty = (rawItem['quantity'] is num)
                ? (rawItem['quantity'] as num).toDouble()
                : double.tryParse('${rawItem['quantity'] ?? 0}') ?? 0.0;
            final itemRevenue = price * qty;
            revByDay[dayLabel] = (revByDay[dayLabel] ?? 0) + itemRevenue;

            ordersByDay[dayLabel] = (ordersByDay[dayLabel] ?? 0) + 1;
          } // else outside window, ignore for chart

          // aggregate by product
          final prodName = rawItem['productName']?.toString() ?? 'Unknown';
          final pPrice =
              double.tryParse(rawItem['sellingPrice']?.toString() ?? '0') ??
              0.0;
          final pQty = (rawItem['quantity'] is num)
              ? (rawItem['quantity'] as num).toDouble()
              : double.tryParse('${rawItem['quantity'] ?? 0}') ?? 0.0;
          final rev = pPrice * pQty;

          productRevenueAggregator[prodName] =
              (productRevenueAggregator[prodName] ?? 0) + rev;
          productQuantityAggregator[prodName] =
              (productQuantityAggregator[prodName] ?? 0) + pQty;

          // category revenue (map productName->category via productMeta, fallback 'Uncategorized')
          final category =
              (productMeta[prodName]?['category'] ?? 'Uncategorized')
                  .toString();
          categoryRevenueAgg[category] =
              (categoryRevenueAgg[category] ?? 0) + rev;

          // recent activity - keep timestamp and relevant text
          activities.add(
            _ActivityItem(
              timestamp: itemTs,
              title:
                  "${pQty.toStringAsFixed(pQty.truncateToDouble() == pQty ? 0 : 2)} × $prodName",
              subtitle:
                  "₹${rev.toStringAsFixed(1)} — ${rawItem['status'] ?? ''}",
              productName: prodName,
              imageUrl: productMeta[prodName]?['img'],
              location: null,
            ),
          );
        }
      }

      // Compose top lists
      final topByRevenue = productRevenueAggregator.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topByQuantity = productQuantityAggregator.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topRevenueList = topByRevenue
          .take(5)
          .map(
            (e) => _TopProduct(
              name: e.key,
              revenue: e.value,
              quantity: productQuantityAggregator[e.key] ?? 0,
            ),
          )
          .toList();
      final topQtyList = topByQuantity
          .take(5)
          .map(
            (e) => _TopProduct(
              name: e.key,
              revenue: productRevenueAggregator[e.key] ?? 0,
              quantity: e.value,
            ),
          )
          .toList();

      // low-stock: use productMeta map (only farmer's products)
      final lowStock = productMeta.entries
          .where(
            (e) =>
                (e.value['presentStock'] is num
                    ? (e.value['presentStock'] as num).toDouble()
                    : double.tryParse('${e.value['presentStock']}') ?? 0) <=
                lowStockThreshold,
          )
          .map(
            (e) => _LowStock(
              productName: e.key,
              presentStock: (e.value['presentStock'] is num)
                  ? (e.value['presentStock'] as num).toDouble()
                  : double.tryParse('${e.value['presentStock']}') ?? 0,
              productId: e.value['productId']?.toString() ?? '',
            ),
          )
          .toList();

      // sort activities by timestamp desc and limit
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final recent = activities.take(recentActivityLimit).toList();

      setState(() {
        revenueByDay = revByDay;
        ordersByDay = ordersByDay;
        topProductsByRevenue = topRevenueList;
        topProductsByQuantity = topQtyList;
        lowStockProducts = lowStock;
        categoryRevenue = categoryRevenueAgg;
        recentActivity = recent;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint("Error in analytics load: $e\n$st");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "My Business Details"),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Recent Activity",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRecentActivityList(),
              ],
            ),
    );
  }

  // -----------------------
  // Charts & widgets
  // -----------------------

  Widget _buildRevenueLineChart() {
    final labels = revenueByDay.keys.toList();
    final values = labels.map((k) => revenueByDay[k] ?? 0.0).toList();
    final maxY = max(1.0, (values.isEmpty ? 0 : values.reduce(max)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Revenue (last ${widget.daysToShow} days)",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: (maxY * 1.2),
              gridData: FlGridData(
                show: true,
                horizontalInterval: max(1, maxY / 4),
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: Colors.grey.shade200, strokeWidth: 0.6),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      final txt = labels[i]; // "dd MMM"
                      // show only day number for compactness
                      final parts = txt.split(' ');
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          parts.first,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      "₹",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: max(1, (maxY / 4)),
                    getTitlesWidget: (v, meta) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < values.length; i++)
                      FlSpot(i.toDouble(), values[i]),
                  ],
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.green,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "X: Date    Y: Revenue (₹)",
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildOrdersBarChart() {
    final labels = ordersByDay.keys.toList();
    final values = labels.map((k) => ordersByDay[k] ?? 0).toList();
    final maxY = max(1, values.isEmpty ? 0 : values.reduce(max));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Orders Over Time",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: Colors.grey.shade200, strokeWidth: 0.6),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text("Date"),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        labels[i].split(' ').first,
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    interval: 1,
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      "Count",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: max(1, (maxY / 4).toDouble()),
                    getTitlesWidget: (v, meta) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              barGroups: [
                for (int i = 0; i < values.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: values[i].toDouble(),
                        color: Colors.blue.shade400,
                        width: 10,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top Selling Products (by revenue)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (topProductsByRevenue.isEmpty)
              const Text(
                "No product sales yet",
                style: TextStyle(color: Colors.grey),
              )
            else
              ...topProductsByRevenue.map((p) {
                final maxRevenue = topProductsByRevenue.isNotEmpty
                    ? topProductsByRevenue.first.revenue
                    : 1.0;
                final widthFraction = maxRevenue > 0
                    ? (p.revenue / maxRevenue)
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: widthFraction,
                              child: Container(
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "₹${p.revenue.toStringAsFixed(1)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              "Top by quantity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (topProductsByQuantity.isEmpty)
              const Text(
                "No product sales yet",
                style: TextStyle(color: Colors.grey),
              )
            else
              ...topProductsByQuantity.map(
                (p) => ListTile(
                  dense: true,
                  title: Text(p.name),
                  trailing: Text("${p.quantity.toStringAsFixed(0)} pcs"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Low-stock products",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (lowStockProducts.isEmpty)
              const Text(
                "All stocked well",
                style: TextStyle(color: Colors.grey),
              )
            else
              ...lowStockProducts.map(
                (p) => ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: p.presentStock <= 0
                        ? Colors.red
                        : Colors.orange,
                    child: Text(p.presentStock.toStringAsFixed(0)),
                  ),
                  title: Text(p.productName),
                  subtitle: Text("Stock: ${p.presentStock}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // navigate to edit product page if you have one
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Edit"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPie() {
    if (categoryRevenue.isEmpty) {
      return _emptyCard("No category data yet");
    }
    final entries = categoryRevenue.entries.toList();
    final total = entries.fold<double>(0.0, (s, e) => s + e.value);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Category-wise Revenue",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: entries.map((e) {
                                final perc = total > 0
                                    ? (e.value / total)
                                    : 0.0;
                                final color = _colorForString(e.key);
                                return PieChartSectionData(
                                  title: "${(perc * 100).toStringAsFixed(0)}%",
                                  value: e.value,
                                  color: color,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: entries.map((e) {
                        final color = _colorForString(e.key);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(width: 12, height: 12, color: color),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e.key)),
                              Text("₹${e.value.toStringAsFixed(0)}"),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    if (recentActivity.isEmpty) return _emptyCard("No recent activity");

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: recentActivity.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final a = recentActivity[index];
          return ListTile(
            leading: a.imageUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(a.imageUrl!))
                : CircleAvatar(
                    child: Text(a.title.isNotEmpty ? a.title[0] : '?'),
                  ),
            title: Text(a.title),
            subtitle: Text(a.subtitle),
            trailing: Text(
              DateFormat('dd MMM, hh:mm a').format(a.timestamp),
              style: const TextStyle(fontSize: 11),
            ),
          );
        },
      ),
    );
  }

  Color _colorForString(String s) {
    final colors = [
      Colors.teal,
      Colors.purple,
      Colors.orange,
      Colors.blue,
      Colors.brown,
      Colors.green,
      Colors.indigo,
    ];
    final h = s.codeUnits.fold(0, (p, e) => p + e);
    return colors[h % colors.length];
  }

  Widget _emptyCard(String msg) {
    return Card(
      child: SizedBox(
        height: 80,
        child: Center(
          child: Text(msg, style: const TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}

// small helper classes
class _TopProduct {
  final String name;
  final double revenue;
  final double quantity;
  _TopProduct({
    required this.name,
    required this.revenue,
    required this.quantity,
  });
}

class _LowStock {
  final String productName;
  final double presentStock;
  final String productId;
  _LowStock({
    required this.productName,
    required this.presentStock,
    required this.productId,
  });
}

class _ActivityItem {
  final DateTime timestamp;
  final String title;
  final String subtitle;
  final String productName;
  final String? imageUrl;
  final String? location;
  _ActivityItem({
    required this.timestamp,
    required this.title,
    required this.subtitle,
    required this.productName,
    this.imageUrl,
    this.location,
  });
}

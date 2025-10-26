  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:fl_chart/fl_chart.dart';
  import 'package:forms/widgets/appbar.dart';

  class MyBusinessPage extends StatefulWidget {
    const MyBusinessPage({super.key});

    @override
    State<MyBusinessPage> createState() => _MyBusinessPageState();
  }

  class _MyBusinessPageState extends State<MyBusinessPage> {
    bool _loading = true;
    double totalRevenue = 0;
    int totalOrders = 0;
    int pendingOrders = 0;
    int completedOrders = 0;
    int acceptedOrders = 0;
    int rejectedOrders = 0;
    double avgOrderValue = 0;
    Map<String, double> topProducts = {};
    Map<String, double> weeklyRevenue = {};

    @override
    void initState() {
      super.initState();
      _fetchBusinessData();
    }

    Future<void> _fetchBusinessData() async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      setState(() => _loading = true);

      try {
        // 1️⃣ Fetch farmer stats from 'users'
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        double revenue = (userDoc['revenue'] ?? 0).toDouble();
        int totalOrders = (userDoc['orders'] ?? 0).toInt();

        // 2️⃣ Initialize counters
        int pending = 0;
        int accepted = 0;
        int completed = 0;
        int rejected = 0;
        Map<String, double> productSales = {};
        Map<String, double> weeklyMap = {};

        // 3️⃣ Loop through all order items
        final ordersSnapshot =
            await FirebaseFirestore.instance.collection('orders').get();

        for (var doc in ordersSnapshot.docs) {
          final data = doc.data();
          final List<dynamic> items = data['items'] ?? [];

          for (var item in items) {
            if (item['farmerId'] == uid) {
              final status = (item['status'] ?? '').toLowerCase();

              if (status == 'pending') pending++;
              if (status == 'accepted') accepted++;
              if (status == 'completed' || status == 'delivered') completed++;
              if (status == 'rejected') rejected++;

              // Track product sales
              String productName = item['productName'] ?? 'Unknown';
              double price =
                  double.tryParse(item['sellingPrice'].toString()) ?? 0;
              double quantity = (item['quantity'] ?? 0).toDouble();
              double totalProductRevenue = price * quantity;

              productSales[productName] =
                  (productSales[productName] ?? 0) + totalProductRevenue;

              // Track weekly revenue
              if (item['timestamp'] != null && item['timestamp'] is Timestamp) {
                DateTime ts = (item['timestamp'] as Timestamp).toDate();
                String dayLabel = DateFormat("dd MMM").format(ts);
                weeklyMap[dayLabel] =
                    (weeklyMap[dayLabel] ?? 0) + totalProductRevenue;
              }
            }
          }
        }

        final sortedProducts = Map.fromEntries(
          productSales.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)),
        );

        setState(() {
          totalRevenue = revenue;
          this.totalOrders = totalOrders;
          pendingOrders = pending;
          acceptedOrders = accepted;
          completedOrders = completed;
          rejectedOrders = rejected;
          avgOrderValue = totalOrders > 0 ? revenue / totalOrders : 0;
          topProducts = sortedProducts;
          weeklyRevenue = weeklyMap;
          _loading = false;
        });
      } catch (e) {
        debugPrint("Error fetching business data: $e");
        setState(() => _loading = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: appBar(context, title: "My Business"),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchBusinessData,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summaryCard(),
                    const SizedBox(height: 16),
                    _orderStatusCard(),
                    const SizedBox(height: 16),
                    _revenueChartCard(),
                    const SizedBox(height: 16),
                    _topProductsCard(),
                  ],
                ),
              ),
      );
    }

    // 🧩 Summary Card
    Widget _summaryCard() {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricTile("Revenue", "₹${totalRevenue.toStringAsFixed(1)}",
                  Icons.currency_rupee),
              _metricTile("Orders", "$totalOrders", Icons.shopping_bag_outlined),
              _metricTile("Avg Value", "₹${avgOrderValue.toStringAsFixed(1)}",
                  Icons.bar_chart_outlined),
            ],
          ),
        ),
      );
    }

    Widget _metricTile(String title, String value, IconData icon) {
      return Column(
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      );
    }

    // 📊 Order Status Breakdown
    Widget _orderStatusCard() {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Order Status Breakdown",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _statusChip("Pending", pendingOrders, Colors.orange),
                  _statusChip("Accepted", acceptedOrders, Colors.blue),
                  _statusChip("Completed", completedOrders, Colors.green),
                  _statusChip("Rejected", rejectedOrders, Colors.red),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _statusChip(String label, int count, Color color) {
      return Chip(
        label: Text(
          "$label: $count",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
    }

    // 📈 Weekly Revenue Chart
    Widget _revenueChartCard() {
      if (weeklyRevenue.isEmpty) {
        return _emptyCard("No revenue data yet");
      }

      final sortedEntries = weeklyRevenue.entries.toList()
        ..sort((a, b) => DateFormat("dd MMM")
            .parse(a.key)
            .compareTo(DateFormat("dd MMM").parse(b.key)));

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Weekly Revenue",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: Colors.grey.shade300, strokeWidth: 0.5),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300, width: 0.8),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        axisNameWidget: const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text("Date",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, _) {
                            int i = value.toInt();
                            if (i < 0 || i >= sortedEntries.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              sortedEntries[i].key.split(" ").first,
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Text("₹ Revenue",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: 100,
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.green,
                        dotData: const FlDotData(show: false),
                        spots: [
                          for (int i = 0; i < sortedEntries.length; i++)
                            FlSpot(i.toDouble(), sortedEntries[i].value),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 🥇 Top Products
    Widget _topProductsCard() {
      if (topProducts.isEmpty) return _emptyCard("No product data yet");

      final top3 = topProducts.entries.take(3).toList();

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Top Selling Products",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              for (var e in top3)
                ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.green),
                  title: Text(e.key,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text("₹${e.value.toStringAsFixed(1)}"),
                ),
            ],
          ),
        ),
      );
    }

    // 🪶 Empty Placeholder
    Widget _emptyCard(String msg) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text(msg,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ),
        ),
      );
    }
  }

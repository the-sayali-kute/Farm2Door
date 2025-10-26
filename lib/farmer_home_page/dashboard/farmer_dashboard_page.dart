// lib/farmer_dashboard/farmer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:forms/farmer_home_page/dashboard/business_analytics.dart';
import 'dashboard_service.dart';
import 'package:lottie/lottie.dart';
import 'my_business_page.dart';
import 'package:forms/widgets/appbar.dart';

class FarmerDashboardPage extends StatefulWidget {
  const FarmerDashboardPage({super.key});

  @override
  State<FarmerDashboardPage> createState() => _FarmerDashboardPageState();
}

class _FarmerDashboardPageState extends State<FarmerDashboardPage> {
  bool _loading = true;
  DashboardData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await fetchDashboardData();
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading dashboard: $e");
      setState(() => _loading = false);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Dashboard"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Lottie.asset(
              "assets/animations/growth.json",
              height: 200,
              repeat: true,
              reverse: false,
              animate: true,
            ),
            const SizedBox(height: 30),
            // Original ListTile card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.dashboard_rounded, color: Colors.white),
                ),
                title: const Text(
                  "My Business Summary",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "See your total earnings, orders, and top products at a glance.",
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyBusinessPage()),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // New Business Analytics widget card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.insights_rounded, color: Colors.white),
                ),
                title: const Text(
                  "Sales & Product Insights",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "Track your daily sales trend and watch your stock levels.",
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BusinessAnalyticsWidget(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.history_rounded, color: Colors.white),
                ),
                title: const Text(
                  "Recent Orders",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "Keep track of your latest customer orders and their status.",
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BusinessAnalyticsWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

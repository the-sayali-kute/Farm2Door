import 'package:flutter/material.dart';
import 'package:forms/farmer_home_page/farmer_home_page.dart';
import 'package:forms/farmer_home_page/orders/order_page.dart';
import 'package:forms/farmer_home_page/profile_page.dart';
import 'package:forms/farmer_home_page/update_page.dart';

class FarmerMainPage extends StatefulWidget {
  const FarmerMainPage({super.key});

  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
  int currentPage = 0;
  late List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _initialize(); // 🔁 Call async setup

  }

  Future<void> _initialize() async {
    
      pages = [FarmerHomePage() ,FarmerOrderPage(), UpdatePage()];
    
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: pages.isEmpty
            ? Center(child: CircularProgressIndicator())
            : IndexedStack(index: currentPage, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedIconTheme: IconThemeData(size: 30),
        selectedLabelStyle: TextStyle(fontSize: 12),
        selectedItemColor: Colors.lightGreen,
        unselectedItemColor: Colors.grey,
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        iconSize: 35,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: "Updates",
          ),
        ],
      ),
    );
  }
}
  Widget containerCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(children: children),
    );
  }



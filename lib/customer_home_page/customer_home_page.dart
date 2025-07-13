import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forms/customer_home_page/cart/cart_page.dart';
import 'package:forms/customer_home_page/orders/order_page.dart';
import 'package:forms/customer_home_page/product_list.dart';
import 'package:forms/reusables/functions.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key, required this.snackBarMsg});
  final String snackBarMsg;

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String path = "";
  int currentPage = 0;
  late List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _initialize(); // 🔁 Call async setup

  }

  Future<void> _initialize() async {
    // path = await addToCart(path: "", totalCartItems: 0);
    setState(() {
      pages = [ProductList(), OrderPage(), CartPage()];
      // Show the snackbar *after* the build method runs
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.snackBarMsg.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(successBar(widget.snackBarMsg));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //a Flutter widget used to intercept the device’s back button (on Android). It lets you override what happens when the user tries to leave the current screen.
    return PopScope(
      canPop: false,// Disables the default pop behavior (so user can't go back to login).
      onPopInvokedWithResult: (didPop, result){
        if(!didPop){
           // If the system back button was pressed
          SystemNavigator.pop();// exit the app
        }
      },
      child: Scaffold(
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
              icon: Icon(Icons.shopping_cart_outlined),
              label: "Cart",
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.person),
            //   label: "My Profile",
            // ),
          ],
        ),
      ),
    );
  }
}

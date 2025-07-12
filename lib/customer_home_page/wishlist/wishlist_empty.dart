import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/customer_home_page.dart';
import 'package:lottie/lottie.dart';

class WishlistEmpty extends StatelessWidget {
  const WishlistEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Container(
              width: 200,
              height: 180,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(
                  236,
                  248,
                  238,
                  1,
                ), // light green background
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Lottie.asset(
                "assets/animations/empty_wishlist.json",
                height: 200,
                repeat: true,
                reverse: false,
                animate: true,
              ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            'Keep track of what you love',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Add items you love so you can find them easily later.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CustomerHomePage(snackBarMsg: "",)),
                );
              },
              child: Text(
                'Browse Products',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

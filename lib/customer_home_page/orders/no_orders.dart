import 'package:flutter/material.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/customer_home_page/customer_home_page.dart';
import 'package:lottie/lottie.dart';

class NoOrders extends StatelessWidget {
  final String msg;
  final bool showOption;
  final bool showAppbar;
  const NoOrders({super.key,required this.msg,required this.showOption,this.showAppbar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar:showAppbar ? 
       appBar(context,title: "My Orders"):null,
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
                "assets/animations/no_orders.json",
                height: 200,
                repeat: true,
                reverse: false,
                animate: true,
              ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          // Text('Opps !', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 5),
          Text(
            'No orders yet!',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 40),
          if(showOption)
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

import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/customer_home_page.dart';
import 'package:forms/farmer_home_page/farmer_main_page.dart';

class LoggedInUserLandingPage extends StatefulWidget {
  final String role;
  const LoggedInUserLandingPage({super.key, required this.role});

  @override
  State<LoggedInUserLandingPage> createState() =>
      _LoggedInUserLandingPageState();
}

class _LoggedInUserLandingPageState extends State<LoggedInUserLandingPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return; // Prevents crash if widget was disposed
        if (widget.role == "farmer") {
          debugPrint("User is farmer. so navigating to farmer's home screen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FarmerMainPage()),
          );
        } else {
          debugPrint("User is buyer. so navigating to buyer's home screen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerHomePage(snackBarMsg: ""),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Your Direct Link to Local Farmers",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*class LoggedInUserLandingPage extends StatefulWidget {
  const LoggedInUserLandingPage({super.key});

  @override
  State<LoggedInUserLandingPage> createState() =>
      _LoggedInUserLandingPageState();
}

class _LoggedInUserLandingPageState extends State<LoggedInUserLandingPage> {
  @override
  void initState() {
    super.initState();
    // Delay of 1 second, then navigate
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustomerHomePage(snackBarMsg: "")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/3.jpeg"),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Farm2Door",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Your Direct Link to Local Farmers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}*/

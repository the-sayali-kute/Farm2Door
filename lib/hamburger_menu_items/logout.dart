import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/app_startup/landing_page.dart';
import 'package:forms/reusables/final_vars.dart';
import 'package:forms/reusables/functions.dart';
import 'package:lottie/lottie.dart';

class LogOut extends StatelessWidget {
  const LogOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: "Nunito",
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset(
                "assets/animations/logOut.json",
                height: 200,
                repeat: true,
                reverse: false,
                animate: true,
              ),
              const SizedBox(height: 30),
              Text(
                "Logging out?",
                style: const TextStyle(
                  fontSize: 20,
                  height: 2.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Thanks for supporting local farmers! \nCome back soon for more fresh picks.",
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  logoutUser(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
                ),
                child: const Text("Log Out",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// if successBar/errorBar are here

Future<void> logoutUser(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    // ✅ Navigate to LandingPage and clear the navigation stack completely
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LandingPage()),
      (route) => false,
    );

    // ✅ Show success feedback after a short delay for smooth transition
    Future.delayed(const Duration(milliseconds: 300), () {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        successBar("Logged out successfully."),
      );
    });
  } catch (e) {
    debugPrint("Logout error: $e");
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      errorBar("Logout failed. Please try again."),
    );
  }
}

// Future<void> logoutUser(BuildContext context) async {
//   try {
//     await FirebaseAuth.instance.signOut();

//     // Pop all routes until root so the StreamBuilder can rebuild properly
//     // ignore: use_build_context_synchronously
//     Navigator.of(context).popUntil((route) => route.isFirst);

//     // Optional: Show feedback using a delay
//     Future.delayed(Duration(milliseconds: 500), () {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         successBar("Logged out successfully."),
//       );
//     });
//   } catch (e) {
//     debugPrint("Logout error: $e");
//     // ignore: use_build_context_synchronously
//     ScaffoldMessenger.of(context).showSnackBar(
//       errorBar("Logout failed. Please try again."),
//     );
//   }
// }


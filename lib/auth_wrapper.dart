import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/landing_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        debugPrint("Current user: user");
        // if (user == null) {
          // debugPrint("user is not logged in, navigating to landing page.");
          return LandingPage(); // Not logged in
        // }

        // debugPrint(
        //   "user is logged in, navigating to logged in user's landing page.",
        // );
        // return FutureBuilder<DocumentSnapshot>(
          // future: FirebaseFirestore.instance
          //     .collection("users")
          //     .doc(user.uid)
          //     .get(),
          // builder: (context, userSnapshot) {
          //   if (userSnapshot.connectionState == ConnectionState.waiting) {
          //     debugPrint("Trying to figure out which role user has");
          //     return const Center(child: CircularProgressIndicator());
          //   }

          //   if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          //     return const Scaffold(
          //       body: Center(child: Text("⚠ User profile not found.")),
          //     );
          //   }

            // final role = (userSnapshot.data!['role'] ?? '')
            //     .toString()
            //     .toLowerCase();
            // debugPrint("user has $role role, navigating to that page");

            // if (role == "farmer") {
            //   debugPrint(
            //     "User is farmer. so navigating to farmer's home screen",
            //   );
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const FarmerMainPage(),
            //       ),
            //     );
            //   });
            // } else {
            //   debugPrint("User is buyer. so navigating to buyer's home screen");
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>
            //             const CustomerHomePage(snackBarMsg: ""),
            //       ),
            //     );
            //   });
            // }

            // return const Scaffold(body: Center(child: Text("⚠ error.")));
          // },
        // );
      },
    );
  }
}

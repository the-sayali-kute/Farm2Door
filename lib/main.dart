import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forms/customer_home_page/customer_home_page.dart';
import 'package:forms/farmer_home_page/farmer_main_page.dart';
import 'package:forms/firebase_options.dart';
import 'package:forms/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrintGestureArenaDiagnostics = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Nunito",
        useMaterial3: true,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
          bodyMedium: TextStyle(fontSize: 15),
          titleMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(fontSize: 10),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(102, 200, 143, 1),
          primary: Color.fromRGBO(142, 231, 179, 1),
        ),
      ),
      // authStateChanges() returns stream of users that can be null. It's benefit is that it is a stream - a continuous real time v
      // value which updates whenever the user is sign in or sign out, this implementation is async. So, whenever user changes we've real
      // time updates, based on that appropriate page is loaded. As soon as user logs out it renders landing_page, without any manual
      // programming.
      home:StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // if (snapshot.data != null) {
          //   return const MyHomePage();
          // }
          return LandingPage();
        },
      ),
    );
  }
}

// StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final user = snapshot.data;

//           // If user is not logged in → show LandingPage
//           if (user == null) {
//             return LandingPage();
//           }

      //     // ✅ User is logged in → fetch role and show correct landing page
      //     return FutureBuilder<DocumentSnapshot>(
      //       future: FirebaseFirestore.instance
      //           .collection("users")
      //           .doc(user.uid)
      //           .get(),
      //       builder: (context, userSnapshot) {
      //         if (userSnapshot.connectionState == ConnectionState.waiting) {
      //           return const Center(child: CircularProgressIndicator());
      //         }

      //         if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
      //           return Scaffold(
      //             body: Center(child: Text("⚠ User profile not found.")),
      //           );
      //         }

      //         final data = userSnapshot.data!.data() as Map<String, dynamic>;
      //         final role = (data['role'] ?? '').toString().toLowerCase();

      //         return LoggedInUserLandingPage(role:role);
      //       },
      //     );
      //   },
      // ),

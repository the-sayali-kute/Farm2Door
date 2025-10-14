import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forms/app_startup/splash_screen.dart';
import 'firebase_options.dart';

//notifications
// 1. When farmer adds a product -> notification to farmer & the customer too
// 2. When farmer receives a new order
// 3. When farmer accepts/rejects/completes order -> notification to customer
// 4.
//
//
String serverKey = "ya29.c.c0ASRK0GZWbjFh6e1kBAnxTnwOb1uckGsyMViNf4Hl38g3k-0H_A5YzgZhZXIpYdQBcWr0owiV_Ybo86t1WTi5cif-A29ardOOFqmtc3t9xlHi80rH80cwVAZK1Du0SFg-soq4ll5KmMjpAqw7nGf8EWKON-600ncv2Z3FtOraMyp4xno57CIL8coY_T77Vziz6jkA3Rzg4HXAGU7SvLo3TrjxSjK8ChiGBGNzMblIwoYzXuM7F0LKJYGyjlikkZJolPgcpfzEof7ns6CiZsmaKsVNao0CA9YNyoU1EEN8RpOKnt5gBsvst9YUP6378xNhBWuJ89n4dcT8yUksblvyIrCd0__TwiGO1PGqDJbXwsGJyFEJouls77tTiQXLDwL391Pmo0ju9YZemX7tQeZpXakg2IrrqcY4pRu57a2218-43vfgbaF69uIahgJtVb-hg5wI0pS4qi-c24bFpwxfau9zgtqzmx3p-uXJ0vojaByX1iu26QplWW_f1vZyJuynnlxhBd79U8uukk67xwye0779j1d0rd6gyujYgejpbO-ZjVqzOvObY7i0Y-mJbBROsccJ8nBYmc1RddMRi7cBsvSx3sfsSW3Bl46S3UFWidzi9w-0baFk-VBsr1QBfUV934YIqZgpfQegaSXmYWvswe24kOxWk2gQxq052vdUazX1duqt1ZIeOx24Vql91ZlgSbaQkvnqZsbzdsrIkwpX7qsQguyevlkfV0cRm7RbSv_ncls7XeXFtY3Q9IyjrYzVwMaXRu_Un8x6uvIasshcYB8BSxOZYYmueF3wJcJgVRc3vvWo0eYglnlfka-etM0U-i4Uq1Vwi_Y_WaXajb0024tbbgi0qfe0qxmwleba3s6qsiQpQwg9Iiy6h4-6pc74kf8ViazvZl16a8hbgFVUezQ4rpgMmbouBhIWtupX2cd7OUI8V4Mw";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrintGestureArenaDiagnostics = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Nunito",
        useMaterial3: true,
        textTheme: const TextTheme(
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
      home: SplashScreen(),
    );
  }
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:forms/firebase_options.dart';
// import 'package:forms/landing_page.dart';
// import 'package:forms/logged_in_user_landing_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   debugPrintGestureArenaDiagnostics = false;
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: "Nunito",
//         useMaterial3: true,
//         textTheme: TextTheme(
//           titleLarge: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
//           bodyMedium: TextStyle(fontSize: 15),
//           titleMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//           titleSmall: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
//           bodySmall: TextStyle(fontSize: 10),
//         ),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Color.fromRGBO(102, 200, 143, 1),
//           primary: Color.fromRGBO(142, 231, 179, 1),
//         ),
//       ),
//       home: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.data != null) {
//             return const LoggedInUserLandingPage(role: 'farmer');
//           }
//           return const LandingPage();
//         },
//       ),

      // authStateChanges() returns stream of users that can be null. It's benefit is that it is a stream - a continuous real time v
      // value which updates whenever the user is sign in or sign out, this implementation is async. So, whenever user changes we've real
      // time updates, based on that appropriate page is loaded. As soon as user logs out it renders landing_page, without any manual
      // programming.
      // home:StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     // if (snapshot.data != null) {
      //     //   return const MyHomePage();
      //     // }
      //     return LandingPage();
      //   },
      // ),
//     );
//   }
// }

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

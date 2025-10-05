// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/authentication/login_form.dart';
import 'package:forms/reusables/functions.dart';
import 'package:geolocator/geolocator.dart';

// import 'package:firebase_core/firebase_core.dart';
Future<void> createUserWithEmailAndPassword({
  required String email,
  required String password,
  required String name,
  required String phone,
  required String role,
  // required String address,
  required BuildContext context,
  int? deliveryRadius,
}) async {
  try {
    final userCredential = await FirebaseAuth.instance
    .createUserWithEmailAndPassword(email: email, password: password);
final User user = userCredential.user!;
final uid = user.uid;

// Fetch location
Position? position = await fetchLocation();

// Build user map
final userMap = {
  "name": name,
  "email": email,
  "phone": phone,
  // "address": address,
  "role": role,
  "password": password,
  "latitude": position?.latitude,
  "longitude": position?.longitude,
  "createdAt": FieldValue.serverTimestamp(),
};

if (role.toLowerCase() == "farmer") {
  userMap["revenue"] = 0;
  userMap["orders"] = 0;
  if (deliveryRadius != null) {
    userMap["deliveryRadius"] = deliveryRadius;
  }
}

// Save to Firestore
await FirebaseFirestore.instance.collection('users').doc(uid).set(userMap);

debugPrint("✅ User profile saved to Firestore for UID: $uid");
showLoadingDialog(context);
Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginForm()));
Navigator.of(context).maybePop();

  } on FirebaseAuthException catch (e) {
    debugPrint("⚠️ ${e.message}");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(e.message ?? 'Registration failed')),
    // );
  }
}

// Future<void> createUserWithEmailAndPassword({
//   required String email,
//   required String password,
//   required String name,
//   required String phone,
//   required String role,
//   required String address,
//   required BuildContext context,
// }) async {
//   try {
//     final userCredential = await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(email: email, password: password);

//     final uid = userCredential.user!.uid;

//     final userDocRef = FirebaseFirestore.instance.collection("users").doc(uid);
//     final userDoc = await userDocRef.get();

//     if (!userDoc.exists) {
//       await userDocRef.set({
//         "name": name,
//         "email": email,
//         "phone": phone,
//         "role": role,
//         "password": password,
//         "address": address,
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//     }

//     debugPrint("✅ User profile saved to Firestore for UID: $uid");
//   } on FirebaseAuthException catch (e) {
//     debugPrint("⚠️ ${e.message}");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(e.message ?? 'Registration failed')),
//     );
//   }
// }

Future<Map<String, dynamic>> loginWithEmailPassWord(
  String email,
  String password,
) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    try {
      Position? position = await fetchLocation()
          .timeout(const Duration(seconds: 10));

      if (position != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
              "latitude": position.latitude,
              "longitude": position.longitude,
            }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("⚠ Location update skipped: $e");
    }

    return {"success": true, "message": "Login Successful"};
  } on FirebaseAuthException catch (e) {
    debugPrint(e.message);
    return {"success": false, "message": "Invalid email or password."};
  }
}



// Future<void> loginWithPhoneOTP(String phone, BuildContext context) async {
//   TextEditingController otpController = TextEditingController();
//   String fullPhoneNumber = '+91${phone.trim()}';

//   // Show progress indicator dialog
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => const Center(child: CircularProgressIndicator()),
//   );

//   try {
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: fullPhoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         Navigator.of(context).pop(); // Dismiss progress
//         await FirebaseAuth.instance.signInWithCredential(credential);
//         showSnackBar(context, "OTP Verified Automatically");
//       },
//       verificationFailed: (e) {
//         Navigator.of(context).pop(); // Dismiss progress
//         showSnackBar(context, e.message ?? "Verification failed");
//       },
//       codeSent: (String verificationId, int? resendToken) async {
//         Navigator.of(context).pop(); // Dismiss progress

//         showOtpDialog(
//           otpController: otpController,
//           context: context,
//           verificationId: verificationId,
//           onPressed: () async {
//             // Show progress while verifying OTP
//             showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (_) => const Center(child: CircularProgressIndicator()),
//             );

//             try {
//               PhoneAuthCredential credential = PhoneAuthProvider.credential(
//                 verificationId: verificationId,
//                 smsCode: otpController.text.trim(),
//               );

//               await FirebaseAuth.instance.signInWithCredential(credential);
//               Navigator.of(context).pop(); // Close progress
//               Navigator.of(context).pop(); // Close OTP dialog

//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(successBar("OTP Verified Successfully"));

//               try {
//                 User? user = FirebaseAuth.instance.currentUser;
//                 debugPrint("Current UID: ${user!.uid}");

//                 DocumentSnapshot userDoc = await FirebaseFirestore.instance
//                     .collection("users")
//                     .doc(user.uid)
//                     .get();

//                 if (userDoc.exists) {
//                   String role = userDoc
//                       .get("role")
//                       .toString()
//                       .toLowerCase()
//                       .trim();
//                   debugPrint("User role: $role");

//                   if (role == "farmer") {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => FarmerHomePage(snackBarMsg: ""),
//                       ),
//                     );
//                   } else if (role == "buyer") {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CustomerHomePage(snackBarMsg: ""),
//                       ),
//                     );
//                   } else {
//                     debugPrint("⚠ Unknown role: $role");
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Unknown user role.")),
//                     );
//                   }
//                 } else {
//                   debugPrint("⚠ User document does not exist.");
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("User profile not found.")),
//                   );
//                 }
//               } catch (e) {
//                 Navigator.of(context).pop(); // Close any open dialog
//                 debugPrint(e.toString());
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   errorBar("Something went wrong while fetching user data."),
//                 );
//               }
//             } catch (e) {
//               Navigator.of(context).pop(); // Close progress dialog
//               debugPrint(e.toString());
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(errorBar("Invalid OTP. Please try again."));
//             }
//           },
//         );
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         // Optional: handle timeout
//       },
//     );
//   } on FirebaseAuthException catch (e) {
//     Navigator.of(context).pop(); // Dismiss progress if still open
//     showSnackBar(context, "Something went wrong: ${e.message}");
//   }
// }

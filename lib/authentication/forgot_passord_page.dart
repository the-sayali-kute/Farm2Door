import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/reusables/functions.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/reusables/final_vars.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // ✅ Check if email exists in Firestore before sending reset link
  void resetPassword() async {
    final email = emailController.text.trim();

    // Email validation
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        errorBar("Please enter a valid email address."),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Query Firestore users collection to check if email exists
      final querySnapshot = await _firestore
          .collection('users') // your Firestore collection for users
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Email not found in Firestore
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          errorBar("No account found with this email."),
        );
        return;
      }

      // Email exists in Firestore → send password reset
      await _auth.sendPasswordResetEmail(email: email);

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        successBar("Reset link sent to your email.")
      );

      Navigator.maybePop(context); // Back to login
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      String errorMessage = "Something went wrong.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      }
      ScaffoldMessenger.of(context).showSnackBar(errorBar(errorMessage));
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        errorBar("An error occurred. Please try again.")
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Forgot Password"),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter your email to receive a password reset link"),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.black,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: border,
                focusedBorder: border,
                enabledBorder: border,
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: gradient,
                      ),
                      child: TextButton(
                        onPressed: resetPassword,
                        style: TextButton.styleFrom(
                          minimumSize: Size(150, 50),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Send Reset Link",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

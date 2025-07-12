import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forms/customer_home_page/appbar.dart';
import 'package:forms/final_vars.dart';
import 'package:forms/functions.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void resetPassword() async {
    final email = emailController.text.trim();

    // ✅ Email validation
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗ Please enter a valid email address.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("📧 Reset link sent to your email")),
      );

      Navigator.maybePop(context);
      // Back to login screen
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ ${e.toString()}")));
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
            TextField(
              cursorColor: Colors.black,
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: border,
                focusedBorder: border,
                enabledBorder: border,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),

            // ✅ Button or loading indicator
            isLoading
                ? CircularProgressIndicator()
                : Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: gradient,
                      ),
                      child: TextButton(
                        onPressed: () async {
                          _sendPasswordResetEmail(
                            context,
                            emailController.text,
                          );
                        },
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

void _sendPasswordResetEmail(BuildContext context, String email) async {
  if (email.trim().isEmpty || !email.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      errorBar("Please enter a valid email address.")
    );
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      successBar("Reset link sent! Please check your email.")
    );
  } on FirebaseAuthException catch (e) {
    String errorMessage = "Something went wrong.";
    if (e.code == 'user-not-found') {
      errorMessage = "No user found for that email.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      errorBar(errorMessage)
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      errorBar("An error occurred. Please try again.")
    );
  }
}

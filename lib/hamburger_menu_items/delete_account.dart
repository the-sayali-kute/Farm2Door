import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/reusables/final_vars.dart';
import 'package:forms/reusables/functions.dart';
import 'package:forms/app_startup/landing_page.dart';
import 'package:lottie/lottie.dart';

class DeleteAccount extends StatelessWidget {
  const DeleteAccount({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(errorBar("No user is logged in."));
      return;
    }

    try {
      // Step 1: Ask for password (for re-authentication)
      final password = await _promptForPassword(context);
      if (password == null || password.isEmpty) return;

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      // Step 2: Reauthenticate user
      await user.reauthenticateWithCredential(cred);

      // Step 3: Delete Firestore document FIRST
      await FirebaseFirestore.instance.collection("users").doc(user.uid).delete();

      // Step 4: Delete user from Firebase Authentication
      await user.delete();

      // Step 5: Sign out just in case (clears session)
      await FirebaseAuth.instance.signOut();

      // Step 6: Navigate to Landing Page after short delay
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(successBar("Account deleted successfully."));
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Failed to delete account.";
      if (e.code == 'wrong-password') {
        message = "Incorrect password. Please try again.";
      } else if (e.code == 'requires-recent-login') {
        message = "Please log in again before deleting your account.";
      }
      ScaffoldMessenger.of(context).showSnackBar(errorBar(message));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(errorBar("Failed to delete account: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Delete Account',
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
                "assets/animations/delete_account.json",
                height: 200,
                repeat: true,
              ),
              const SizedBox(height: 30),
              const Text(
                "Leaving Farm2Door?",
                style: TextStyle(
                  fontSize: 20,
                  height: 2.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "If you delete your account, all your data including your profile and past orders will be permanently removed.\n\nWe're sad to see you go!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _showConfirmationDialog(context),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text(
                  "Delete Account",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Are you sure?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Do you really want to delete your account?\n\nThis action is permanent and cannot be undone.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              "Yes, Delete",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔐 Prompt user to re-enter password
Future<String?> _promptForPassword(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();
  return await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Password"),
      content: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: "Enter your password",
          focusColor: Colors.black,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(passwordController.text),
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}

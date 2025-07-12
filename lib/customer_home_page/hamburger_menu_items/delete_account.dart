import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/final_vars.dart';
import 'package:forms/functions.dart';
import 'package:forms/landing_page.dart';
import 'package:lottie/lottie.dart';

class DeleteAccount extends StatelessWidget {
  const DeleteAccount({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(errorBar(("No user is logged in.")));
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;

      // Ask user to re-enter password
      final password = await _promptForPassword(context);
      if (password == null) return; // User cancelled

      // Re-authenticate user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(cred);

      // Delete from Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).delete();

      // Delete auth account
      await user.delete();

      // Wait briefly for UI to show snackbar (optional)
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(errorBar("Failed to delete account: $e"));
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
                "assets/animations/delete_account.json", // Replace with your delete animation
                height: 200,
                repeat: true,
                reverse: false,
                animate: true,
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
      barrierDismissible: false, // user must choose explicitly
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
            onPressed: () => Navigator.maybePop(context)
,
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.maybePop(context);
 // close dialog
              _deleteAccount(context); // proceed with deletion
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


Future<String?> _promptForPassword(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();

  return await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Password"),
      content: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: "Enter your password",focusColor: Colors.black),
        
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.maybePop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.maybePop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}

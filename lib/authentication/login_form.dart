import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/authentication/auth_functions.dart';
import 'package:forms/farmer_home_page/farmer_main_page.dart';
import 'package:forms/authentication/signup_form.dart';
import 'package:forms/customer_home_page/customer_home_page.dart';
import 'package:forms/reusables/final_vars.dart';
import 'package:forms/reusables/functions.dart';
import 'package:forms/widgets/email_widget.dart';
import 'package:forms/widgets/password_widget.dart';
import 'package:forms/authentication/forgot_passord_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late bool hasForgotPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // The total height of the current device's screen in logical pixels
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.only(
                  top: 32,
                  bottom: 50,
                  left: 32,
                  right: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25), // Reduced top spacing
                    Text(
                      "Welcome Back!",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 25), // Adjusted spacing
                    Text(
                      "Log In",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return SignupForm();
                                },
                              ),
                            );
                          },

                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40), // Increased spacing before form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        emailWidget(),
                        SizedBox(
                          height: 25,
                        ), // Consistent spacing between fields
                        PasswordWidget(),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        SizedBox(height: 40), // Increased spacing before button
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              

                              if (emailController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  errorBar(
                                    "Please enter both email and password.",
                                  ),
                                );
                                return;
                              }
                              try {
                                final result = await loginWithEmailPassWord(
                                  emailController.text,
                                  passwordController.text,
                                );

                                //                                 if (!mounted)
                                //                                   return; // prevent UI update if widget disposed
                                //                                Navigator.maybePop(context);
                                //  // dismiss loading dialog

                                if (result["success"]) {
                                  emailController.clear();
                                  passwordController.clear();

                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) return;

                                  final userDoc = await FirebaseFirestore
                                      .instance
                                      .collection("users")
                                      .doc(user.uid)
                                      .get();

                                  if (!userDoc.exists) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "User profile not found.",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final role = userDoc
                                      .get("role")
                                      .toString()
                                      .toLowerCase();

                                  if (role == "farmer") {
                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FarmerMainPage(),
                                      ),
                                    );
                                    // WidgetsBinding.instance
                                    //     .addPostFrameCallback((_) {
                                    //       if (!mounted) return;
                                    //       Navigator.pushReplacement(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //           builder: (context) =>
                                    //               FarmerMainPage(),
                                    //         ),
                                    //       );
                                    //     });
                                  } else if (role == "buyer") {
                                    if (!mounted) return;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (!mounted) return;
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomerHomePage(
                                                    snackBarMsg: "",
                                                  ),
                                            ),
                                          );
                                        });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Unknown user role."),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(errorBar(result["message"]));
                                }
                              } catch (e) {
                                if (mounted) Navigator.maybePop(context);

                                debugPrint("Unhandled login error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  errorBar("Something went wrong."),
                                );
                              }
                            },

                            style: buttonStyle,
                            child: Text("Log In", style: buttonTextStyle),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

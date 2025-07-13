import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:forms/authentication/auth_functions.dart';
import 'package:forms/authentication/login_form.dart';
import 'package:forms/reusables/functions.dart';
import 'package:forms/widgets/role_widget.dart';
import 'package:forms/reusables/final_vars.dart';
import 'package:forms/widgets/full_name_widget.dart';
import 'package:forms/widgets/email_widget.dart';
import 'package:forms/widgets/password_widget.dart';
import 'package:forms/widgets/address_widget.dart';
import 'package:forms/widgets/phone_widget.dart';
import 'package:forms/farmer_home_page/areaproximity.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  double deliveryRadius = 1;
  String selectedRole = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.only(top: 32, bottom: 50, left: 32, right: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Text(
                        "Already have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginForm();
                              },
                            ),
                          );
                        },

                        child: Text(
                          "Log In",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RoleWidget(
                          selectedRole: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value;
                            });
                          },
                        ),

                        SizedBox(height: 25),
                        FullNameWidget(),
                        SizedBox(height: 25),
                        emailWidget(),
                        SizedBox(height: 25),
                        PhoneWidget(),
                        SizedBox(height: 25),
                        passwordWidget(),
                        SizedBox(height: 25),
                        AddressWidget(),
                        SizedBox(height: 25),
                        if (selectedRole == "Farmer") ...[
                          AreaProximityWidget(
                            radius: deliveryRadius,
                            onChanged: (value) {
                              setState(() {
                                deliveryRadius = value;
                              });
                            },
                          ),
                        ],

                        Center(
                          child: TextButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              try {
                                await createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  name: fullNameController.text,
                                  phone: phoneController.text,
                                  address: addressController.text,
                                  role: selectedRole.toLowerCase(),
                                  context: context,
                                  deliveryRadius: selectedRole == "Farmer"
                                      ? deliveryRadius.toInt()
                                      : null,
                                );

                                if (selectedRole == "Farmer") {
                                  await FirebaseMessaging.instance
                                      .getToken()
                                      .then((token) {
                                        FirebaseFirestore.instance
                                            .collection('fcmTokens')
                                            .doc(
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                            )
                                            .set({'token': token});
                                      });

                                  Navigator.pushReplacement(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginForm(),
                                    ),
                                  );
                                } else if (selectedRole == "Buyer") {
                                  Navigator.pushReplacement(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginForm(),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(
                                  // ignore: use_build_context_synchronously
                                  context,
                                ).showSnackBar(errorBar(e.toString()));
                              }

                              // await storeUserDetails(
                              //   name: fullNameController.text,
                              //   role: selectedRole,
                              //   password: passwordController.text,
                              //   email: emailController.text,
                              //   address: addressController.text,
                              //   phone: int.parse(phoneController.text),
                              // );
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return CustomerHomePage();
                              //     },
                              //   ),
                              // );
                            },
                            style: buttonStyle,
                            child: Text("Sign Up", style: buttonTextStyle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

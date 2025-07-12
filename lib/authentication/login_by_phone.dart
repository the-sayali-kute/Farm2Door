import 'package:flutter/material.dart';
import 'package:forms/authentication/signup_form.dart';
import 'package:forms/final_vars.dart';
import 'package:forms/widgets/phone_widget.dart';

class LoginByPhone extends StatelessWidget {
  const LoginByPhone({super.key, required this.hasForgotPassword});
  final bool hasForgotPassword;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        // The total height of the current device's screen in logical pixels
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: SafeArea(
          child: Center(
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
                    SizedBox(height: 25),  // Reduced top spacing
                    Text("Welcome Back!", style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 25),  // Adjusted spacing
                    Text("Log In", style: Theme.of(context).textTheme.titleMedium),
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
                    SizedBox(height: 40),  // Increased spacing before form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhoneWidget(),
                        SizedBox(height: 25),   // Increased spacing before button
                        Center(
                          child: TextButton(
                            onPressed: () async{
                              // await loginWithPhoneOTP(phoneController.text,context);
                              // navigate to OTP page.
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(builder: (context){
                              //     return 
                              //   })
                              // );
                            },
                            style: buttonStyle,
                            child: Text(
                              "Send OTP",
                              style: buttonTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
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
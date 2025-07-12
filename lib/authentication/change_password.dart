import 'package:flutter/material.dart';
import 'package:forms/final_vars.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   backgroundColor: const Color.fromARGB(255, 202, 58, 58),
      //   appBar: AppBar(
      //     title: Text("Change Password"),
      //     centerTitle: true, 
      //     titleTextStyle: Theme.of(context).textTheme.titleSmall,
      //   ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                      Text(
                        "Update Password",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 30),
                      TextField(
                        obscureText: true,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          labelStyle: Theme.of(context).textTheme.bodyMedium,
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                        ),
                      ),
                      SizedBox(height: 25),
                      TextField(
                        obscureText: true,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: Theme.of(context).textTheme.bodyMedium,
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                        ),
                      ),
                      SizedBox(height: 40),
                      TextButton(
                        onPressed: () {
                          // Navigate to the home page.
                        },
                        style: buttonStyle,
                        child: Text("Reset Password", style: buttonTextStyle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

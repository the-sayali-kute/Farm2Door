import 'package:flutter/material.dart';
import 'package:forms/reusables/final_vars.dart';
// ignore: camel_case_types
class emailWidget extends StatelessWidget {
  const emailWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      keyboardType: TextInputType.emailAddress,
      controller: emailController,
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
      validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Email is required';
          }
          return null;
        },

    );
  }
}
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
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) {
          return 'Email is required';
        }
        // Regex for email validation
        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        if (!emailRegex.hasMatch(trimmedValue)) {
          return 'Enter valid email';
        }
        return null; // Validation passed
      },
    );
  }
}
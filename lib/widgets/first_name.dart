import 'package:flutter/material.dart';
import 'package:forms/reusables/final_vars.dart';
class FirstName extends StatelessWidget {
  const FirstName({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: firstNameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: "First name",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
      validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Name is required';
          }
          return null;
        },

    );

  }
}
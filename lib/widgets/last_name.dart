import 'package:flutter/material.dart';
import 'package:forms/final_vars.dart';
class LastName extends StatelessWidget {
  const LastName({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: lastNameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: "Last name",
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
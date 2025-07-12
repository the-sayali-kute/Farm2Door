import 'package:flutter/material.dart';
import 'package:forms/final_vars.dart';
class passwordWidget extends StatelessWidget {
  const passwordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: true,
      controller: passwordController,
      cursorColor: Colors.black,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
      validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Password is required';
          }
          return null;
        },

    );
  }
}
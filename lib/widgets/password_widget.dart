import 'package:flutter/material.dart';
import 'package:forms/reusables/final_vars.dart';

class PasswordWidget extends StatefulWidget {
  const PasswordWidget({super.key});

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      controller: passwordController,
      cursorColor: Colors.black,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        final password = value?.trim() ?? '';

        // Rule 1: Minimum length
        if (password.length < 6) {
          return 'Password must be at least 6 characters long';
        }

        // Rule 2: At least one special character
        final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
        if (!specialCharRegex.hasMatch(password)) {
          return 'Include at least one special character';
        }

        // Rule 3: At least one uppercase letter
        final uppercaseRegex = RegExp(r'[A-Z]');
        if (!uppercaseRegex.hasMatch(password)) {
          return 'Include at least one uppercase letter';
        }

        return null; // ✅ Password is valid
      },
    );
  }
}

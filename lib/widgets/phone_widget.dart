import 'package:flutter/material.dart';
import 'package:forms/reusables/final_vars.dart';

class PhoneWidget extends StatelessWidget {
  const PhoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixText: '+91 ',
        labelText: "Phone",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
      validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Phone number is required';
          }
          return null;
        },

      inputFormatters: inputFormatters,
    );
  }
}

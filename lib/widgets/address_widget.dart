import 'package:flutter/material.dart';
import 'package:forms/reusables/final_vars.dart';

class AddressWidget extends StatelessWidget {
  const AddressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: addressController,
      keyboardType: TextInputType.streetAddress,
      decoration: InputDecoration(
        labelText: "Address",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
        
      ),
      validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Address is required';
          }
          return null;
        },

    );
  }
}
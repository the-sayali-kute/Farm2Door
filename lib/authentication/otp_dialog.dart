import 'package:flutter/material.dart';
import 'package:forms/final_vars.dart';

void showOtpDialog({
  required BuildContext context,
  required TextEditingController otpController,
  required VoidCallback onPressed,
  required String verificationId,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text("Enter OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: otpController,
              cursorColor: Colors.black,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            child: Text(
              "Submit",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
              ),
            ),
          ),
        ],
      );
    },
  );
}

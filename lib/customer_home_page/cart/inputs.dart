import 'package:flutter/material.dart';
import 'package:forms/reusables/functions.dart';

final border = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black),
  borderRadius: BorderRadius.circular(10),
);

final loading = (BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );
};

Widget buildImgStack(
  String path,
  BuildContext context,
  String productId,
  String productName,
  String unit,
  String sellingPrice,
  String farmerId,
  String mrp,
) {
  return Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(path, height: 120, width: 120, fit: BoxFit.cover),
      ),
      Positioned(
        bottom: 4,
        right: 4,
        child: GestureDetector(
          onTap: () {
            addToCart(
              context,
              farmerId: farmerId,
              productId: productId,
              productName: productName,
              path: path,
              sellingPrice: sellingPrice,
              mrp: mrp,
              unit: unit,
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color.fromARGB(255, 240, 255, 218),
            child: Icon(
              Icons.add_shopping_cart_sharp,
              color: Colors.green,
              size: 18,
            ),
          ),
        ),
      ),
    ],
  );
}

final gradient = LinearGradient(
  colors: [
    Color(0xFF7BB661), // Fresh leaf green
    Color(0xFF4CA330), // Natural green
    Color(0xFF2C5E1E), // Deep forest green
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.5, 1.0],
  tileMode: TileMode.clamp,
);

final buttonStyle = TextButton.styleFrom(
  backgroundColor: Colors.black,
  foregroundColor: Colors.white,
  minimumSize: Size(double.infinity, 50),
);
final buttonStyle_greenshade = TextButton.styleFrom(
  backgroundColor: Colors.green,
  foregroundColor: Colors.white,
  minimumSize: Size(double.infinity, 50),
  // LinearBorder does not exist in Flutter. Use RoundedRectangleBorder for button shape.
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
);

final buttonTextStyle = TextStyle(
  fontFamily: "Nunito",
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

// Role selector
class RoleWidget extends StatefulWidget {
  final Function(String) onRoleSelected;
  const RoleWidget({super.key, required this.onRoleSelected});

  @override
  State<RoleWidget> createState() => _RoleWidgetState();
}

class _RoleWidgetState extends State<RoleWidget> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      style: TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: "Role",
        labelStyle: TextStyle(color: Colors.black),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
      items: ["Farmer", "Buyer"].map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(
            role,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRole = value!;
          widget.onRoleSelected(selectedRole!);
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a role";
        }
        return null;
      },
    );
  }
}

// Input fields

class FullNameWidget extends StatelessWidget {
  final TextEditingController controller;

  const FullNameWidget({super.key, required this.controller});

  String? _validateFullName(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Full Name is required';
    }

    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmedValue.length > 50) {
      return 'Name cannot exceed 50 characters';
    }

    // Regex: letters and spaces only, no consecutive spaces
    final nameRegex = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');
    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'Enter a valid name (letters and single spaces only)';
    }

    return null; // validation passed
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: 'Full Name',
        labelStyle: TextStyle(color: Colors.black),
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
      validator: _validateFullName,
    );
  }
}


class EmailWidget extends StatelessWidget {
  final TextEditingController controller;

  const EmailWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
    );
  }
}

class PhoneWidget extends StatelessWidget {
  final TextEditingController controller;

  const PhoneWidget({super.key, required this.controller});

  String? _validatePhone(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Phone number required';
    }

    // Check if only digits
    final digitsOnly = RegExp(r'^[0-9]+$');
    if (!digitsOnly.hasMatch(trimmedValue)) {
      return 'Phone number can contain digits only';
    }

    if (trimmedValue.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }

    return null; // validation passed
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefix: const Text("+91 "),
        labelText: "Phone",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
      validator: _validatePhone,
    );
  }
}

class PasswordWidget extends StatelessWidget {
  final TextEditingController controller;

  const PasswordWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      cursorColor: Colors.black,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
    );
  }
}

class AddressWidget extends StatelessWidget {
  final TextEditingController controller;

  const AddressWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      keyboardType: TextInputType.streetAddress,
      decoration: InputDecoration(
        labelText: "Address",
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
    );
  }
}

class ReferralCode extends StatelessWidget {
  final TextEditingController controller;

  const ReferralCode({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: 'Refernce Code',
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
    );
  }
}

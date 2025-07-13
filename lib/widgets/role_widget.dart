// import 'package:flutter/material.dart';
// import 'package:forms/final_vars.dart';
// class RoleWidget extends StatefulWidget {

//   const RoleWidget({super.key});

//   @override
//   State<RoleWidget> createState() => _RoleWidgetState();
// }

// String selectedRole = "";

// class _RoleWidgetState extends State<RoleWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<String>(
//       style: TextStyle(fontSize: 16, color: Colors.black),
//       decoration: InputDecoration(
//         labelText: "Role",
//         labelStyle: TextStyle(color: Colors.black),
//         border: border,
//         enabledBorder: border,
//         focusedBorder: border,
//       ),
//       // converting a list of strings to a list of dropdown menu items which is required by items property.
//       items: ["Farmer", "Buyer"].map((role) {
//         return DropdownMenuItem<String>(
//           value: role,
//           child: Text(
//             role,
//             style: TextStyle(fontSize: 16, color: Colors.black),
//           ),
//         );
//       }).toList(),
//       onChanged: (value) {
//         setState(() {
//           selectedRole = value!;
//         });
//       },
//       validator: (value) {
//           if (value == null || value.trim().isEmpty) {
//             return 'Role is required';
//           }
//           return null;
//         },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:forms/reusables/final_vars.dart';

class RoleWidget extends StatelessWidget {
  final String selectedRole;
  final Function(String) onChanged;

  const RoleWidget({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedRole.isNotEmpty ? selectedRole : null,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: "Role",
        labelStyle: const TextStyle(color: Colors.black),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
      items: ["Farmer", "Buyer"].map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(
            role,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value); // 🔁 Notify parent
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Role is required';
        }
        return null;
      },
    );
  }
}

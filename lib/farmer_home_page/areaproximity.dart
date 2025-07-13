// import 'package:flutter/material.dart';
// import 'package:forms/farmer_home_page/farm2door_components.dart';

// class AreaProximitySelector extends StatefulWidget {
//   const AreaProximitySelector({super.key});

//   @override
//   State<AreaProximitySelector> createState() => _AreaProximitySelectorState();
// }

// class _AreaProximitySelectorState extends State<AreaProximitySelector> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Accept orders within this radius',
//           style: TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             Expanded(
//               child: Slider(
//                 value: ProfileDataCollector.radius,
//                 min: 1,
//                 max: 100,
//                 divisions: 99,
//                 label: ProfileDataCollector.radius.round().toString(),
//                 activeColor: Colors.green,
//                 onChanged: (value) {
//                   setState(() {
//                     ProfileDataCollector.radius = value;
//                   });
//                 },
//               ),
//             ),
//             Text(
//               '${ProfileDataCollector.radius.round()} km',
//               style: TextStyle(fontSize: 12),
//             )
//           ],
//         )
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class AreaProximityWidget extends StatelessWidget {
  final double radius;
  final Function(double) onChanged;

  const AreaProximityWidget({
    super.key,
    required this.radius,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Area Proximity",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "Accept orders within this radius",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Slider(
          value: radius,
          min: 1,
          max: 20,
          label: "${radius.toInt()} km",
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${radius.toInt()} km",
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

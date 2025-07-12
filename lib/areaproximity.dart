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
          max: 50,
          divisions: 49,
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

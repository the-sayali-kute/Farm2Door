import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InstagramGradientIcon extends StatelessWidget {
  const InstagramGradientIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFF405DE6), // Deep Blue
            Color(0xFF5851DB), // Indigo
            Color(0xFF833AB4), // Purple
            Color(0xFFC13584), // Magenta
            Color(0xFFE1306C), // Pink
            Color(0xFFFD1D1D), // Red
            Color(0xFFF56040), // Orange
            Color(0xFFF77737), // Lighter Orange
            Color(0xFFFCaf45), // Yellow
            Color(0xFFFFDC80), // Light Yellow
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: const FaIcon(
        FontAwesomeIcons.instagram,
        size: 30, // Adjust size as needed
      ),
    );
  }
}

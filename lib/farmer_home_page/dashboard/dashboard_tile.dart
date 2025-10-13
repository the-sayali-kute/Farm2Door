// lib/farmer_dashboard/dashboard_tile.dart
import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? background;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.background,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ??
        LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: (bg is LinearGradient) ? bg : null,
          color: (bg is Color) ? bg : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white.withOpacity(0.2), child: Icon(icon, color: Colors.white)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }
}

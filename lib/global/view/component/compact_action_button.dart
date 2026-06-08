import 'package:flutter/material.dart';

class CompactActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isActive;
  final MaterialColor themeColor;

  const CompactActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.themeColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? themeColor.withOpacity(0.2) : themeColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? themeColor.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? themeColor.shade900 : themeColor.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? themeColor.shade900 : themeColor.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

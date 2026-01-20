import 'package:flutter/material.dart';

class CustomThemeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggle;

  const CustomThemeSwitch({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isDarkMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 70,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: isDarkMode ? Colors.grey[800] : Colors.yellow[700],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sun icon (left)
            AnimatedOpacity(
              opacity: isDarkMode ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.wb_sunny, color: Colors.white, size: 20),
              ),
            ),
            // Moon icon (right)
            AnimatedOpacity(
              opacity: isDarkMode ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.nightlight_round,
                    color: Colors.white, size: 20),
              ),
            ),
            // Sliding circle
            AnimatedAlign(
              alignment: isDarkMode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

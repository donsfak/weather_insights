// lib/widgets/theme_switcher.dart
import 'package:flutter/material.dart';

class ThemeSwitcher extends StatelessWidget {
  final VoidCallback onToggle;

  const ThemeSwitcher({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Colors.white,
      ),
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: onToggle,
    );
  }
}

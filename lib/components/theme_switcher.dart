// lib/widgets/theme_switcher.dart
import 'package:flutter/material.dart';

class ThemeSwitcher extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const ThemeSwitcher({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: isDarkMode ? Colors.yellowAccent : Colors.blueGrey,
      ),
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: onToggleTheme,
    );
  }
}

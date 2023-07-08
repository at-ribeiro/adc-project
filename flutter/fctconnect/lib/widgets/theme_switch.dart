import 'package:flutter/material.dart';

import '../Themes/theme_manager.dart';
import '../constants.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({
    super.key,
    required this.themeManager,
  });

  final ThemeManager themeManager;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Update the theme mode here
        // You can use Provider, GetX, or any other state management approach
        if (themeManager.getThemeMode() == ThemeMode.light) {
          themeManager.toggleTheme('dark');
        } else if (themeManager.getThemeMode() == ThemeMode.dark) {
          themeManager.toggleTheme('system');
        } else {
          themeManager.toggleTheme('light');
        }
      },
      child: themeManager.getThemeMode() == ThemeMode.light
          ? Icon(Icons.light_mode, color: Style.kPrimaryColorDark)
          : themeManager.getThemeMode() == ThemeMode.dark
              ? Icon(Icons.dark_mode, color: Style.kPrimaryColorLight)
              : Text(
                  'System Theme',
                  style: TextStyle(fontSize: 18),
                ),
    );
  }
}

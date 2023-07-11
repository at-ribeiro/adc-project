import 'package:flutter/material.dart';

import '../Themes/theme_manager.dart';

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({
    Key? key,
    required this.themeManager,
  }) : super(key: key);

  final ThemeManager themeManager;

  @override
  _ThemeSwitchState createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  bool _isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    _isDarkTheme = widget.themeManager.getThemeMode() == ThemeMode.dark;

    return Switch(
      value: _isDarkTheme,
      onChanged: (value) {
        setState(() {
          _isDarkTheme = value;
          // Toggle theme
          widget.themeManager.toggleTheme(_isDarkTheme ? 'dark' : 'light');
        });
      },
      activeTrackColor: Theme.of(context).primaryColor,
    );
  }
}

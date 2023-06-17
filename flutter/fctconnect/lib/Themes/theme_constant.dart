import 'package:flutter/material.dart';
import 'package:responsive_login_ui/constants.dart';

const PRIMARY_COLOR_DARK = Color.fromARGB(188, 26, 58, 182);

const PRIMARY_COLOR_LIGHT = Color.fromARGB(187, 54, 94, 255);
const COLOR_ACCENT = Color.fromARGB(210, 89, 117, 255);
const COLOR_ACCENT_splash = Color.fromARGB(255, 17, 47, 166);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: PRIMARY_COLOR_LIGHT,
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: COLOR_ACCENT),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: MaterialStateProperty.all< EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.5)),
          
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(kButtonColor),
      overlayColor: MaterialStateProperty.all<Color>(kButtonColor),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryColor,
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: kButtonColor),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: MaterialStateProperty.all< EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.5)),
          
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(kButtonColor),
      overlayColor: MaterialStateProperty.all<Color>(kButtonColor),
    ),
  ),
);

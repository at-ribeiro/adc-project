import 'package:flutter/material.dart';
import 'package:responsive_login_ui/constants.dart';

ThemeData lightTheme = ThemeData(
  textTheme: TextTheme(
    bodyText1: TextStyle(color: Style.kAccentColor0Light),
    bodyText2: TextStyle(color: Style.kAccentColor0Light),
    headline1: TextStyle(color: Style.kAccentColor0Light),
    headline2: TextStyle(color: Style.kAccentColor0Light),
    headline3: TextStyle(color: Style.kAccentColor0Light),
    headline4: TextStyle(color: Style.kAccentColor0Light),
    headline5: TextStyle(color: Style.kAccentColor0Light),
    headline6: TextStyle(color: Style.kAccentColor0Light),
    subtitle1: TextStyle(color: Style.kAccentColor2Light),
  ),
  brightness: Brightness.light,
  primaryColor: Style.kPrimaryColorLight,
  scaffoldBackgroundColor: Style.kPrimaryColorLight,
  primaryIconTheme: IconThemeData(color: Style.kAccentColor1Light),
  iconTheme: IconThemeData(color: Style.kAccentColor1Light),
  primaryTextTheme: TextTheme(
    headline6: TextStyle(color: Style.kAccentColor0Light),
  ),
  indicatorColor: Style.kAccentColor0Light,
  appBarTheme: AppBarTheme(
    backgroundColor: Style.kPrimaryColorLight,
    elevation: 0.0,
    iconTheme: IconThemeData(color: Style.kAccentColor0Light),
    titleTextStyle: TextStyle(
        color: Style.kAccentColor0Light,
        fontWeight: FontWeight.bold,
        fontSize: 20.0),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Style.kSecondaryColorLight,
    indicatorColor: Style.kAccentColor1Light,
    iconTheme: MaterialStateProperty.all(
        IconThemeData(color: Style.kAccentColor0Light)),
  ),
  drawerTheme: DrawerThemeData(
    elevation: 0.0,
    backgroundColor: Style.kPrimaryColorLight,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Style.kAccentColor1Light,
      foregroundColor: Style.kPrimaryColorLight),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.5)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: Style.kBorderRadius,
        ),
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Style.kAccentColor0Light,
        ),
      ),
      backgroundColor:
          MaterialStateProperty.all<Color>(Style.kAccentColor1Light),
      overlayColor:
          MaterialStateProperty.all<Color>(Style.kSecondaryColorLight),
    ),
  ),
  searchBarTheme: SearchBarThemeData(
    backgroundColor: MaterialStateProperty.all<Color>(Style.kPrimaryColorLight),
  ),
  inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Style.kAccentColor0Light,
      ),
      prefixStyle: TextStyle(
        color: Style.kAccentColor1Light,
      ),
      suffixStyle: TextStyle(
        color: Style.kAccentColor1Light,
      ),
      iconColor: Style.kAccentColor1Light,
      focusColor: Style.kAccentColor1Light),
  dialogBackgroundColor: Style.kAccentColor2Light.withOpacity(1.0),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
          20.0), // assuming Style.kBorderRadius = BorderRadius.circular(20.0)
    ),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Style.kAccentColor1Light,
    circularTrackColor: Style.kAccentColor0Light,
  ),
  expansionTileTheme: ExpansionTileThemeData(
    iconColor: Style.kAccentColor1Light,
    textColor: Style.kAccentColor0Light,
    backgroundColor: Style.kAccentColor2Light.withOpacity(0.5),
    collapsedIconColor: Style.kAccentColor1Light,
  ),
  focusColor: Style.kAccentColor1Light,
);

//Dark theme
ThemeData darkTheme = ThemeData(
  textTheme: TextTheme(
    bodyText1: TextStyle(color: Style.kAccentColor0Dark),
    bodyText2: TextStyle(color: Style.kAccentColor0Dark),
    headline1: TextStyle(color: Style.kAccentColor0Dark),
    headline2: TextStyle(color: Style.kAccentColor0Dark),
    headline3: TextStyle(color: Style.kAccentColor0Dark),
    headline4: TextStyle(color: Style.kAccentColor0Dark),
    headline5: TextStyle(color: Style.kAccentColor0Dark),
    headline6: TextStyle(color: Style.kAccentColor0Dark),
    subtitle1: TextStyle(color: Style.kAccentColor2Dark),
  ),
  brightness: Brightness.dark,
  primaryColor: Style.kPrimaryColorDark,
  scaffoldBackgroundColor: Style.kPrimaryColorDark,
  primaryIconTheme: IconThemeData(color: Style.kAccentColor1Dark),
  iconTheme: IconThemeData(color: Style.kAccentColor1Dark),
  primaryTextTheme: TextTheme(
    headline6: TextStyle(color: Style.kAccentColor0Dark),
  ),
  indicatorColor: Style.kAccentColor0Dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Style.kPrimaryColorDark,
    elevation: 0.0,
    iconTheme: IconThemeData(color: Style.kAccentColor0Dark),
    titleTextStyle: TextStyle(
        color: Style.kAccentColor0Dark,
        fontWeight: FontWeight.bold,
        fontSize: 20.0),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Style.kSecondaryColorDark,
    indicatorColor: Style.kAccentColor1Dark,
    iconTheme: MaterialStateProperty.all(
        IconThemeData(color: Style.kAccentColor0Dark)),
  ),
  drawerTheme: DrawerThemeData(
    elevation: 0.0,
    backgroundColor: Style.kPrimaryColorDark,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Style.kAccentColor1Dark,
      foregroundColor: Style.kPrimaryColorDark),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.5)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: Style.kBorderRadius,
        ),
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Style.kAccentColor0Dark,
        ),
      ),
      backgroundColor:
          MaterialStateProperty.all<Color>(Style.kAccentColor1Dark),
      overlayColor: MaterialStateProperty.all<Color>(Style.kSecondaryColorDark),
    ),
  ),
  searchBarTheme: SearchBarThemeData(
    backgroundColor: MaterialStateProperty.all<Color>(Style.kPrimaryColorDark),
  ),
  inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Style.kAccentColor0Dark,
      ),
      prefixStyle: TextStyle(
        color: Style.kAccentColor1Dark,
      ),
      suffixStyle: TextStyle(
        color: Style.kAccentColor1Dark,
      ),
      iconColor: Style.kAccentColor1Dark,
      focusColor: Style.kAccentColor1Dark),
  dialogBackgroundColor: Style.kAccentColor2Dark.withOpacity(1.0),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
          20.0), // assuming Style.kBorderRadius = BorderRadius.circular(20.0)
    ),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Style.kAccentColor1Dark,
    circularTrackColor: Style.kAccentColor0Dark,
  ),
  expansionTileTheme: ExpansionTileThemeData(
    iconColor: Style.kAccentColor1Dark,
    textColor: Style.kAccentColor0Dark,
    backgroundColor: Style.kAccentColor2Dark.withOpacity(0.5),
    collapsedIconColor: Style.kAccentColor1Dark,
  ),
  focusColor: Style.kAccentColor1Dark,
);

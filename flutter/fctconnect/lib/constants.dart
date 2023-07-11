import 'package:flutter/material.dart';

class Style {
  //current mode
  static dynamic kPrimaryColor = Color.fromARGB(255, 27, 32, 53);

  static dynamic kSecondaryColor = Color.fromARGB(255, 33, 51, 115);

  static dynamic kAccentColor0 =
      Color.fromARGB(255, 221, 244, 255); //if light mode troccar com a primaria

  static dynamic kAccentColor1 = Color.fromARGB(255, 133, 198, 147);

  static dynamic kAccentColor2 = Color.fromARGB(255, 118, 170, 185);

  static dynamic kCardColor = Color.fromARGB(108, 100, 106, 124);
  static dynamic kCardBorderColor = Color.fromARGB(255, 109, 116, 136);

  //light mode
  static dynamic kPrimaryColorLight = Color.fromARGB(255, 221, 244, 255);

  static dynamic kSecondaryColorLight = Color.fromARGB(255, 182, 217, 255);

  static dynamic kAccentColor0Light =
      Color.fromARGB(255, 25, 43, 79); //if light mode troccar com a primaria

  static dynamic kAccentColor1Light = Color.fromARGB(255, 67, 177, 124);

  static dynamic kAccentColor2Light = Color.fromARGB(255, 18, 90, 125);

  static dynamic kCardColorLight = Color.fromARGB(108, 60, 64, 75);
  static dynamic kCardBorderColorLight = Color.fromARGB(255, 68, 72, 85);

//Dark mode

  static dynamic kPrimaryColorDark = Color.fromARGB(255, 27, 32, 53);

  static dynamic kSecondaryColorDark = Color.fromARGB(255, 34, 51, 115);

  static dynamic kAccentColor0Dark =
      Color.fromARGB(255, 221, 244, 255); //if light mode troccar com a primaria

  static dynamic kAccentColor1Dark = Color.fromARGB(245, 133, 198, 147);

  static dynamic kAccentColor2Dark = Color.fromARGB(234, 118, 171, 185);

// Icon Constants
  static dynamic kPlayClockButton = Icon(Icons.play_arrow_sharp);
  static dynamic kPauseClockButton = Icon(Icons.pause_sharp);

// Time constants
  static dynamic kWorkDuration = 25;
  static dynamic kShortBreakDuration = 5;
  static dynamic kLongBreakDuration = 30;

// Text constants
  static dynamic kWorkLabel = 'Work';
  static dynamic kShortBreakLabel = 'Short break';
  static dynamic kLongBreakLabel = 'Long break';

  static dynamic kGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        kSecondaryColor.withOpacity(0.6),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kSecondaryColor.withOpacity(0.6),
      ],
    ),
  );
  static dynamic kGradientDecorationUp = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        kSecondaryColor.withOpacity(0.6),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
      ],
    ),
  );

  static dynamic kGradientDecorationDown = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kPrimaryColor.withOpacity(1.0),
        kSecondaryColor.withOpacity(0.6),
      ],
    ),
  );

  static dynamic kBorderRadius = BorderRadius.all(Radius.circular(15));
}

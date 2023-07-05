import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimaryColor = Color.fromARGB(255, 27, 32, 53);

const kSecondaryColor = Color.fromARGB(145, 33, 59, 151);

const kAccentColor0 =
    Color.fromARGB(255, 221, 244, 255); //if light mode troccar com a primaria

const kAccentColor1 = Color.fromARGB(245, 133, 198, 147);

const kAccentColor2 = Color.fromARGB(234, 118, 171, 185);

const kCardColor = Color.fromARGB(108, 100, 106, 124);
const kCardBorderColor = Color.fromARGB(255, 109, 116, 136);




// Icon Constants
const Icon kPlayClockButton = Icon(Icons.play_arrow_sharp);
const Icon kPauseClockButton = Icon(Icons.pause_sharp);

// Time constants
const int kWorkDuration = 25;
const int kShortBreakDuration = 5;
const int kLongBreakDuration = 30;

// Text constants
const String kWorkLabel = 'Work';
const String kShortBreakLabel = 'Short break';
const String kLongBreakLabel = 'Long break';



dynamic kGradientDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      kSecondaryColor.withOpacity(0.6),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kSecondaryColor.withOpacity(0.6),
    ],
  ),
);
dynamic kGradientDecorationUp = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      kSecondaryColor.withOpacity(0.6),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
    ],
  ),
);

dynamic kGradientDecorationDown = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kPrimaryColor.withOpacity(1),
      kSecondaryColor.withOpacity(0.6),
    ],
  ),
);

const kBorderRadius = BorderRadius.all(Radius.circular(15));

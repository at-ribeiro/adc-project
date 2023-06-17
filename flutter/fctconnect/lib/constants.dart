import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimaryColor = Color.fromARGB(255, 34, 38, 62);

const kPrimaryLightColor = Color.fromARGB(255, 43, 46, 76);

const kSecondaryColor = Color.fromARGB(255, 71, 169, 74);

const kIconColorUnselected = Color.fromARGB(218, 204, 209, 253);

const kIconColorSelected = Color.fromARGB(255, 125, 255, 164);

const kTransparancyColor = Color.fromARGB(177, 36, 43, 80);

const kPostCreator = Color.fromARGB(255, 46, 46, 60);

const kButtonColor = Color.fromARGB(124, 49, 57, 128);

 dynamic kGradientDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      kSecondaryColor.withOpacity(0.6),
      kPrimaryLightColor.withOpacity(0.4),
      kPrimaryLightColor.withOpacity(0.4),
      kPrimaryLightColor.withOpacity(0.4),
      kSecondaryColor.withOpacity(0.6),
    ],
  ),
);

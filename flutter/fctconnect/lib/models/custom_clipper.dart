import 'dart:ui';

import 'package:flutter/material.dart';

class OutwardRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double roundness = 25;

    path.lineTo(0, -roundness);
    path.quadraticBezierTo(size.width / 2, roundness, size.width, -roundness);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

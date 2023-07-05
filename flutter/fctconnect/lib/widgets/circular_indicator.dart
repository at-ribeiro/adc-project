import 'package:flutter/material.dart';

import '../constants.dart';

class CircularProgressIndicatorCustom extends StatelessWidget {
  const CircularProgressIndicatorCustom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: kAccentColor1,);
  }
}
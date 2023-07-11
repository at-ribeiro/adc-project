
import 'package:flutter/material.dart';

import '../constants.dart';

AlertDialog ErrorDialog(String errorText, buttonText, BuildContext context) {
    return AlertDialog(
            shape:  RoundedRectangleBorder(
              borderRadius: Style.kBorderRadius,
            ),
            backgroundColor: Style.kAccentColor2.withOpacity(0.3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorText,
                  style: TextStyle(color: Style.kAccentColor0),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(buttonText),
                ),
              ],
            ),
          );
  }

import 'package:flutter/material.dart';

import '../constants.dart';

AlertDialog ErrorDialog(String errorText, buttonText, BuildContext context) {
    return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: kBorderRadius,
            ),
            backgroundColor: kAccentColor0.withOpacity(0.3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorText,
                  style: const TextStyle(color: kAccentColor0),
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
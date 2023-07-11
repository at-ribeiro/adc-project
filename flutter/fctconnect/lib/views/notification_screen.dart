import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Notification',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(fontSize: 20),
            ),
          ],
        )
      ),
    );
  }
}
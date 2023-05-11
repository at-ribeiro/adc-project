import 'package:flutter/material.dart';

class EventCreator extends StatelessWidget {
  final String event;

  EventCreator({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Register for $event',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Perform event registration logic
                Navigator.pop(context); // Go back to the previous page
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}


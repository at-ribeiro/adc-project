import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MyNotificationButton extends StatelessWidget {
  final String title;
  final String body;

  const MyNotificationButton(
      {Key? key, required this.title, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          final functions = FirebaseFunctions.instance;
          final result =
              await functions.httpsCallable('sendNotificationToAllUsers').call({
            'title': title,
            'body': body,
          });
          print('Function called successfully: $result');
        } catch (e) {
          print('Error calling function: $e');
        }
      },
      child: Text('Enviar notificação a todos os utilizadores'),
    );
  }
}

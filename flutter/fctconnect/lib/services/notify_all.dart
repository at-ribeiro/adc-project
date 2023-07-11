import 'package:flutter/material.dart';

import 'package:responsive_login_ui/services/base_client.dart';

class MyNotificationButton extends StatelessWidget {
  final String title;
  final String body;
  final String tokenId;
  final String username;

  const MyNotificationButton(
      {Key? key,
      required this.title,
      required this.body,
      required this.tokenId,
      required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ElevatedButton(
      onPressed: () async {
        BaseClient.sendNotificationToAll(tokenId, username, title, body);
      },
      child: Text(
        'Continuar',
        style: textTheme.bodyText1!.copyWith(
            fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

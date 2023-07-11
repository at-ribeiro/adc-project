import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/models/Token.dart';

import '../models/paths.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class ConfirmationPage extends StatefulWidget {
  final String eventId;

  const ConfirmationPage({super.key, required this.eventId});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  late Token _token;
  bool _isLoadingToken = true;
  late String _eventId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _eventId = widget.eventId;
  }

  Future confirmPresence() async {
    await BaseClient.registerInEvent(
        'qrcode', _token.tokenID, _token.username, _eventId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        setState(() {
          _token = token;
          _isLoadingToken = false;
        });
      });
    }
    confirmPresence();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'A sua presença no evento foi confirmada!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('${Paths.event}/${_eventId}');
              },
              child: Text('Volte ao evento'),
            ),
          ],
        ),
      ),
    );
  }
}

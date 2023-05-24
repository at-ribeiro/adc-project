import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/event_data.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/services/session_manager.dart';

import '../models/events_list_data.dart';

class EventPage extends StatefulWidget {
  final EventData event;

  const EventPage({required this.event});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isButtonPressed = false;
  late String _buttonLabel;
  late EventData _event;
  @override
  void initState() {
    _event = widget.event;
    super.initState();
    checkIfButtonShouldBePressed();
  }

  Future<void> checkIfButtonShouldBePressed() async {
    var username = await SessionManager.get("Username");
    var tokenID = await SessionManager.get("Token");
    var response = await BaseClient()
        .isInEvent("/event", username!, tokenID!); // Simulate network delay
    setState(() {
      isButtonPressed = response;
      _buttonLabel = isButtonPressed ? "Sair do evento" : "Entrar no evento";
    });
  }

  Future<void> handleButtonPress() async {
    var username = await SessionManager.get("Username");
    var tokenID = await SessionManager.get("Token");

    if(!isButtonPressed){
    await BaseClient().joinEvent("/events", username!, tokenID!, _event);}
    else {
      await BaseClient().leaveEvent("/events", username!, tokenID!, _event);
    }
   // Simulate network delay
    setState(() {
      isButtonPressed = !isButtonPressed;
      _buttonLabel = isButtonPressed ? "Sair do evento" : "Entrar no evento";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_event.url != null) ...[
              Image.network(
                _event.url!,
                fit: BoxFit.cover,
                height: 400, // Set the desired height for the banner image
                width: double.infinity,
              ),
            ]else...[
              //ir buscar a default
            ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Description: ${widget.event.description}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Creator: ${widget.event.creator}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start Date & Time: ' +
                        DateFormat('dd-MM-yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            _event.start,
                          ),
                        ),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'End Date & Time: ' +
                        DateFormat('dd-MM-yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            _event.end,
                          ),
                        ),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FutureBuilder<void>(
                        future: checkIfButtonShouldBePressed(),
                        builder: (BuildContext context,
                            AsyncSnapshot<void> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return ElevatedButton(
                              onPressed: handleButtonPress,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                                    if (states
                                            .contains(MaterialState.pressed) ||
                                        isButtonPressed) {
                                      return Color.fromARGB(255, 170, 170,
                                          170); // Change to desired pressed color
                                    }
                                    return Colors
                                        .blue; // Change to desired default color
                                  },
                                ),
                              ),
                              child: Text(
                                _buttonLabel,
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

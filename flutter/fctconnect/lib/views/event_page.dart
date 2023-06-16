import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/event_data.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/services/session_manager.dart';

import '../models/Token.dart';
import '../models/events_list_data.dart';
import '../services/load_token.dart';

class EventPage extends StatefulWidget {
  final String eventId;

  const EventPage({required this.eventId});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isButtonPressed = false;
  late EventData _event;
  late String _buttonLabel;
  late String _eventId;
  late Token _token;
  bool isEventLoading = true;
  bool _isLoadingToken = true;
  @override
  void initState() {
    _eventId = widget.eventId;
    super.initState();
  }

  Future<void> checkIfButtonShouldBePressed() async {
    var username = await SessionManager.get("Username");
    var tokenID = await SessionManager.get("Token");
    var response = await BaseClient().isInEvent("/event", username!, tokenID!);
    setState(() {
      isButtonPressed = response;
      _buttonLabel = isButtonPressed ? "Sair do evento" : "Entrar no evento";
    });
  }

  Future<void> handleButtonPress() async {
    var username = await SessionManager.get("Username");
    var tokenID = await SessionManager.get("Token");

    if (!isButtonPressed) {
      await BaseClient().joinEvent("/events", username!, tokenID!, _event);
    } else {
      await BaseClient().leaveEvent("/events", username!, tokenID!, _event);
    }

    setState(() {
      isButtonPressed = !isButtonPressed;
      _buttonLabel = isButtonPressed ? "Sair do evento" : "Entrar no evento";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
            
          });
        });
      });
    } else if (!isEventLoading) {
      return loadEvent();
    } else {
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
              ] else ...[
                //ir buscar a default
              ],
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Description: ${_event.description}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Creator: ${_event.creator}',
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

  Widget loadEvent() {
    return FutureBuilder(
        future: _loadEvent(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Evento não encontrado!'),
                content: Text('Volte para trás'),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.go("/events");
                    },
                    child: Text('Voltar'),
                  ),
                ],
              );
            } else {
              EventData event = snapshot.data;
              setState(() {
                _event = event;
                isEventLoading = false;
                checkIfButtonShouldBePressed();
              });
              return Container();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<EventData> _loadEvent() async {
    try {
      EventData event =
          await BaseClient().getEvent("/events", _eventId, _token.tokenID);
      return event;
    } catch (e) {
      return Future.error(e);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/event_data.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/services/session_manager.dart';

import '../constants.dart';
import '../models/Token.dart';
import '../models/paths.dart';
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
      return Container(
        decoration: kGradientDecorationUp,
        child: TokenGetterWidget(onTokenLoaded: (Token token) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
          });
        }),
      );
    } else if (isEventLoading) {
      return loadEvent();
    } else {
      checkIfButtonShouldBePressed();
      return Container(
        decoration: kGradientDecorationUp,
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: kAccentColor0
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${_event.description}',
                        style: TextStyle(fontSize: 16, color: kAccentColor2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Creator: ${_event.creator}',
                        style: TextStyle(fontSize: 16, color: kAccentColor2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start Date & Time: ' +
                            DateFormat('dd-MM-yyyy HH:mm:ss').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                _event.start,
                              ),
                            ),
                        style: TextStyle(fontSize: 16, color: kAccentColor2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'End Date & Time: ' +
                            DateFormat('dd-MM-yyyy HH:mm:ss').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                _event.end,
                              ),
                            ),
                        style: TextStyle(fontSize: 16, color: kAccentColor2),
                      ),
                      SizedBox(height: 16),
                      showQrcodeOrnot(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  showQrcodeOrnot() {
    if (_event.creator == _token.username) {
      return Column(
        children: [
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ClipRRect(
                    borderRadius: kBorderRadius,
                    child: Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        child: ClipRRect(
                          borderRadius: kBorderRadius,
                          child: Image.network(
                            _event.qrcodeUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: SizedBox(
              height: 100.0, // Replace with your desired height
              // Adjust the fit property as needed
              child: Image.network(
                _event.qrcodeUrl!,
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      );
    }
  }

  Widget loadEvent() {
    return FutureBuilder(
      future: _loadEvent(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            String errorText = snapshot.error.toString();
            if (errorText.contains('404'))
              errorText = 'Evento não encontrado';
            else if (errorText.contains('401'))
              errorText = 'Não tem permissões para aceder a este evento';
            else if (errorText.contains('500'))
              errorText = 'Erro interno do servidor';
            else
              errorText = 'Algo não correu bem';

            return Container(
              decoration: kGradientDecorationUp,
              child: AlertDialog(
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
                        context.go(Paths.events);
                      },
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              setState(() {
                _event = snapshot.data;
                isEventLoading = false;
              });
            });
            return Container();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<EventData> _loadEvent() async {
    try {
      EventData event = await BaseClient()
          .getEvent("/qrcode/get", _eventId, _token.tokenID, _token.username);
      return event;
    } catch (e) {
      return Future.error(e);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';
import '../models/AlertPostData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../services/notify_all.dart';

class ReportDetailsPage extends StatefulWidget {
  final AlertPostData alertData;

  const ReportDetailsPage({
    required this.alertData,
  });

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  late Token _token;
  bool _isLoadingToken = true;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        setState(() {
          _token = token;
          _isLoadingToken = false;
        });
      });
    } else {
      return Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Criador: ${widget.alertData.creator}',
                style: textTheme.headline5,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Localização: ${widget.alertData.location}',
                style: textTheme.subtitle1,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Descrição:',
                style: textTheme.subtitle1,
              ),
              Text(
                widget.alertData.description,
                style: textTheme.headline6,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Data/Hora: ${DateFormat('HH:mm - dd-MM-yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(widget.alertData.timestamp.toString()),
                  ),
                )}',
                style: textTheme.subtitle1,
              ),
              const SizedBox(height: 16.0),
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: Style.kBorderRadius,
                            ),
                            backgroundColor:
                                Style.kAccentColor0.withOpacity(0.3),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tem a certeza que pretende alertar todos os utilizadores sobre esta anomalia?',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    MyNotificationButton(
                                      username: _token.username,
                                      tokenId: _token.tokenID,
                                      title: widget.alertData.description,
                                      body: widget.alertData.description,
                                    ),
                                    SizedBox(width: 15),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child:
                                          Text('Não', style: textTheme.button!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  icon: Icon(
                    Icons.notification_add,
                    color: Theme.of(context).iconTheme.color,
                  )),
            ],
          ),
        ),
      );
    }
  }
}

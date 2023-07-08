import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';
import '../models/AlertPostData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../services/notify_all.dart';



class ListReportsPage extends StatefulWidget {
  const ListReportsPage({Key? key}) : super(key: key);



  @override
  State<ListReportsPage> createState() => _ListReportPageState();
}

class _ListReportPageState extends State<ListReportsPage> {
  late Token _token;
  bool _isLoadingToken = true;
  List<AlertPostData> alertDataList = [];
  List<int> reportsToDelete = [];





  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadReports() async {
    List<AlertPostData> posts = await BaseClient().getReports(
      "/alert",
      _token.username,
      _token.tokenID,
    );

    if (posts.isNotEmpty) {
      setState(() {
        alertDataList.addAll(posts);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void addToSelectedReports(int timestamp) {
    setState(() {
      reportsToDelete.add(timestamp);
    });
  }

  void removeFromSelectedReports(int timestamp) {
    setState(() {
      reportsToDelete.remove(timestamp);
    });
  }




  @override
  Widget build(BuildContext context) {

    TextTheme textTheme = Theme.of(context).textTheme;

    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
            _loadReports();
          });
        });
      });
    } else {
      return Container(
    
        child: Scaffold(
       
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await BaseClient().deleteReports(
                "/alert",
                _token.username,
                _token.tokenID,
                reportsToDelete,
              );
              setState(() {
                alertDataList.clear();
                reportsToDelete.clear();
              });
              _loadReports();
            },
            child: Icon(
              Icons.delete,
              color: Style.kAccentColor0,
            ),
          ),
          body: ListView.builder(
            itemCount: alertDataList.length,
            itemBuilder: (context, index) {
              AlertPostData alertData = alertDataList[index];
              bool isSelected = reportsToDelete.contains(alertData.timestamp);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(15.0), // Setting the border radius
                  child: Container(
                    decoration: BoxDecoration(
                      color: Style.kAccentColor2
                          .withOpacity(0.3), // Glass effect by using opacity
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Container(
                      height: 150,
                      child: Card(
                        color: Colors
                            .transparent, // To make sure Card takes the glass effect
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: SingleChildScrollView(
                          child: ListTile(
                            title: Text(alertData.creator),
                            subtitle: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Criador: ${alertData.creator}'),
                                    Text('Localização: ${alertData.location}'),
                                    Text('Descrição:'),
                                    Text(alertData.description, style: textTheme.bodyText1),
                                    Text(
                                        'Data/Hora: ${DateFormat('HH:mm - dd-MM-yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(
                                            alertData.timestamp.toString()),
                                      ),
                                    )}'),
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape:
                                                   RoundedRectangleBorder(
                                                borderRadius: Style.kBorderRadius,
                                              ),
                                              backgroundColor: Style.kAccentColor0
                                                  .withOpacity(0.3),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Tem a certeza que pretende alertar todos os utilizadores sobre esta anomalia?',
                                                    style:  TextStyle(
                                                        color: Style.kAccentColor0),
                                                  ),
                                                  const SizedBox(height: 15),
                                                  Row(
                                                    children: [
                                                       MyNotificationButton(title: alertData.description, body: alertData.location),
                                                      SizedBox(width: 15),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors.red),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          'Não',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    icon: Icon(Icons.notification_add, color: Theme.of(context).iconTheme.color,)),
                              ],
                            ),
                            trailing: Flexible(
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                    ),
                                    onPressed: () {
                                      if (isSelected) {
                                        removeFromSelectedReports(
                                            alertData.timestamp);
                                      } else {
                                        addToSelectedReports(
                                            alertData.timestamp);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }
}

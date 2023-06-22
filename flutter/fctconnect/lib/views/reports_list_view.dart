import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';
import '../models/AlertPostData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

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
        decoration: kGradientDecorationUp,
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
              color: kAccentColor0,
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
                      color: Colors.white
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
                    child: Card(
                      color: Colors
                          .transparent, // To make sure Card takes the glass effect
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(alertData.creator),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Criador: ${alertData.creator}'),
                            Text('Localização: ${alertData.location}'),
                            Text('Descrição:'),
                            Text(alertData.description),
                            Text(
                                'Data/Hora: ${DateFormat('HH:mm - dd-MM-yyyy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(alertData.timestamp.toString()),
                              ),
                            )}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onPressed: () {
                            if (isSelected) {
                              removeFromSelectedReports(alertData.timestamp);
                            } else {
                              addToSelectedReports(alertData.timestamp);
                            }
                          },
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

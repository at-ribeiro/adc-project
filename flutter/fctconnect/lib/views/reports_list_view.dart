import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isLoadingToken =true;
  List<AlertPostData> alertDataList = [];
  List<int> reportsToDelete= [];

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
    }else{return Scaffold(
    appBar: AppBar(
      title: Text('Lista de Anomalias'),
      actions: [
        IconButton(
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
  icon: Icon(Icons.delete),
),
      ],
    ),
    body: ListView.builder(
      itemCount: alertDataList.length,
      itemBuilder: (context, index) {
        AlertPostData alertData = alertDataList[index];
        bool isSelected = reportsToDelete.contains(alertData.timestamp);
        return Card(
          child: ListTile(
            title: Text(alertData.creator),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Criador: ${alertData.creator}'),
                Text('Localização: ${alertData.location}'),
                Text('Descrição:'),
                Text(alertData.description),
                Text('Data/Hora: ${DateFormat('HH:mm - dd-MM-yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(alertData.timestamp.toString()),
                  ),
                )}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
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
        );
      },
    ),
  );}
}

}
import 'package:flutter/material.dart';
import '../models/AlertPostData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onPressed;

  const _CustomAppBar({required this.onPressed});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Reporte um problema'),
      actions: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(Icons.send),
        ),
      ],
    );
  }
}

class ReportPage extends StatefulWidget {

  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Token _token;
  bool  _isLoadingToken = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController problemController = TextEditingController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    problemController.dispose();
    super.dispose();
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void submitForm() {
    String name = nameController.text;
    String location = locationController.text;
    String problem = problemController.text;

    if(name == '' || location == '' || problem == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Preencha todos os campos!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Voltar'),
              ),
            ],
          );
        },
      );
      return;
    }
    AlertPostData alert = AlertPostData(
      creator: name,
      location: location,
      description: problem,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    BaseClient().createReport("/alert",_token.username, _token.tokenID, alert);

    nameController.clear();
    locationController.clear();
    problemController.clear();
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
    } else{return Scaffold(
      appBar: _CustomAppBar(
        onPressed: submitForm,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nome do docente',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Localização do problema',
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: problemController,
                maxLines: isExpanded ? null : 10,
                minLines: 10,
                decoration: InputDecoration(
                  hintText:
                      'Seja o mais detalhado possível. Qual foi o problema que encontrou?',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );}
  }
}

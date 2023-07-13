import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import '../constants.dart';
import '../models/AlertPostData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Token _token;
  bool _isLoadingToken = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController problemController = TextEditingController();
  bool isExpanded = false;
  int _characterCount = 0;
  final int _maxCharacterLimit = 300;

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

    if (name == '' || location == '' || problem == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String errorText = 'Por favor preencha todos os campos';
          String buttonText = 'Ok';
          return ErrorDialog(errorText, buttonText, context);
        },
      );
      return;
    }else if(_characterCount > _maxCharacterLimit){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String errorText = 'O texto não pode exceder os 300 caracteres';
          String buttonText = 'Ok';
          return ErrorDialog(errorText, buttonText, context);
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

    BaseClient().createReport("/alert", _token.username, _token.tokenID, alert);

    nameController.clear();
    locationController.clear();
    problemController.clear();
    setState(() {
      _characterCount = 0;
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
    } else {
      return Container(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor,
            foregroundColor:
                Theme.of(context).floatingActionButtonTheme.foregroundColor,
            onPressed: () {
              submitForm();
            },
            child: Icon(Icons.send),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: Style.kBorderRadius,
                    color: Style.kAccentColor2.withOpacity(0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: Style.kBorderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person,
                              color: Theme.of(context).iconTheme.color),
                          hintText: 'Nome completo do utilizador',
                          border: InputBorder.none,
                        ),
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione o nome do docente';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: Style.kBorderRadius,
                    color: Style.kAccentColor2.withOpacity(0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: Style.kBorderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person,
                              color: Theme.of(context).iconTheme.color),
                          hintText: 'Localização do problema',
                          border: InputBorder.none,
                        ),
                        controller: locationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione a localização';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: Style.kBorderRadius,
                    color: Style.kAccentColor2.withOpacity(0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: Style.kBorderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextFormField(
                              maxLines: null, // Allow unlimited lines

                              onChanged: (text) {
                                setState(() {
                                  _characterCount = text.length;
                                });
                              },
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.description,
                                    color: Theme.of(context).iconTheme.color),
                                hintText: 'Qual foi o problema que encontrou?',
                                border: InputBorder.none,
                              ),
                              controller: problemController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione uma descrição para o report';
                                } else if (_characterCount >
                                    _maxCharacterLimit) {
                                  return 'A descrição não pode ter mais de $_maxCharacterLimit caracteres';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$_characterCount/$_maxCharacterLimit'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

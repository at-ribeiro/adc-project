import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:responsive_login_ui/models/profile_info.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../models/Token.dart';

import '../models/paths.dart';
import '../models/update_data.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class EditProfileOptions extends StatefulWidget {
  const EditProfileOptions({Key? key}) : super(key: key);

  @override
  State<EditProfileOptions> createState() => _EditProfileOptionsState();
}

class _EditProfileOptionsState extends State<EditProfileOptions> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingToken = true;

  late Token _token;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onScroll() {}

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
            body: Container(
          padding: EdgeInsets.only(left: 16, top: 25, right: 16),
          child: ListView(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Style.kAccentColor1,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Conta",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Divider(
                height: 15,
                thickness: 2,
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () {
                  context.go(Paths.editProfile);
                },
                title: Text(
                  "Editar Perfil",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                leading: Icon(
                  Icons.edit,
                ),
              ),
              ListTile(
                onTap: () {
                  context.go(Paths.changePassword);
                },
                title: Text(
                  "Mudar Password",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                leading: Icon(
                  Icons.lock,
                ),
              ),
              ListTile(
                title: Text(
                  "Apagar Conta",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: Style.kBorderRadius,
                        ),
                        backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                        title: Text(
                            "Tem a certeza que deseja apagar a sua conta?"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancelar"),
                            style: ElevatedButton.styleFrom(),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return FutureBuilder(
                                    future: BaseClient().deleteAccount(
                                        "/remove",
                                        _token.tokenID,
                                        _token.username),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: Style.kBorderRadius,
                                          ),
                                          backgroundColor: Style.kAccentColor2
                                              .withOpacity(0.3),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'A apagar...',
                                                style: TextStyle(
                                                    color: Style.kAccentColor0),
                                              ),
                                              SizedBox(height: 15),
                                              CircularProgressIndicator(
                                                color: Style.kAccentColor1,
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        if (snapshot.hasError) {
                                          return ErrorDialog(
                                              "Erro ao apagar a conta.",
                                              'OK',
                                              context);
                                        } else {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: Style.kBorderRadius,
                                            ),
                                            backgroundColor: Style.kAccentColor2
                                                .withOpacity(0.3),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Conta apagada com sucesso!',
                                                  style: TextStyle(
                                                      color:
                                                          Style.kAccentColor0),
                                                ),
                                                SizedBox(height: 15),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    CacheDefault.cacheFactory
                                                        .logout();
                                                    CacheDefault.cacheFactory
                                                        .delete('isLoggedIn');
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    prefs.remove('ProfilePic');
                                                    context.go(Paths.login);
                                                  },
                                                  child: Text('Ok'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            child: Text("Apagar"),
                            style: ElevatedButton.styleFrom(
                              primary:Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        )),
      );
    }
  }
}

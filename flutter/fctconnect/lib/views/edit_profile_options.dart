import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/Themes/theme_manager.dart';

import 'package:responsive_login_ui/models/profile_info.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/firebase_api.dart';
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
  ThemeManager themeManager = ThemeManager();
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingToken = true;

  late Token _token;
  late ScrollController _scrollController;

  late bool _notificationsEnabled;
  bool _notificationsLoading = true;
  FirebaseApi _firebaseApi = FirebaseApi(); // Add this

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _loadNotificationsState() async {
    bool aux;

    if (await CacheDefault.cacheFactory.get('NotificationState') == 'true') {
      aux = true;
    } else {
      aux = false;
    }

    return aux;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final themeProvider = Provider.of<ThemeManager>(context, listen: false);
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
          });
        });
      });
    } else if (_notificationsLoading) {
      return FutureBuilder(
          future: _loadNotificationsState(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _notificationsEnabled = false;
                    _notificationsLoading = false;
                  });
                });
                return Container();
              } else {
                if (snapshot.data != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _notificationsEnabled = snapshot.data;
                      _notificationsLoading = false;
                    });
                  });
                } else {
                  setState(() {
                    _notificationsEnabled = false;
                    _notificationsLoading = false;
                  });
                }
                return Container();
              }
            } else {
              return Container(
                  color: Colors.transparent,
                  child: const Center(child: CircularProgressIndicator()));
            }
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
                    style: textTheme.headline5,
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
              if (_token.role != "SA" && _token.role != "SECRETARIA") ...[
                ListTile(
                  onTap: () {
                    context.go(Paths.editProfile);
                  },
                  title: Text(
                    "Editar Perfil",
                    style: textTheme.headline6,
                  ),
                  leading: Icon(
                    Icons.edit,
                  ),
                ),
              ],
              ListTile(
                onTap: () {
                  context.go(Paths.changePassword);
                },
                title: Text(
                  "Mudar Password",
                  style: textTheme.headline6,
                ),
                leading: Icon(
                  Icons.lock,
                ),
              ),
              ListTile(
                title: Text(
                  "Apagar Conta",
                  style: textTheme.headline6,
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
                              primary: Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Aparência",
                    style: textTheme.headline5,
                  )
                ],
              ),
              Divider(
                height: 15,
                thickness: 2,
              ),
              ExpansionTile(
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                title: Row(
                  children: [
                    Icon(
                      themeProvider.getThemeMode() == ThemeMode.light
                          ? Icons.wb_sunny
                          : themeProvider.getThemeMode() == ThemeMode.dark
                              ? Icons.nights_stay
                              : Icons.phone_android,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    SizedBox(width: 32),
                    Text(
                      themeProvider.getThemeMode() == ThemeMode.light
                          ? 'Light'
                          : themeProvider.getThemeMode() == ThemeMode.dark
                              ? 'Dark'
                              : 'System',
                      style: textTheme.headline6,
                    ),
                  ],
                ),
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.wb_sunny,
                        color: themeProvider.getThemeMode() == ThemeMode.light
                            ? Theme.of(context).iconTheme.color
                            : Theme.of(context).textTheme.headline1!.color),
                    title: Text(
                      'Light',
                      style: textTheme.headline6,
                    ),
                    onTap: () {
                      themeProvider.toggleTheme('light');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.nights_stay,
                        color: themeProvider.getThemeMode() == ThemeMode.dark
                            ? Theme.of(context).iconTheme.color
                            : Theme.of(context).textTheme.headline1!.color),
                    title: Text(
                      'Dark',
                      style: textTheme.headline6,
                    ),
                    onTap: () {
                      themeProvider.toggleTheme('dark');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.phone_android,
                        color: themeProvider.getThemeMode() == ThemeMode.system
                            ? Theme.of(context).iconTheme.color
                            : Theme.of(context).textTheme.headline1!.color),
                    title: Text(
                      'Predifinição do sistema',
                      style: textTheme.headline6,
                    ),
                    onTap: () {
                      themeProvider.toggleTheme('system');
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.notifications,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Notificações",
                    style: textTheme.headline5,
                  )
                ],
              ),
              Divider(
                height: 15,
                thickness: 2,
              ),
              SwitchListTile(
                activeColor: Theme.of(context).iconTheme.color,
                title: Text("Notificações", style: textTheme.headline6),
                value: _notificationsEnabled,
                onChanged: (bool value) async {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  if (value) {
                    await _firebaseApi.reenableNotifications();
                    CacheDefault.cacheFactory.set('NotificationState', 'true');
                  } else {
                    await _firebaseApi.disableNotifications();
                    CacheDefault.cacheFactory.set('NotificationState', 'false');
                  }
                },
                secondary: const Icon(Icons.notifications),
              ),
            ],
          ),
        )),
      );
    }
  }
}

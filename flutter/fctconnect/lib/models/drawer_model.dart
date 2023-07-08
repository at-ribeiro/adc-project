import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/models/paths.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

import '../Themes/theme_manager.dart';
import '../constants.dart';

import '../data/cache_factory_provider.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../views/messages/messages_view.dart';
import '../widgets/theme_switch.dart';
import 'Token.dart';

class DrawerModel extends StatefulWidget {
  const DrawerModel({super.key});

  @override
  State<DrawerModel> createState() => _DrawerModelState();
}

class _DrawerModelState extends State<DrawerModel> {
  ThemeManager _themeManager = ThemeManager();
  late Token _token;
  bool _isLoadingToken = true;
  String urlPic = "";
  bool _ifProfilePicLoading = true;

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
        });
      });
    } else {
      return _buildDrawer();
    }
  }

  Widget _buildDrawer() {
    ThemeManager themeManager = context.watch<ThemeManager>();
    bool isDarkModeOn = themeManager.themeMode == ThemeMode.dark;
    String username = _token.username;
    String profiPic = _token.profilePic;

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Style.kAccentColor0Dark
              : Style.kAccentColor0Light,
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
              headline6: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Style.kAccentColor0Dark
                    : Style.kAccentColor0Light,
                fontSize: 18.0,
              ),
            ),
        listTileTheme: ListTileThemeData(
          iconColor: Theme.of(context).brightness == Brightness.dark
              ? Style.kAccentColor0Dark
              : Style.kAccentColor0Light,
          textColor: Theme.of(context).brightness == Brightness.dark
              ? Style.kAccentColor0Dark
              : Style.kAccentColor0Light,
        ),
      ),
      child: Drawer(
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
        )
        ),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              children: [
                IntrinsicWidth(
                  stepWidth: double.infinity,
                  child: Container(
                    height: 250,
                    child: DrawerHeader(
                      decoration: const BoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(_token.profilePic),
                          ),
                          const SizedBox(height: 15),
                          Text(username, style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 15),
                          ThemeSwitch(themeManager: themeManager),
                        ],
                      ),
                    ),
                  ), // Set the width of the DrawerHeader to the maximum available width
                ),
                ListTile(
                  leading: Icon(
                    Icons.home,
                  ),
                  title: const Text('Home'),
                  onTap: () {
                    context.go(Paths.homePage);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.map,
                  ),
                  title: const Text('Mapa'),
                  onTap: () {
                    context.go(Paths.mapas);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.directions_walk,
                  ),
                  title: const Text('Percursos'),
                  onTap: () {
                    context.go(Paths.routes);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.event,
                  ),
                  title: const Text('Eventos'),
                  onTap: () {
                    context.go(Paths.events);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.group,
                  ),
                  title: const Text('Nucleos'),
                  onTap: () {
                    context.go(Paths.nucleos);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.calendar_month,
                  ),
                  title: const Text('Calendário'),
                  onTap: () {
                    context.go(Paths.calendar);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.message),
                  title: const Text('Mensagens'),
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (ctx) => MessagesView()));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.timer),
                  title: const Text('Pomodoro'),
                  onTap: () {
                    context.go(Paths.pomodoro);
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
                ListTile(
                  leading: Icon(Icons.group_add),
                  title: const Text('Criar Núcleo'),
                  onTap: () {
                    context.go(Paths.criarNucleo);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.report),
                  title: const Text('Report'),
                  onTap: () {
                    context.go(Paths.report);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.report_problem_outlined),
                  title: const Text('Lista de Anomalias'),
                  onTap: () {
                    context.go(Paths.listReports);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.report_gmailerrorred),
                  title: const Text('Posts Reportados'),
                  onTap: () {
                    context.go(Paths.reportedPosts);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title:
                      const Text('Sair', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    BaseClient()
                        .doLogout("/logout", _token.username, _token.tokenID);

                    CacheDefault.cacheFactory.logout();
                    CacheDefault.cacheFactory.delete('isLoggedIn');

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    prefs.remove('ProfilePic');

                    context.go(Paths.login);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



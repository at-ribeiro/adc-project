import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/models/paths.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  ScrollController _scrollController = ScrollController();

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

  Drawer _buildDrawer() {
    ThemeManager themeManager = context.watch<ThemeManager>();
    bool isDarkModeOn = themeManager.themeMode == ThemeMode.dark;
    String username = _token.username;
    String profiPic = _token.profilePic;

    return Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                topRight: Radius.circular(30))),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              IntrinsicWidth(
                stepWidth: double.infinity,
                child: DrawerHeader(
                  decoration: const BoxDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(_token.profilePic),
                      ),
                      const SizedBox(height: 5),
                      Text(username, style: const TextStyle(fontSize: 18)),
                      ThemeSwitch(themeManager: themeManager),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  context.go(Paths.homePage);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.map),
                title: const Text('Mapa'),
                onTap: () {
                  context.go(Paths.mapas);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.directions_walk),
                title: const Text('Percursos'),
                onTap: () {
                  context.go(Paths.routes);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: const Text('Eventos'),
                onTap: () {
                  context.go(Paths.events);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_month),
                title: const Text('Calendário'),
                onTap: () {
                  context.go(Paths.calendar);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: const Text('Núcleos'),
                onTap: () {
                  context.go(Paths.nucleos);
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
              ListTile(
                leading: Icon(
                  Icons.report,
                ),
                title: const Text('Report'),
                onTap: () {
                  context.go(Paths.report);
                  Navigator.pop(context);
                },
              ),
              if (_token.role == "SA" || _token.role == "SECRETARIA")
                Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.report_problem_outlined,
                      ),
                      title: const Text('Lista de Anomalias'),
                      onTap: () {
                        context.go(Paths.listReports);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.report_gmailerrorred,
                      ),
                      title: const Text('Posts Reportados'),
                      onTap: () {
                        context.go(Paths.reportedPosts);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                ),
                title: const Text('Sair', style: TextStyle(color: Colors.red)),
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
        ));
  }
}

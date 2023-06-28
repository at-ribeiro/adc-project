import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/models/paths.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Themes/theme_manager.dart';
import '../data/cache_factory_provider.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../views/messages/messages_view.dart';
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

    return Drawer(
      backgroundColor: kPrimaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: kBorderRadius,
      ),
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
                  Switch(
                    value: isDarkModeOn,
                    onChanged: (value) {
                      _themeManager.toggleTheme(value);
                    },
                  ),
                ],
              ),
            ), // Set the width of the DrawerHeader to the maximum available width
          ),
          ListTile(
            leading: Icon(Icons.home, color: kAccentColor1),
            title: const Text('Home'),
            onTap: () {
              context.go(Paths.homePage);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.map, color: kAccentColor1),
            title: const Text('Mapa'),
            onTap: () {
              context.go(Paths.mapas);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: kAccentColor1),
            title: const Text('Eventos'),
            onTap: () {
              context.go(Paths.events);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.group, color: kAccentColor1),
            title: const Text('Grupos'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month, color: kAccentColor1),
            title: const Text('Calendário'),
            onTap: () {
              context.go(Paths.calendar);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.message, color: kAccentColor1),
            title: const Text('Mensagens'),
            onTap: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (ctx) => MessagesView()));
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          ListTile(
            leading: Icon(Icons.report, color: kAccentColor1),
            title: const Text('Report'),
            onTap: () {
              context.go(Paths.report);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.report_problem_outlined, color: kAccentColor1),
            title: const Text('Lista de Anomalias'),
            onTap: () {
              context.go(Paths.listReports);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.report_gmailerrorred, color: kAccentColor1),
            title: const Text('Posts Reportados'),
            onTap: () {
              context.go(Paths.reportedPosts);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: kAccentColor1),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () async {
              BaseClient().doLogout("/logout", _token.username, _token.tokenID);

              CacheDefault.cacheFactory.logout();
              CacheDefault.cacheFactory.delete('isLoggedIn');
             
              SharedPreferences prefs = await SharedPreferences.getInstance();

              prefs.remove('ProfilePic');

              context.go(Paths.login);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

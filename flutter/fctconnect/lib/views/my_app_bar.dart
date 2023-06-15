import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/session_manager.dart';
import 'event_view.dart';
import 'login_view.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget body;
  final VoidCallback onDrawerPressed;
  final Widget bottomNavigationBar;
  final Token token;

  const MyAppBar({
    required this.title,
    required this.body,
    required this.onDrawerPressed,
    required this.token,
    required this.bottomNavigationBar,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: onDrawerPressed,
        ),
      ),
      drawer: Drawer(
      child: Column(
        children: [
          IntrinsicWidth(
            stepWidth: double.infinity,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/default_profile.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(token.username),
                ],
              ),
            ), // Set the width of the DrawerHeader to the maximum available width
          ),
          ListTile(
            title: const Text('Eventos'),
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (ctx) => EventView()));
            },
          ),
          ListTile(
            title: const Text('Grupos'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Calendário'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          ListTile(
            title: const Text('Sair'),
            onTap: () async {
              BaseClient().doLogout("/logout", token.username, token.tokenID);

              SessionManager.storeSession('session', '/');
              if (kIsWeb) {
                SessionManager.storeSession('isLoggedIn', 'false');
                SessionManager.delete('Username');
                SessionManager.delete('Token');
                SessionManager.delete('ED');
                SessionManager.delete('CD');
                SessionManager.delete('Role');
              }

              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (ctx) => const LoginView()));
            },
          ),
        ],
      ),
    ),
      body: body,
      bottomNavigationBar:  bottomNavigationBar,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:responsive_login_ui/services/cookie_manager.dart';
import 'package:responsive_login_ui/views/login_view.dart';
import 'package:responsive_login_ui/views/signUp_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/simple_ui_controller.dart';
import 'models/Token.dart';
import 'views/my_home_page.dart';
import 'views/news_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Get.put(SimpleUIController());

  // Restore session from shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? session = prefs.getString('session');
  
  runApp(MyApp(session: session));
}

class MyApp extends StatelessWidget {
  final String? session;

  MyApp({Key? key, this.session}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return _getRouteWidget(_getSession());
          },
        );
      },
    );
  }

  Widget _getRouteWidget(String routeName) {
    String? _tokenid;
    String? _username;
    String? _role;
    String? _creationDate;
    String? _expirationDate;

    Token? token;
    if (routeName != '/') {
      _tokenid = CookieManager.get('Token');
      _username = CookieManager.get('Username');
      _role = CookieManager.get('Role');
      _creationDate = CookieManager.get('CD');
      _expirationDate = CookieManager.get('ED');

      token = Token(
        username: _username,
        role: _role,
        tokenID: _tokenid,
        creationDate: int.parse(_creationDate!),
        expirationDate: int.parse(_expirationDate!),
      );
    }
    
    switch (routeName) {
      case '/':
        return LoginView();
      case '/home':
        // Return your home page widget here
        return MyHomePage(token: token!);
      case '/news':
        // Return your profile page widget here
        return NewsView(token: token!);
      // Add more routes as needed
      case '/singup':
        return SignUpView();
      default:

        return LoginView();
    }
  }

  String _getSession() {
    if (session != null && session!.isNotEmpty) {
      return session!;
    } else {
      return '/';
    }
  }

  void setLastVisitedPage(String currentPage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_visited_page', currentPage);
  }
}

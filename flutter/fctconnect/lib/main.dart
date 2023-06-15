import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/data/cache_factory_provider.dart';
import 'package:responsive_login_ui/services/fcm_services.dart';
import 'package:responsive_login_ui/services/get_fcm_token.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:responsive_login_ui/views/login_view.dart';
import 'package:responsive_login_ui/views/signUp_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_router.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_strategy/url_strategy.dart';

import 'controller/simple_ui_controller.dart';
import 'models/Token.dart';
import 'views/my_home_page.dart';
import 'views/news_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  await FcmServices.initializeFirebase();

  FcmServices.firebaseAnalytics();

  FcmServices.firebaseMessaging();

  Get.put(SimpleUIController());

  // Restore session from shared preferences

  String? session = await CacheDefault.cacheFactory.get('Session');

  getKey();

  runApp(MyApp(session: session));
}

// class ThemeNotifier extends ChangeNotifier {
//   // Define your default thememode here
//   ThemeMode themeMode = ThemeMode.system;
//   SharedPreferences? prefs;

//   ThemeNotifier() {
//     _init();
//   }

//   _init() async {
//     // Get the stored theme from shared preferences
//     prefs = await SharedPreferences.getInstance();

//     int _theme = prefs?.getInt("theme") ?? themeMode.index;
//     themeMode = ThemeMode.values[_theme];
//     notifyListeners();
//   }

//   setTheme(ThemeMode mode) {
//     themeMode = mode;
//     notifyListeners();
//     // Save the selected theme using shared preferences
//     prefs?.setInt("theme", mode.index);
//   }
// }

// final themeNotifierProvider =
//     ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier());


void getKey() async {
  String? fcmKey = await FcmToken.getFcmToken();
  print("TOKEN : $fcmKey");
}

class MyApp extends StatelessWidget {
  final String? session;

  MyApp({Key? key, this.session}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    _initializeIsLoggedIn();
    return MaterialApp.router(
      routerConfig: AppRouter().router,
      debugShowCheckedModeBanner: false,
      // initialRoute: '/',
      // onGenerateRoute: (RouteSettings settings) {
      //   return MaterialPageRoute(
      //     builder: (BuildContext context) {
      //       return FutureBuilder<Widget>(
      //         future: _getRouteWidget(_getSession()),
      //         builder: (context, snapshot) {
      //           if (snapshot.hasData) {
      //             return snapshot.data!;
      //           } else {
      //             return Scaffold(
      //               body: Center(
      //                 child: CircularProgressIndicator(),
      //               ),
      //             );
      //           }
      //         },
      //       );
      //     },
      //   );
      // },
    );
  }

  // Future<Widget> _getRouteWidget(String routeName) async {
  //   String? _tokenid;
  //   String? _username;
  //   String? _role;
  //   String? _creationDate;
  //   String? _expirationDate;

  //   Token? token;
  //   if (routeName != '/') {
  //     _tokenid = await CacheDefault.cacheFactory.get('Token');
  //     _username = await CacheDefault.cacheFactory.get('Username');
  //     _role = await CacheDefault.cacheFactory.get('Role');
  //     _creationDate = await CacheDefault.cacheFactory.get('Creationd');
  //     _expirationDate = await CacheDefault.cacheFactory.get('Expirationd');
  //     token = Token(
  //       username: _username!,
  //       role: _role!,
  //       tokenID: _tokenid!,
  //       creationDate: int.parse(_creationDate!),
  //       expirationDate: int.parse(_expirationDate!),
  //     );
  //   } else {
  //     CacheDefault.cacheFactory.set('Session', '/');
  //   }

  //   switch (routeName) {
  //     case '/':
  //       return LoginView();
  //     case '/home':
  //       // Return your home page widget here
  //       return MyHomePage(token: token!);
  //     case '/news':
  //       // Return your profile page widget here
  //       return NewsView(token: token!);
  //     // Add more routes as needed
  //     case '/signup':
  //       return SignUpView();
  //     default:
  //       return LoginView();
  //   }
  // }

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

  Future<String?> isLoggedIn() async {
    return await SessionManager.get('isLoggedIn');
  }

  void _initializeIsLoggedIn() async {
    bool containsIsLoggedIn =
        await CacheDefault.cacheFactory.get('isLoggedIn') != null;
    if (!containsIsLoggedIn) {
      CacheDefault.cacheFactory.set('isLoggedIn', false);
    }
  }
}

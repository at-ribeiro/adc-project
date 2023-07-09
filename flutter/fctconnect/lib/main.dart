import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/Themes/theme_constant.dart';
import 'package:responsive_login_ui/Themes/theme_manager.dart';
import 'package:responsive_login_ui/data/cache_factory_provider.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/services/fcm_services.dart';
import 'package:responsive_login_ui/services/get_fcm_token.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'config/app_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'controller/simple_ui_controller.dart';

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

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await requestNotificationPermissions();

    Future<void> sendTokenToBackend() async {
      String? msgToken = await _firebaseMessaging.getToken();

      if (msgToken != null) {
        BaseClient().sendMessageToken(msgToken);
      }
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? firebaseToken = await messaging.getToken();
      print('Firebase Token: $firebaseToken');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // User granted permissions. Now we can get the token and send it to the backend
      sendTokenToBackend();
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: MyApp(session: session),
    ),
  );
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
//     ChangeNotifierProvider<ThemeNotifier>(create: (_ ) => ThemeNotifier());

void getKey() async {
  String? fcmKey = await FcmToken.getFcmToken();
  print("TOKEN : $fcmKey");
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  final String? session;

  MyApp({Key? key, this.session}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    Provider.of<ThemeManager>(context, listen: false)
        .addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeIsLoggedIn();
    final themeManager = Provider.of<ThemeManager>(context);
    return Consumer<ThemeManager>(builder: (context, themeManager, child) {
      return MaterialApp.router(
        routerConfig: AppRouter().router,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeManager.themeMode,
      );
    });
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

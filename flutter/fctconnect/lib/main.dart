import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/Themes/theme_constant.dart';
import 'package:responsive_login_ui/Themes/theme_manager.dart';
import 'package:responsive_login_ui/api/firebase_api.dart';
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


  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDqJdRjuqeuTWBoiSPHk3jr9wFCUF9ksOg",
          authDomain: "fctconnect-flutter.firebaseapp.com",
          projectId: "fctconnect-flutter",
          storageBucket: "fctconnect-flutter.appspot.com",
          messagingSenderId: "223517067321",
          appId: "1:223517067321:web:be1a93ee777f2337eea5e8"),
    );
  } else {
    await Firebase.initializeApp();
  }

  
   await FirebaseApi().initNotification();

  // Restore session from shared preferences

  String? session = await CacheDefault.cacheFactory.get('Session');

  Get.put(SimpleUIController());
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: MyApp(session: session),
    ),
  );
}

getKey() async {
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
        title: 'FCTConnect',
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

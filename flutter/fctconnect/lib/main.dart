import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_login_ui/views/signUp_view.dart';
import 'package:fluro/fluro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/signup', page: () => SignUpView()),
        
      ],
    );
  }


final router = FluroRouter();

void defineRoutes() {
  router.define('/signup', handler: Handler(handlerFunc: (_, __) => SignUpView()));

}

}

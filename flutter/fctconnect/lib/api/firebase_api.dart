import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../data/cache_factory_provider.dart';
import '../models/paths.dart';
import '../config/app_router.dart';
import '../services/base_client.dart';

Future<void> handleBackgorundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    Get.toNamed(Paths.notification);
  }


 Future<void> disableNotifications() async {
    if (!kIsWeb) {
      await _firebaseMessaging.deleteToken();
    }
    String? newToken = await _firebaseMessaging.getToken();

 CacheDefault.cacheFactory.set('NotificationState', 'false');
  
  }

    Future<void> reenableNotifications() async {
    if (!kIsWeb) {
      String? newToken = await _firebaseMessaging.getToken();
      
      if (newToken != null) {
        // This is your custom method for sending the token to your backend server.
        BaseClient().sendMessageToken(newToken);
      }
    }
     CacheDefault.cacheFactory.set('NotificationState', 'true');
  }
  Future initPushNotification() async {
  if(!kIsWeb){  await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );}

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgorundMessage);
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    if (!kIsWeb) {
      String? msgToken = await _firebaseMessaging.getToken();

      if (msgToken != null) {
        BaseClient().sendMessageToken(msgToken);
      }

      final fCMToken = await _firebaseMessaging.getToken();

      print('FCM Token: $fCMToken');
    }
    try {
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(handleBackgorundMessage);
      }
    } catch (error) {
      print('Firebase background messaging not available on web');
    }

     initPushNotification();

     CacheDefault.cacheFactory.set('NotificationState', 'true');
  }
}




import 'package:firebase_messaging/firebase_messaging.dart';

class FcmToken{
  
static Future<String?> getFcmToken() async {
  String? token;
  token = await FirebaseMessaging.instance.getToken().then((value) => token = value);
  return token;

}
}
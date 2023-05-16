import 'package:shared_preferences/shared_preferences.dart';

class SessionManager{


    static void storeSession(String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('session', s);
  }




}
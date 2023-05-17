import 'package:shared_preferences/shared_preferences.dart';

class SessionManager{


    static void storeSession( String n, String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(n, s);
  }

  static Future<void> delete(String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(s);
  }

  static Future<String?> get(String s) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(s);
  }





}
import 'dart:html' as html;

class CookieManager {
  
static String get(String name) {
  // Search for the cookie name in the cookie string
  final String cookie = html.document.cookie
      ?.split('; ')
      .firstWhere((row) => row.startsWith(name), orElse: () => "") ?? "";
  if (cookie.isNotEmpty) {
    final int idx = cookie.indexOf('=');
    return cookie.substring(idx + 1, cookie.length);
  } else {
    return '';
  }
}



  static void set(String name, String value) {
    // Set the cookie
    html.document.cookie = "$name=$value";
  }

  static void delete(String name) {
    // Delete the cookie by setting the value to an empty string and setting
    // the expiration date to a past date
    html.document.cookie = "$name=; expires=Thu, 01 Jan 1970 00:00:00 GMT";
  }
}

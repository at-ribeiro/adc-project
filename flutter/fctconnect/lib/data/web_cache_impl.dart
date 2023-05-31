import 'dart:html';

import 'cache_factory.dart';

class CacheFactoryImpl extends CacheFactory {
  @override
  void delete(String key) {
    final expiredDate = DateTime.now().subtract(const Duration(days: 1));
    final cookie = '$key=; expires=$expiredDate';
    document.cookie = cookie;
  }

  @override
  Future? get(String key) {
    
    final cookies = document.cookie;
    if(cookies!.isEmpty)
    return null;

    final cookieList = cookies!.split(';');

    for (final cookie in cookieList) {
      final keyValue = cookie.split('=');
      final cookieKey = keyValue[0].trim();
      final cookieValue = keyValue[1].trim();

      if (cookieKey == key) {
        return Future.value(cookieValue);
      }
    }
    return null; // Cookie with the specified key not found
  }

  @override
  void logout() {
    delete('Token');
    delete('Username');
    delete('Creationd');
    delete('Expirationd');
    delete('Role');
    delete('Session');
  }
  @override
  void login(String token, String username, String creationd,
      String expirationd, String role) {
    set('Token', token);
    set('Username', username);
    set('Creationd', creationd);
    set('Expirationd', expirationd);
    set('Role', role);
  }


  @override
  void printDB() {
    // TODO: implement printDB
  }

  @override
  void set(String key, dynamic value) {
  document.cookie = '$key=$value';
  }

  @override
  void initDB() {
    // TODO: implement initDB
  }
}

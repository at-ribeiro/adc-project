
import 'dart:async';

import 'package:responsive_login_ui/services/session_manager.dart';
import 'cache_factory.dart';

class CacheFactoryImpl extends CacheFactory {


CacheFactoryImpl._();


static final CacheFactoryImpl _instance = CacheFactoryImpl._();

factory CacheFactoryImpl() {
  return _instance;
}

  @override
  void delete(String key) {
    SessionManager.delete(key);
  }

  @override
  Future? get(String key) async {
  return SessionManager.get(key);
  }

  @override
  void initDB() async{
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
  void printDB() {
    // TODO: implement printDB
  }

  @override
  void set(String key, value) {
    SessionManager.storeSession(key
    , value);
  }
 
  
  @override
  void login(String token, String username, String creationd, String expirationd, String role) {
    set('Token', token);
    set('Username', username);
    set('Creationd', creationd);
    set('Expirationd', expirationd);
    set('Role', role);
  }
}

import 'dart:async';

import 'package:responsive_login_ui/dataBase/session_database.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'cache_factory.dart';

class CacheFactoryImpl extends CacheFactory {


CacheFactoryImpl._();

static Database? _database;

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
 
  FutureOr<void> _createDB(Database db, int version) {
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
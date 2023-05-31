
import 'stub_cache_factory.dart'
    if (dart.library.io) 'native_cache_impl.dart'
    if (dart.library.html) 'web_cache_impl.dart';

class CacheDefault {
  final CacheFactoryImpl _cacheFactoryImpl;

  CacheDefault() : _cacheFactoryImpl = CacheFactoryImpl();


  Future<dynamic>? get(String key) async {
    return _cacheFactoryImpl.get(key);
  }

  void set(String key, dynamic value) {
    _cacheFactoryImpl.set(key, value);
  }

  void delete(String key) {
    _cacheFactoryImpl.delete(key);
  }

  void logout() {
    _cacheFactoryImpl.logout();
  }

  void initDB() {
    _cacheFactoryImpl.initDB();
  }
  
  void printDB() {
    _cacheFactoryImpl.printDB();
  }

  void login(String token, String username, String creationd, String expirationd, String role) {
    _cacheFactoryImpl.login(token, username, creationd, expirationd, role);
  }

  static final CacheDefault cacheFactory = CacheDefault();
  
}

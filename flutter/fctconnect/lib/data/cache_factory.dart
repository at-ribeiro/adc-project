abstract class CacheFactory {
  void set (String key, dynamic value);
  Future<dynamic>? get (String key);
  void delete (String key);
  void logout();
  void initDB();
  void printDB();
  void login(String token, String username, String creationd,
      String expirationd, String role);
}


final String tableSession = 'session';

class SessionStorageDataFields{
  static final String token = 'token';
  static final String username = '_username';
  static final String isLoggedIn = 'isLoggedIn';
  static final String creationd = 'creationd';
  static final String expirationd = 'expirationd';
  static final String role = 'role';
  static final String session = 'session';
  
}

class SessionStorageData{



final int token;
final String username;
final bool isLoggedIn;
final int creationd;
final int expirationd;
final String role;
final String session;

const SessionStorageData({
  required this.token,
  required this.username,
  required this.isLoggedIn,
  required this.creationd,
  required this.expirationd,
  required this.role,
  required this.session,
});

}
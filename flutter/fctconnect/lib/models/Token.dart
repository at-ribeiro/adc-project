class Token {
  String username;
  String role;
  String tokenID;
  double creationDate;
  double expirationDate;

  Token({
    required this.username,
    required this.role,
    required this.tokenID,
    required this.creationDate,
    required this.expirationDate,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      username: json['username'],
      role: json['role'],
      tokenID: json['tokenID'],
      creationDate: json['creationDate'],
      expirationDate: json['expirationDate'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'role': role,
    'tokenID': tokenID,
    'creationTime': creationDate,
    'expirationTime': expirationDate,
  };
}

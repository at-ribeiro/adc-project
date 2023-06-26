class Token {
  String username;
  String role;
  String tokenID;
  int creationDate;
  int expirationDate;
  String profilePic;

  Token({
    required this.username,
    required this.role,
    required this.tokenID,
    required this.creationDate,
    required this.expirationDate,
    required this.profilePic,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      username: json['username'],
      role: json['role'],
      tokenID: json['tokenID'],
      creationDate: json['creationDate'],
      expirationDate: json['expirationDate'],
      profilePic: json['profilePic'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'role': role,
    'tokenID': tokenID,
    'creationTime': creationDate,
    'expirationTime': expirationDate,
    'profilePic': profilePic,
  };
}

class UserQueryData {
  final String username;
  final String fullname;
  


  UserQueryData({
    required this.username,
    required this.fullname,
 
  });

  factory UserQueryData.fromJson(Map<String, dynamic> json) {
    return UserQueryData(
      username: json['username'],
      fullname: json['fullname'],
    );
  }
}
class UserQueryData {
  final String username;
  final String fullname;
  final String profilePic;
  


  UserQueryData({
    required this.username,
    required this.fullname,
    required this.profilePic,
 
  });

  factory UserQueryData.fromJson(Map<String, dynamic> json) {
    return UserQueryData(
      username: json['username'],
      fullname: json['fullname'],
      profilePic: json['profilePic'],
    );
  }
}
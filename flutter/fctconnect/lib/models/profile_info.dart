class ProfileInfo {
  final String username;
  final String fullname;
  final String email;
  final String role;
  final int nFollowing;
  final int nFollowers;
  final int nPosts;



  ProfileInfo({
    required this.username,
    required this.fullname,
    required this.email,
    required this.role,
    required this.nFollowing,
    required this.nFollowers,
    required this.nPosts,

  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      username: json['username'],
      fullname: json['fullname'],
      email: json['email'],
      role: json['role'],
      nFollowing: json['nFollowing'],
      nFollowers: json['nFollowers'],
      nPosts: json['nPosts'],
 
    );
  }
}
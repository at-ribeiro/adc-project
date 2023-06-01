class ProfileInfo {
  
  final String fullname;




  ProfileInfo({
    required this.fullname,
  

  });

  factory ProfileInfo.toJson(Map<String, dynamic> json) {
    return ProfileInfo(
      fullname: json['fullname'],
    );
  }
}
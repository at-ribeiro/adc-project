import 'dart:typed_data';

class ProfileInfo {
  final String username;
  final String fullname;
  final String email;
  final String role;
  final int nFollowing;
  int nFollowers;
  int nPosts;
  final String about_me;
  final String phone;
  final String city;
  final String department;
  final String course;
  final String year;
  final int nGroups;
  final int nNucleos;
  final String purpose;
  final String office;
  final String privacy;
  final String profilePicUrl;
  final String coverPicUrl;
  Uint8List? profilePic;
  String? profilePicFileName;
  Uint8List? coverPic;
  String? coverPicFileName;

  ProfileInfo({
    required this.username,
    required this.fullname,
    required this.email,
    required this.role,
    required this.nFollowing,
    required this.nFollowers,
    required this.nPosts,
    required this.about_me,
    required this.phone,
    required this.city,
    this.department = '',
    this.course = '',
    this.year = '',
    this.nGroups = 0,
    this.nNucleos = 0,
    this.purpose = '',
    this.office = '',
    required this.privacy,
    this.profilePic,
    this.coverPic,
    this.profilePicFileName,
    this.coverPicFileName,
    required this.profilePicUrl,
    required this.coverPicUrl,
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
      phone: json['phone'],
      about_me: json['about_me'],
      city: json['city'],
      department: json['department'] ?? '',
      course: json['course'] ?? '',
      year: json['year'] ?? '',
      nGroups: json['nGroups'] ?? 0,
      nNucleos: json['nNucleos'] ?? 0,
      purpose: json['purpose'] ?? '',
      office: json['office'] ?? '',
      privacy: json['privacy'],
      profilePicFileName: json['profilePicFileName'],
      coverPicFileName: json['coverPicFileName'],
      profilePicUrl: json['profilePicUrl'],
      coverPicUrl: json['coverPicUrl'],

    );
  }
}

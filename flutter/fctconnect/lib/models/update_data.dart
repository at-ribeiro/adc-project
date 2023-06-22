class UpdateData {
  final String username;
  final String fullname;
  final String email;
  final String about_me;
  final String phone;
  final String city;
  final String department;
  final String course;
  final String year;
  final String purpose;
  final String office;
  final String privacy;

  UpdateData({
    required this.username,
    required this.fullname,
    required this.email,
    required this.about_me,
    required this.phone,
    required this.city,
    required this.department,
    required this.course,
    required this.year,
    required this.purpose,
    required this.office,
    required this.privacy,
  });

  factory UpdateData.fromJson(Map<String, dynamic> json) {
    return UpdateData(
      username: json['username'],
      fullname: json['fullname'],
      email: json['email'],
      phone: json['phone'],
      about_me: json['about_me'],
      city: json['city'],
      department: json['department'],
      course: json['course'],
      year: json['year'],
      purpose: json['purpose'],
      office: json['office'],
      privacy: json['privacy'],
    );
  }
}

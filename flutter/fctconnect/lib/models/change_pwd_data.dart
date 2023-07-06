class ChangePwdData {
  final String newPassword;
  final String oldPassword;
  final String passwordV;

  ChangePwdData({
    required this.newPassword, 
    required this.oldPassword,
    required this.passwordV,
  });

  factory ChangePwdData.fromJson(Map<String, dynamic> json) {
    return ChangePwdData(
      newPassword: json['newPassword'],
      oldPassword: json['oldPassword'],
      passwordV: json['passwordV'],
    );
  }
}
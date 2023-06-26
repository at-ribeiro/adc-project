class CommentData {
  final String user;
  final String text;
  final int timestamp;
  final String? profilePic;

  CommentData({
    required this.user, 
    required this.text,
    required this.timestamp,
    this.profilePic,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      user: json['user'],
      text: json['text'],
      timestamp: json['timestamp'],
      profilePic: json['profilePic'],
    );
  }
}
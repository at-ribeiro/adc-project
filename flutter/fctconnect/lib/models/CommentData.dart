class CommentData {
  final String username;
  final String text;
  final String url;
  final String timestamp;

  CommentData({
    required this.username,
    required this.text,
    required this.url,
    required this.timestamp,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      username: json['username'],
      text: json['text'],
      url: json['url'],
      timestamp: json['timestamp'],
    );
  }
}
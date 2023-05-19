class FeedData {
  final String id;
  final String text;
  final String user;
  final String url;
  final String timestamp;

  FeedData({
    required this.id,
    required this.text,
    required this.user,
    required this.url,
    required this.timestamp,
  });

  factory FeedData.fromJson(Map<String, dynamic> json) {
    return FeedData(
      id: json['id'],
      text: json['text'],
      user: json['user'],
      url: json['url'],
      timestamp: json['timestamp'],
    );
  }
}
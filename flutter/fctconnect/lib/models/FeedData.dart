class FeedData {
  final String id;
  final String text;
  final String user;
  final String url;
  final String profilePic;
  final String timestamp;
  final List<dynamic> likes;

  FeedData({
    required this.id,
    required this.text,
    required this.user,
    required this.url,
    required this.profilePic,
    required this.timestamp,
    required this.likes,
  });

  factory FeedData.fromJson(Map<String, dynamic> json) {
    return FeedData(
      id: json['id'],
      text: json['text'],
      user: json['user'],
      url: json['url'],
      profilePic: json['profilePic'],
      timestamp: json['timestamp'],
      likes:json['likes'],
    );
  }

  get postID => null;
}
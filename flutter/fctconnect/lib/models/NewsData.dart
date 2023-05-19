class NewsData {
  final String title;
  final String text;
  final String url;
  final String timestamp;

  NewsData({
    required this.title,
    required this.text,
    required this.url,
    required this.timestamp,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) {
    return NewsData(
      title: json['title'],
      text: json['text'],
      url: json['url'],
      timestamp: json['timestamp'],
    );
  }

}
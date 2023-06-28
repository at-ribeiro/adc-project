class NewsData {
  final String title;
  final String text;
  final String imageUrl;
  final String timestamp;
  final String newsUrl;

  NewsData({
    required this.title,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.newsUrl,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) {
    return NewsData(
      title: json['title'],
      text: json['text'],
      imageUrl: json['url'],
      timestamp: json['timestamp'],
      newsUrl: json['newsurl'],
    );
  }

}
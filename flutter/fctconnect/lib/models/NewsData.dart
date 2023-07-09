class NewsData {
  final String title;
  final String text;
  final String imageUrl;
  final String timestamp;
  final String newsUrl;
  final String path;
  final List<String>? paragraphs;
  NewsData({
    required this.title,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.newsUrl,
    required this.path,
    this.paragraphs,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) {
    return NewsData(
      title: json['title'],
      text: json['text'],
      imageUrl: json['url'],
      timestamp: json['timestamp'],
      newsUrl: json['newsurl'],
      path: json['path'],
    );
  }

}
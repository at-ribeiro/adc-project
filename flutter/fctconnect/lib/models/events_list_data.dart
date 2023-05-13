class EventsListData {
  final String id;
  final String text;
  final String user;
  final String url;
  final String timestamp;

  EventsListData({
    required this.id,
    required this.text,
    required this.user,
    required this.url,
    required this.timestamp,
  });

  factory EventsListData.fromJson(Map<String, dynamic> json) {
    return EventsListData(
      id: json['id'],
      text: json['text'],
      user: json['user'],
      url: json['url'],
      timestamp: json['timestamp'],
    );
  }
}
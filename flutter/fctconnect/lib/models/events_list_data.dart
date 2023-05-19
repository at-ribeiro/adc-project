class EventsListData {
  final String title;
  final String description;
  final String creator;
  final String url;
  final String start;
  final String end;

  EventsListData({
    required this.title,
    required this.description,
    required this.creator,
    required this.url,
    required this.start,
    required this.end

  });

  factory EventsListData.fromJson(Map<String, dynamic> json) {
    return EventsListData(
      title: json['title'],
      description: json['description'],
      creator: json['creator'],
      url: json['url'],
      start: json['start'],
      end: json['end'],
    );
  }
}
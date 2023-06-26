class EventGetData {
  final String creator;
  final String title;
  final String description;
  final String url;
  final int start;
  final int end;
  final String id;
  final String qrCodeUrl;
  final List<dynamic>? participants;
  final double lat;
  final double lng;
 
  EventGetData({
    required this.creator,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.lat,
    required this.lng,
    required this.url,
    required this.id,
    required this.qrCodeUrl,
    this.participants,
  });

  factory EventGetData.fromJson(Map<String, dynamic> json) {
    return EventGetData(
      title: json['title'],
      description: json['description'],
      creator: json['creator'],
      start: json['start'],
      end: json['end'],
      lat: json['lat'],
      lng: json['lng'],  
      url: json['url'],
      id: json['id'],
      qrCodeUrl: json['qrCodeUrl'],
      participants: json['participants'],
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';

class EventPostData {
  final String creator;
  final String title;
  final String description;
  final int start;
  final int end;
  Uint8List? imageData;
  String? fileName;
  final double lat;
  final double lng;
 
  EventPostData({
    required this.creator,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.lat,
    required this.lng,
    this.imageData,
    this.fileName,
  });

  factory EventPostData.fromJson(Map<String, dynamic> json) {
    return EventPostData(
      title: json['title'],
      description: json['description'],
      creator: json['creator'],
      start: json['start'],
      end: json['end'],
      lat: json['lat'],
      lng: json['lng'],      
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'creator': creator,
      'start': start,
      'end': end,
      'lat': lat,
      'lng': lng,
    };
  }

  String toJson() => json.encode(toMap());
}

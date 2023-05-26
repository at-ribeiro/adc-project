// To parse this JSON data, do
//
//     final registerUser = registerUserFromJson(jsonString);

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

class EventData {
  String? id;
  String creator;
  String title;
  String description;
  int start;
  int end;
   final String? url;
  Uint8List? imageData;
  String? fileName;

  EventData({
    this.id,
    required this.creator,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.imageData,
    this.fileName,
    this.url
  });

  Map<String, dynamic> toMap() => {
        "creator": creator,
        "title": title,
        "description": description,
        "start": start,
        "end": end,
      };

      factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      title: json['title'],
      description: json['description'],
      creator: json['creator'],
      url: json['url'],
      start: json['start'],
      end: json['end'],
      id: json['id'],
    );
  }
   
   String toJson() => json.encode(toMap());
}

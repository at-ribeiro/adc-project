// To parse this JSON data, do
//
//     final registerUser = registerUserFromJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';

class EventData {
  String?id;
  String creator;
  String title;
  String description;
  int start;
  int end;
  late List<String>? participants;
  final String? url;
  Uint8List? imageData;
  String? fileName;
  final String? qrcodeUrl;
 
  EventData({
    this.qrcodeUrl,
     this.id,
    required this.creator,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
     participants,
    this.imageData,
    this.fileName,
    this.url,
  });

  Map<String, dynamic> toMap() => {
        "creator": creator,
        "title": title,
        "description": description,
        "start": start,
        "end": end,
        "participants": participants,
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
      participants: json['participants'],
      qrcodeUrl: json['qrCodeUrl'],
    );
  }

  String toJson() => json.encode(toMap());
}

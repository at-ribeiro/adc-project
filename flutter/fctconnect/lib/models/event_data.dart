// To parse this JSON data, do
//
//     final registerUser = registerUserFromJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';

class EventData {
  String creator;
  String title;
  String description;
  int start;
  int end;
  Uint8List? imageData;
  String? fileName;

  EventData({
    required this.creator,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.imageData,
    this.fileName
  });

  Map<String, dynamic> toMap() => {
        "creator": creator,
        "title": title,
        "description": description,
        "data_inicio": start,
        "data_fim": end,
      };
   
   String toJson() => json.encode(toMap());
}

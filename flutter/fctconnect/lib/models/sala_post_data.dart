import 'dart:convert';

class SalaPostData {
  final String name;
  final String building;
  final double lat;
  final double lng;
  final int capacity;
 
  SalaPostData({
    required this.name,
    required this.building,
    required this.lat,
    required this.lng,
    required this.capacity,
  });

  factory SalaPostData.fromJson(Map<String, dynamic> json) {
    return SalaPostData(
      name: json['name'],
      building: json['building'],
      lat: json['lat'],
      lng: json['lng'],     
      capacity: json["capacity"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'building': building,
      'lat': lat,
      'lng': lng,
      "capacity" : capacity,
    };
  }

  String toJson() => json.encode(toMap());
}
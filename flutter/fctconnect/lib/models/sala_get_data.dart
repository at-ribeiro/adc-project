class SalaGetData {
  final String id;
  final String name;
  final String building;
  final double lat;
  final double lng;
  final int capacity;
 
  SalaGetData({
    required this.id,
    required this.name,
    required this.building,
    required this.lat,
    required this.lng,
    required this.capacity,
  });

  factory SalaGetData.fromJson(Map<String, dynamic> json) {
    return SalaGetData(
      id: json['id'],
      name: json['name'],
      building: json['building'],
      lat: json['lat'],
      lng: json['lng'],  
      //url: json['url'],
      capacity: json['capacity'],
    );
  }
}
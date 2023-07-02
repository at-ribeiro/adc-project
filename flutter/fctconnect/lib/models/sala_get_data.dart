class SalaGetData {
  final String name;
  final String building;
  final String url;
  final String id;
  //final String qrCodeUrl;
  final List<dynamic>? lotation;
  final double lat;
  final double lng;
  final int capacity;
 
  SalaGetData({
    required this.name,
    required this.building,
    required this.lat,
    required this.lng,
    required this.url,
    required this.id,
    this.lotation,
    required this.capacity,
  });

  factory SalaGetData.fromJson(Map<String, dynamic> json) {
    return SalaGetData(
      name: json['name'],
      building: json['building'],
      lat: json['lat'],
      lng: json['lng'],  
      url: json['url'],
      id: json['id'],
      //qrCodeUrl: json['qrCodeUrl'],
      lotation: json['lotation'],
      capacity: json['capacity'],
    );
  }
}
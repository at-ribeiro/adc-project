class LocationGetData {
  final String name;
  final double latitude;
  final double longitude;
  final String type;
  final String event;

 
  LocationGetData({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.event,
  });

  factory LocationGetData.fromJson(Map<String, dynamic> json) {
    return LocationGetData(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      type: json['type'],
      event: json['event'],
    );
  }
}

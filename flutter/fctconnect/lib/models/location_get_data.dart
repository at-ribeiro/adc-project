class LocationGetData {
  final String name;
  final double latitude;
  final double longitude;
  final String type;
  final String event;
  String duration; 

 
  LocationGetData({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.event,
    this.duration = '0 min',
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'event': event,
    };
  }
}

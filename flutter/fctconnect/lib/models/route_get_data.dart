import 'location_get_data.dart';

class RouteGetData {
  final String creator;
  final String name;
  final List<LocationGetData> locations;
  final List<int> durations;
  final List<String> participants;

  RouteGetData({
    required this.creator,
    required this.name,
    required this.locations,
    required this.durations,
    required this.participants,
  });

  factory RouteGetData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> locationsData = json['locations'];
    final List<LocationGetData> parsedLocations =
        List<LocationGetData>.from(
            locationsData.map((location) => LocationGetData.fromJson(location)));

    return RouteGetData(
      creator: json['creator'],
      name: json['name'],
      locations: parsedLocations,
      durations: List<int>.from(json['durations'] ?? []),
      participants: List<String>.from(json['participants'] ?? []),
    );
  }
}

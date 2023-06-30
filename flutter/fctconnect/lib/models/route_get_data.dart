class RouteGetData {
  final String creator;
  final String name;
  final List<String> locations;
  final List<String> participants;

  RouteGetData({
    required this.creator,
    required this.name,
    required this.locations,
    required this.participants,
  });

  factory RouteGetData.fromJson(Map<String, dynamic> json) {
    return RouteGetData(
      creator: json['creator'],
      name: json['name'],
      locations: json['locations'],
      participants: json['participants'],
    );
  }
}

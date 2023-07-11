class RoutePostData {
  final String creator;
  final String name;
  final List<String> locations;
  final List<int> durations;
  final List<dynamic> participants;

  RoutePostData({
    required this.creator,
    required this.name,
    required this.locations,
    required this.durations,
    required this.participants,
  });

  factory RoutePostData.fromJson(Map<String, dynamic> json) {
    return RoutePostData(
      creator: json['creator'],
      name: json['name'],
      locations: json['locations'],
      durations: json['durations'],
      participants: json['participants'],
    );
  }

}

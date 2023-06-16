class AlertPostData {
  final String creator;
  final String location;
  final String description;
  final int timestamp;

  AlertPostData({
    required this.creator,
    required this.location,
    required this.description,
    required this.timestamp,
  });

  factory AlertPostData.fromJson(Map<String, dynamic> json) {
    return AlertPostData(
      creator: json['creator'],
      location: json['location'],
      description: json['description'],
      timestamp: json['timestamp'],
    );
  }
}
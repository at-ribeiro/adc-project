class ActivityData {
  final String activityName;
  final int from;
  final int to;
  final String background;
  final String creationTime;

  ActivityData({
    required this.activityName, 
    required this.from,
    required this.to,
    required this.background,
    required this.creationTime,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      activityName: json['activityName'],
      to: json['to'],
      from: json['from'],
      background: json['background'],
      creationTime: json['creationTime'],
    );
  }
}
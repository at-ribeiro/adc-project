import 'dart:ui';

class Activity {
  Activity(this.activityName, this.from, this.to, this.background, this.creationTime);

  String activityName;
  DateTime from;
  DateTime to;
  Color background;
  String creationTime;
}
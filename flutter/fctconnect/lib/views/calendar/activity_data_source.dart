import 'dart:ui';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'activities.dart';

class ActivityDataSource extends CalendarDataSource{
  ActivityDataSource(List<Activity> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index){
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index){
    return appointments![index].to;
  }

  @override
  String getSubject(int index){
    return appointments![index].activityName;
  }

  @override
  Color getColor(int index){
    return appointments![index].background;
  }

  String getCreationTime(int index){
    return appointments![index].creationTime;
  }

}
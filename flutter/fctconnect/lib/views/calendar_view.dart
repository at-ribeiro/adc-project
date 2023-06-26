import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'calendar/activity_provider.dart';
import 'calendar/calendar_widget.dart';

class CalendarView extends StatelessWidget {
  
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ActivityProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CalendarWidget(),
      ),
    );
  }
}

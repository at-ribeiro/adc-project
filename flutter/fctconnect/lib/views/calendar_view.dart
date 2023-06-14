import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/models/Token.dart';

import 'calendar/activity_provider.dart';
import 'calendar/calendar_widget.dart';

class CalendarView extends StatelessWidget {
  final Token token;
  
  const CalendarView({Key? key, required this.token}) : super(key: key);

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
        home: CalendarWidget(token: token),
      ),
    );
  }
}
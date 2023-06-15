import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/Token.dart';
import '../../services/load_token.dart';
import 'activities.dart';
import 'activity_data_source.dart';
import 'activity_provider.dart';

class CalendarWidget extends StatefulWidget {

  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late Token _token;
  bool _isLoadingToken = true;
  CalendarView calendarView = CalendarView.month;
  CalendarController calendarController = CalendarController();
  TextEditingController activityNameController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    activityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
          });
        });
      });
    } else {
      final provider = Provider.of<ActivityProvider>(context);

      if (!_isInitialized) {
        provider.initializeActivities(_token);
        _isInitialized = true;
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text("Calendário"),
          actions: [
            IconButton(
              onPressed: () {
                provider.addActivity(context, _token);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      calendarView = CalendarView.month;
                      calendarController.view = calendarView;
                    });
                  },
                  child: Text("Por Mês"),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      calendarView = CalendarView.week;
                      calendarController.view = calendarView;
                    });
                  },
                  child: Text("Por Semana"),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      calendarView = CalendarView.day;
                      calendarController.view = calendarView;
                    });
                  },
                  child: Text("Por Dia"),
                ),
              ],
            ),
            Expanded(
              child: SfCalendar(
                view: calendarView,
                showNavigationArrow: true,
                initialSelectedDate: DateTime.now(),
                controller: calendarController,
                dataSource: ActivityDataSource(provider.activities),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  showAgenda: true,
                ),
                onTap: (CalendarTapDetails details) {
                  if (details.targetElement == CalendarElement.appointment) {
                    final Activity tappedActivity =
                        details.appointments!.first as Activity;
                    provider.updateActivity(context, tappedActivity, _token);
                  }
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}

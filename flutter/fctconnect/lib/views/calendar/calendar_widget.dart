import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/models/Token.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'activities.dart';
import 'activity_data_source.dart';
import 'activity_provider.dart';

class CalendarWidget extends StatefulWidget {
  final Token token;

  const CalendarWidget({Key? key, required this.token}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late Token _token;
  CalendarView calendarView = CalendarView.month;
  CalendarController calendarController = CalendarController();
  TextEditingController activityNameController = TextEditingController();


  @override
  void initState() {
    _token = widget.token;
    super.initState();
  }

  @override
  void dispose() {
    activityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context);
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

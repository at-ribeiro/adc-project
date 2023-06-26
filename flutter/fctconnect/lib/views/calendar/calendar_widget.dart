import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/constants.dart';
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

      return FutureBuilder(
        future: provider.initializeActivities(_token),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: kBorderRadius,
              ),
              backgroundColor: kAccentColor0.withOpacity(0.3),
              content: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: kAccentColor1,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error initializing activities: ${snapshot.error}');
          } else {
            return Container(
              decoration: kGradientDecorationDown,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: FloatingActionButton(
                  backgroundColor: kPrimaryColor,
                  onPressed: () {
                    provider.addActivity(context, _token);
                  },
                  child: const Icon(Icons.add, color: kAccentColor0),
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
                          color: kAccentColor2.withOpacity(0.1),
                          border: Border.all(color: kSecondaryColor, width: 3),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(7)),
                          shape: BoxShape.rectangle,
                        ),
                        monthViewSettings: const MonthViewSettings(
                          appointmentDisplayMode:
                              MonthAppointmentDisplayMode.indicator,
                          showAgenda: true,
                          monthCellStyle: MonthCellStyle(
                            textStyle: TextStyle(
                              color: kAccentColor0,
                              fontSize: 16,
                            ),
                            trailingDatesTextStyle: TextStyle(
                              color: kAccentColor0,
                              fontSize: 16,
                            ),
                            leadingDatesTextStyle: TextStyle(
                              color: kAccentColor0,
                              fontSize: 16,
                            ),
                            todayTextStyle: TextStyle(
                              color: kAccentColor0,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        onTap: (CalendarTapDetails details) {
                          if (details.targetElement ==
                              CalendarElement.appointment) {
                            final Activity tappedActivity =
                                details.appointments!.first as Activity;
                            provider.updateActivity(
                                context, tappedActivity, _token);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    }
  }
}

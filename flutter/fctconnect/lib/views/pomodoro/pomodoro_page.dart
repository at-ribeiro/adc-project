import 'dart:async';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:responsive_login_ui/constants.dart';

import 'my_helprer.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({Key? key}) : super(key: key);

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const String POMODORO = "Pomodoro";
  static const String SHORT_BREAK = "ShortBreak";
  static const String LONG_BREAK = "LongBreak";

  bool mainPressed = false;

  String mainButtonAction = "start";
  String focus = "hora de focar";
  String message = "hora de focar";
  String rest = "hora do intervalo";

 

  var timerDetails = {
    "pomodoro": 25,
    "shortBreak": 5,
    "longBreak": 15,
    "longBreakInterval": 4,
    "session": 0,
    "mode": "pomodoro",
    "remainingTime": {"total": 25 * 60, "minute": 25, "second": 0}
  };
  late Timer interval = Timer(const Duration(seconds: 1), () {});

  String minutes = "25";
  String seconds = "00";

  List<String> tasks = [];
  String currentTask = "tarefa atual";

  void switchColor(String mode) {
    setState(() {
      // if(mode == POMODORO) {

      //     backgroundColor = MyHelper.tomadonoBackgroundColor;
      //     buttonsColor = MyHelper.tomadonoButtonColor;
      // } else if(mode == SHORT_BREAK) {

      //     backgroundColor = MyHelper.shortBreakBackgroundColor;
      //     buttonsColor = MyHelper.shortBreakButtonColor;
      // } else if(mode == LONG_BREAK) {

      //     backgroundColor = MyHelper.longBreakBackgroundColor;
      //     buttonsColor = MyHelper.longBreakButtonColor;
      // }
    });
  }

  void switchMode(String mode) {
    stopTimer();
    timerDetails["mode"] = mode;
    int time = (timerDetails[mode] ?? 0) as int;
    timerDetails["remainingTime"] = {
      "total": time * 60,
      "minute": timerDetails[mode],
      "second": 0
    };

    setState(() {
      if (mode == POMODORO) {
        message = focus;
      } else {
        message = rest;
      }
    });

    switchColor(mode);
    updateClock();
  }

  void updateClock() {
    Map remainingTime = timerDetails["remainingTime"] as Map;
    setState(() {
      minutes = "${remainingTime["minute"]}".padLeft(2, "0");
      seconds = "${remainingTime["second"]}".padLeft(2, "0");
    });
  }

  void startTimer() {
    Map remainingTime = timerDetails["remainingTime"] as Map;
    int total = remainingTime["total"];
    var endTime = DateTime.now().add(Duration(seconds: total));

    if (timerDetails["mode"] == POMODORO) {
      timerDetails["session"] = (timerDetails["session"] as int) + 1;
    }

    setState(() {
      mainButtonAction = "stop";
      mainPressed = true;
    });

    interval = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerDetails["remainingTime"] = getRemainingTime(endTime);
      updateClock();

      Map remainingTime = timerDetails["remainingTime"] as Map;
      int total = remainingTime["total"];
      if (total <= 0) {
        interval.cancel();
        HapticFeedback.vibrate();

        switch (timerDetails["mode"]) {
          case POMODORO:
            int timerSession = timerDetails["session"] as int;
            int longBreakInterval = timerDetails["longBreakInterval"] as int;

            if (timerSession % longBreakInterval == 0) {
              switchMode(LONG_BREAK);
            } else {
              switchMode(SHORT_BREAK);
            }
            break;
          default:
            switchMode(POMODORO);
        }
        startTimer(); // Restart the timer for the break section
      }
    });
  }

  void stopTimer() {
    interval.cancel();
    setState(() {
      mainButtonAction = "start";
      mainPressed = false;
    });
  }

  Map<String, int> getRemainingTime(DateTime endTime) {
    DateTime currentTime = DateTime.now();
    Duration different = endTime.difference(currentTime);

    int total = different.inSeconds;
    int minute = different.inMinutes;
    int second = total % 60;

    return {"total": total, "minute": minute, "second": second};
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // audioPlayer.dispose();
    taskController.dispose();
  }

  final taskController = TextEditingController();
  void showTaskDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Style.kAccentColor2Light.withOpacity(0.5),
            title: Text("Registe uma tarefa"),
            content: Padding(
              padding: EdgeInsets.all(0),
              child: Form(
                child: TextFormField(
                  controller: taskController,
                  decoration: InputDecoration(
                      labelText: "nome da tarefa", icon: Icon(Icons.edit)),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // print(taskController.text);
                    setState(() {
                      tasks.add(taskController.text);
                    });
                  },
                  child: Text("Ok"))
            ],
          );
        });
  }

  void showSettingDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 50,
              child: const Center(
                child: Text("Made by Tran Thanh Tung and he likes milk tea"),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("ok"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showTaskDialog();
          },
          child: Icon(Icons.add),
        ),
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TomadonoButton(
                            callback: () {
                              switchMode(POMODORO);
                            },
                            buttonText: "Pomodoro",
                            buttonColor: Theme.of(context).primaryColor),
                        TomadonoButton(
                            callback: () {
                              switchMode(LONG_BREAK);
                            },
                            buttonText: "long break",
                            buttonColor:Theme.of(context).primaryColor),
                        TomadonoButton(
                            callback: () {
                              switchMode(SHORT_BREAK);
                            },
                            buttonText: "short break",
                            buttonColor:Theme.of(context).primaryColor),
                      ],
                    ),
                    Text(
                      "$message\n[$currentTask]",
                      textAlign: TextAlign.center,
                      style: textTheme.headline5?.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "$minutes:$seconds",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 80),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (mainButtonAction == "start") {
                            startTimer();
                          } else {
                            stopTimer();
                          }
                        },
                        child: Text(
                          mainButtonAction,
                          style:
                              TextStyle(fontSize: 28, color: Theme.of(context).primaryColor),
                        ))
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).indicatorColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              "  Minhas tarefas.",
                              style: textTheme.headline6!.copyWith(
                                color: Theme.of(context).primaryColor,
                              )
                            )),
                        Expanded(
                          flex: 3,
                          child: ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(
                                        height: 2,
                                      ),
                              itemCount: tasks.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Theme.of(context).primaryColor),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .indicatorColor,)),
                                        onPressed: () {
                                          setState(() {
                                            currentTask = tasks[index];
                                          });
                                        },
                                        child: Center(
                                          child: Text(
                                            tasks[index],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .iconTheme.color),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            print("Remove at $index");
                                            setState(() {
                                              tasks.removeAt(index);
                                            });
                                          },
                                        ))
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TomadonoButton extends StatelessWidget {
  VoidCallback callback;
  String buttonText;
  Color buttonColor;
  TomadonoButton(
      {Key? key,
      required this.callback,
      required this.buttonText,
      required this.buttonColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: callback,
        child: Text(
          buttonText,
        ));
  }
}

class TomadonoTaskButton extends StatelessWidget {
  VoidCallback callback;
  String buttonText;
  Color buttonColor;
  TomadonoTaskButton(
      {Key? key,
      required this.callback,
      required this.buttonText,
      required this.buttonColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(onPressed: callback, child: Text(buttonText)),
        ),
      ],
    );
  }
}

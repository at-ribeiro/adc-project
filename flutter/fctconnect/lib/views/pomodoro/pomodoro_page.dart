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
  static const String POMODORO = "pomodoro";
  static const String SHORT_BREAK = "shortBreak";
  static const String LONG_BREAK = "longBreak";

  bool mainPressed = false;

  String mainButtonAction = "start";
  String focus = "time to focus";
  String message = "time to focus";
  String rest = "time to take a break";

  Color backgroundColor = Style.kPrimaryColor;
  Color buttonsColor = Style.kPrimaryColor;

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
  String currentTask = "your task";

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
        // audioPlayer.play();
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
        startTimer();
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
            title: Text("Enter task"),
            content: Padding(
              padding: EdgeInsets.all(0),
              child: Form(
                child: TextFormField(
                  controller: taskController,
                  decoration: InputDecoration(
                      labelText: "task's name", icon: Icon(Icons.edit)),
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // print(taskController.text);
                    setState(() {
                      tasks.add(taskController.text);
                    });
                  },
                  child: Text("ok"))
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
    return Container(
      decoration: Style.kGradientDecorationUp,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                            buttonColor: buttonsColor),
                        TomadonoButton(
                            callback: () {
                              switchMode(LONG_BREAK);
                            },
                            buttonText: "long break",
                            buttonColor: buttonsColor),
                        TomadonoButton(
                            callback: () {
                              switchMode(SHORT_BREAK);
                            },
                            buttonText: "short break",
                            buttonColor: buttonsColor),
                      ],
                    ),
                    Text(
                      "$message\n[$currentTask]",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2),
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
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Style.kAccentColor0),
                        ),
                        child: Text(
                          mainButtonAction,
                          style:
                              TextStyle(fontSize: 28, color: backgroundColor),
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
                    color: Style.kAccentColor0,
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
                              "   my tasks",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Style.kPrimaryColor,
                                  fontWeight: FontWeight.bold),
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
                                                    backgroundColor),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Style.kAccentColor0)),
                                        onPressed: () {
                                          setState(() {
                                            currentTask = tasks[index];
                                          });
                                        },
                                        child: Center(
                                          child: Text(
                                            tasks[index],
                                            style:
                                                TextStyle(color: Style.kAccentColor1),
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
                        Expanded(
                            flex: 2,
                            child: TomadonoTaskButton(
                              callback: () {
                                showTaskDialog();
                              },
                              buttonText: "+ add task +",
                              buttonColor: buttonsColor,
                            )),
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

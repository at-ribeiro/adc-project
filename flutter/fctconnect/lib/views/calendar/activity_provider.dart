import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:responsive_login_ui/models/ActivityData.dart';
import '../../models/Token.dart';
import '../../services/base_client.dart';
import 'activities.dart';

class ActivityProvider extends ChangeNotifier {
  List<Activity> activities = [];

  Future<void> initializeActivities(Token token) async {
    List<ActivityData> activitiesData = await BaseClient()
        .getActivities("/activity", token.username, token.tokenID);
    for(var activity in activitiesData){
      activities.add(
        Activity(
        activity.activityName,
        DateTime.fromMillisecondsSinceEpoch(activity.from),
        DateTime.fromMillisecondsSinceEpoch(activity.to),
        Color(int.parse("0xFF${activity.background}")),
        activity.creationTime,
      )
      );
    }
  }

  void addActivity(BuildContext context, Token token) async {
    final TextEditingController nameController = TextEditingController();
    Color? selectedColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CreateActivityDialog(
          nameController: nameController,
          selectedColor: selectedColor,
          onAdd: (activity) {
            activities.add(activity);
            ActivityData a = ActivityData(
              activityName: activity.activityName,
              from: activity.from.millisecondsSinceEpoch,
              to: activity.to.millisecondsSinceEpoch,
              background: activity.background.value
                  .toRadixString(16)
                  .substring(2)
                  .toUpperCase(),
              creationTime: activity.creationTime,
            );

            BaseClient()
                .createActivity("/activity", token.username, token.tokenID, a);
            notifyListeners();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void updateActivity(
      BuildContext context, Activity activity, Token token) async {
    final TextEditingController nameController =
        TextEditingController(text: activity.activityName);
    Color? selectedColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _UpdateActivityDialog(
          nameController: nameController,
          selectedColor: selectedColor,
          originalActivity: activity,
          onUpdate: (updatedActivity) {
            final index = activities.indexOf(activity);
            if (index != -1) {
              activities[index] = updatedActivity;
              ActivityData a = ActivityData(
                activityName: updatedActivity.activityName,
                from: updatedActivity.from.millisecondsSinceEpoch,
                to: updatedActivity.to.millisecondsSinceEpoch,
                background: updatedActivity.background.value
                    .toRadixString(16)
                    .substring(2)
                    .toUpperCase(),
                creationTime: updatedActivity.creationTime,
              );
              BaseClient().updateActivity(
                  "/activity", token.username, token.tokenID, a);

              notifyListeners();
            }
            Navigator.pop(context);
          },
          onDelete: () {
            activities.remove(activity);
            BaseClient().deleteActivity("/activity", token.username,
                token.tokenID, activity.creationTime);
            notifyListeners();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _CreateActivityDialog extends StatefulWidget {
  final TextEditingController nameController;
  final Color? selectedColor;
  final void Function(Activity) onAdd;

  const _CreateActivityDialog({
    Key? key,
    required this.nameController,
    required this.selectedColor,
    required this.onAdd,
  }) : super(key: key);

  @override
  _CreateActivityDialogState createState() => _CreateActivityDialogState();
}

class _CreateActivityDialogState extends State<_CreateActivityDialog> {
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  Color? selectedColor;

  void _showColorPicker(BuildContext context) async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolha a cor'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor ?? Colors.white,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedColor);
              },
              child: Text('Selecione'),
            ),
          ],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        selectedColor = pickedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Criar Atividade'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Nome',
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          startDate = selectedDate;
                          startTime = selectedTime;
                        });
                      }
                    }
                  },
                  child: Text('Selecione data de inicio'),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            startDate != null && startTime != null
                ? '${startTime!.format(context)} ${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year.toString()}'
                : 'Data de início não selecionada',
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          endDate = selectedDate;
                          endTime = selectedTime;
                        });
                      }
                    }
                  },
                  child: Text('Selecione data de fim'),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            endDate != null && endTime != null
                ? '${endTime!.format(context)} ${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year.toString()}'
                : 'Data de fim não selecionada',
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _showColorPicker(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selectedColor ?? Colors.white,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Voltar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (startDate != null &&
                startTime != null &&
                endDate != null &&
                endTime != null &&
                selectedColor != null) {
              final activity = Activity(
                  widget.nameController.text,
                  DateTime(startDate!.year, startDate!.month, startDate!.day,
                      startTime!.hour, startTime!.minute),
                  DateTime(endDate!.year, endDate!.month, endDate!.day,
                      endTime!.hour, endTime!.minute),
                  selectedColor!,
                  (DateTime.now().microsecondsSinceEpoch).toString());
              widget.onAdd(activity);
            }
          },
          child: Text('Adicionar'),
        ),
      ],
    );
  }
}

class _UpdateActivityDialog extends StatefulWidget {
  final TextEditingController nameController;
  final Color? selectedColor;
  final Activity originalActivity;
  final void Function(Activity) onUpdate;
  final void Function() onDelete;

  const _UpdateActivityDialog({
    Key? key,
    required this.nameController,
    required this.selectedColor,
    required this.originalActivity,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _UpdateActivityDialogState createState() => _UpdateActivityDialogState();
}

class _UpdateActivityDialogState extends State<_UpdateActivityDialog> {
  Color? selectedColor;
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  void _showColorPicker(BuildContext context) async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolha a cor'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor ?? widget.originalActivity.background,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedColor);
              },
              child: Text('Selecione'),
            ),
          ],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        selectedColor = pickedColor;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the date and time values with the original activity's start and end dates
    startDate = widget.originalActivity.from;
    startTime = TimeOfDay.fromDateTime(widget.originalActivity.from);
    endDate = widget.originalActivity.to;
    endTime = TimeOfDay.fromDateTime(widget.originalActivity.to);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Atualizar Atividade'),
          Spacer(),
          SizedBox(
            width: 8,
          ),
          IconButton(
            onPressed: () {
              widget.onDelete();
            },
            icon: Icon(Icons.delete),
          )
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Nome',
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: startTime ?? TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          startDate = selectedDate;
                          startTime = selectedTime;
                        });
                      }
                    }
                  },
                  child: Text('Selecione data de início'),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            startDate != null && startTime != null
                ? '${startTime!.format(context)} ${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year.toString()}'
                : 'Data de início não selecionada',
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: endTime ?? TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          endDate = selectedDate;
                          endTime = selectedTime;
                        });
                      }
                    }
                  },
                  child: Text('Selecione data de fim'),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            endDate != null && endTime != null
                ? '${endTime!.format(context)} ${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year.toString()}'
                : 'Data de fim não selecionada',
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _showColorPicker(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selectedColor ?? widget.originalActivity.background,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Voltar'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedActivity = Activity(
                widget.nameController.text,
                DateTime(
                  startDate!.year,
                  startDate!.month,
                  startDate!.day,
                  startTime!.hour,
                  startTime!.minute,
                ),
                DateTime(
                  endDate!.year,
                  endDate!.month,
                  endDate!.day,
                  endTime!.hour,
                  endTime!.minute,
                ),
                selectedColor ?? widget.originalActivity.background,
                widget.originalActivity.creationTime);
            widget.onUpdate(updatedActivity);
          },
          child: Text('Atualizar'),
        ),
      ],
    );
  }
}

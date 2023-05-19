import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/events_list_data.dart';

class EventPage extends StatefulWidget {
  final EventsListData event;


  const EventPage({required this.event});

  @override
  _EventPageState createState() => _EventPageState();
}


class _EventPageState extends State<EventPage> {
  bool isButtonPressed = false;
  late String buttonLabel;
  @override
  void initState() {
    super.initState();
    buttonLabel = "Entrar no evento";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.event.url,
              fit: BoxFit.cover,
              height: 400, // Set the desired height for the banner image
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Description: ${widget.event.description}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Creator: ${widget.event.creator}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start Date & Time: ' +
                        DateFormat('dd-MM-yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(widget.event.start),
                          ),
                        ),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'End Date & Time: ' +
                        DateFormat('dd-MM-yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(widget.event.end),
                          ),
                        ),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        
                        onPressed: () {
                          setState(() {
                            isButtonPressed = !isButtonPressed;
            
                           
                              buttonLabel = isButtonPressed ? "Sair do evento" : "Entrar no evento";
                          
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (states.contains(MaterialState.pressed) || isButtonPressed) {
                                return Color.fromARGB(255, 170, 170, 170); // Change to desired pressed color
                              }
                              return Colors.blue; // Change to desired default color
                            },
                          ),
                        ),
                        child: Text(
                          buttonLabel,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

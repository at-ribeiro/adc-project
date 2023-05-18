import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/events_list_data.dart';

class EventPage extends StatelessWidget {
  final EventsListData event;

  const EventPage({required this.event});

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
              event.url,
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
                    event.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Description: ${event.description}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Creator: ${event.creator}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start Date & Time: ' +
                        DateFormat('dd-MM-yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(event.start),
                          ),
                        ),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'End Date & Time: ' +
                        DateFormat('dd-MM-yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(event.end),
                          ),
                        ),
                    style: TextStyle(fontSize: 16),
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

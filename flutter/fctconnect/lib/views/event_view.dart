import 'package:flutter/material.dart';
import 'package:responsive_login_ui/views/search_event_view.dart';

class EventView extends StatefulWidget {
  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  List<String> events = [];
  List<String> filteredEvents = [];

  TextEditingController eventController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  void addEvent() {
    String newEvent = eventController.text;
    if (newEvent.isNotEmpty) {
      setState(() {
        events.add(newEvent);
        eventController.clear();
        filteredEvents = List.from(events);
      });
    }
  }

  void filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredEvents = List.from(events);
      } else {
        filteredEvents = events
            .where((event) => event.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> personEvents = ['Event 1', 'Event 2', 'Event 3'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Registration'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: eventController,
              decoration: InputDecoration(
                labelText: 'Event Name',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: addEvent,
            child: Text('Register Event'),
          ),
          Padding(padding: const EdgeInsets.all(16.0)),
          ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchEventView(),
                  ),
                );
              },
              child: Text('Pesquisar outros eventos')),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredEvents[index]),
                );
              },
            ),
          ),
          PersonEventsWidget(
            personName: 'John Doe',
            events: personEvents,
          ),
        ],
      ),
    );
  }
}

class PersonEventsWidget extends StatelessWidget {
  final String personName;
  final List<String> events;

  PersonEventsWidget({
    required this.personName,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Events for $personName:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: events.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(events[index]),
            );
          },
        ),
      ],
    );
  }
}

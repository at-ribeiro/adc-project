import 'package:flutter/material.dart';
import 'package:responsive_login_ui/views/event_creator.dart';
import 'package:responsive_login_ui/views/search_event_view.dart';

import '../models/Token.dart';

class EventView extends StatefulWidget {
  final Token token;

  const EventView({Key? key, required this.token}) : super(key: key);

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  List<String> events = [];
  List<String> filteredEvents = [];
  late Token _token;

  TextEditingController eventController = TextEditingController();
  TextEditingController searchController = TextEditingController();

   @override
  void initState() {
    super.initState();
    _token = widget.token;
  }

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
        title: Text('Eventos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: eventController,
              decoration: InputDecoration(
                labelText: 'Nome do Evento',
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchEventView(),
                  ),
                );
              },
              child: const Text('Pesquisar outros eventos')),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventCreator(
                    event: '',
                  ),
                ),
              );
            },
            child: const Text('Registar Evento'),
          ),
          Padding(padding: const EdgeInsets.all(16.0)),
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
            personName: _token.username,
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

  const PersonEventsWidget({
    required this.personName,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
          child: Text(
            'Eventos de $personName:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
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

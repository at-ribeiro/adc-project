import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:responsive_login_ui/models/events_list_data.dart';
import 'package:responsive_login_ui/views/event_creator.dart';
import 'package:responsive_login_ui/views/search_event_view.dart';

import '../models/Token.dart';
import '../services/base_client.dart';
import '../models/event_data.dart';

class EventView extends StatefulWidget {
  final Token token;

  const EventView({Key? key, required this.token}) : super(key: key);

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  String _eventText = '';
  Uint8List? _imageData;
  String? _fileName;
  List<EventsListData> _events = [];
  List<String> filteredEvents = [];
  late Token _token;
  bool _loadingMore = false;
  String _lastDisplayedEventTimestamp =
      DateTime.now().millisecondsSinceEpoch.toString();

  late ScrollController _scrollController;

  TextEditingController eventController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadEvents();
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
                    token: _token
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

  void _loadEvents() async {
    List<EventsListData> events = await BaseClient().getEvents("/events",
        _token.tokenID, _token.username, _lastDisplayedEventTimestamp);
    if (mounted) {
      setState(() {
        _events = events;
        if (events.isNotEmpty) {
          _lastDisplayedEventTimestamp = events.last.timestamp;
        }
      });
    }
  }

   Future<void> _refreshEvents() async {
    _lastDisplayedEventTimestamp =
        DateTime.now().millisecondsSinceEpoch.toString();
    List<EventsListData> latestEvents = await BaseClient().getEvents("/events",
        _token.tokenID, _token.username, _lastDisplayedEventTimestamp);
    setState(() {
      _events = latestEvents;
      if (latestEvents.isNotEmpty) {
        _lastDisplayedEventTimestamp = latestEvents.last.timestamp;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _loadEvents();
    }
  }
}

  @override
  Widget build(BuildContext context) {
    var personName;
    var events;
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
      ],
      
    );
  }

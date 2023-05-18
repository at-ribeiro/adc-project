import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/events_list_data.dart';
import 'package:responsive_login_ui/views/event_creator.dart';
import 'package:responsive_login_ui/views/search_event_view.dart';

import '../models/Token.dart';
import '../services/base_client.dart';
import '../models/event_data.dart';
import 'event_page.dart';

class EventView extends StatefulWidget {
  final Token token;

  const EventView({Key? key, required this.token}) : super(key: key);

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  List<EventsListData> _events = [];
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchEventView(),
                    ),
                  );
                },
                child: const Text('Pesquisar outros eventos'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventCreator(
                        token: _token,
                      ),
                    ),
                  );
},
                child: const Text('Registar Evento'),
              )
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshEvents,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _events.length + (_loadingMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= _events.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    EventsListData event = _events[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (ctx) => EventPage(event: event),
                          ),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (event.url.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    event.url,
                                    width: 220,
                                    height: 150,
                                    fit: BoxFit.cover,
),
                                ),
                              const SizedBox(width: 7.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Start Date & Time: ' +
                                          DateFormat('dd-MM-yyyy HH:mm:ss')
                                              .format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(event.start),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'End Date & Time: ' +
                                          DateFormat('dd-MM-yyyy HH:mm:ss')
                                              .format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(event.end),
                                        ),
                                      ),
style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
),
    );
  }

  void _loadEvents() async {
    List<EventsListData> events = await BaseClient().getEvents(
      "/events",
      _token.tokenID,
      _token.username,
      _lastDisplayedEventTimestamp,
    );
    if (mounted) {
      setState(() {
        _events = events;
        if (events.isNotEmpty) {
          _lastDisplayedEventTimestamp = events.last.start;
        }
      });
    }
  }

  Future<void> _refreshEvents() async {
_lastDisplayedEventTimestamp =
        DateTime.now().millisecondsSinceEpoch.toString();
    List<EventsListData> latestEvents = await BaseClient().getEvents(
      "/events",
      _token.tokenID,
      _token.username,
      _lastDisplayedEventTimestamp,
    );
    setState(() {
      _events = latestEvents;
      if (latestEvents.isNotEmpty) {
        _lastDisplayedEventTimestamp = latestEvents.last.start;
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
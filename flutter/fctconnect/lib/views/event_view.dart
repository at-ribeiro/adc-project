import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:responsive_login_ui/models/paths.dart';

import '../constants.dart';
import '../models/Token.dart';
import '../models/event_get_data.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class EventView extends StatefulWidget {
  const EventView({Key? key}) : super(key: key);

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  List<EventGetData> _events = [];
  late Token _token;
  bool _isLoadingToken = true;
  bool _loadingMore = false;
  int _lastDisplayedEventTimestamp = DateTime.now().millisecondsSinceEpoch;

  late ScrollController _scrollController;

  TextEditingController eventController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
            _loadEvents();
          });
        });
      });
    } else {
      return Container(
   
        child: Scaffold(

          body: Column(
            children: [
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
                        EventGetData event = _events[index];
                        return GestureDetector(
                          onTap: () {
                            context.go('${Paths.event}/${event.id}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: Style.kBorderRadius,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 50.0, sigmaY: 50.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Style.kAccentColor2.withOpacity(0.1),
                                    borderRadius: Style.kBorderRadius,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (event.url != null)
                                          ClipRRect(
                                            borderRadius: Style.kBorderRadius,
                                            child: Image.network(
                                              event.url!,
                                              width: 220,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        const SizedBox(width: 7.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                             
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Start Date & Time: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    event.start,
                                                  ),
                                                )}',
                                                style: TextStyle(
                                               
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'End Date & Time: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    event.end,
                                                  ),
                                                )}',
                                                style: TextStyle(
                                                  
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
        ),
      );
    }
  }

  void _loadEvents() async {
    List<EventGetData> events = await BaseClient().getEvents(
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
    _lastDisplayedEventTimestamp = DateTime.now().millisecondsSinceEpoch;
    List<EventGetData> latestEvents = await BaseClient().getEvents(
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

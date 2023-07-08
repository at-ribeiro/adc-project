import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/events_list_data.dart';
import 'package:responsive_login_ui/models/paths.dart';
import 'package:responsive_login_ui/views/event_creator.dart';
import 'package:responsive_login_ui/views/search_event_view.dart';

import '../constants.dart';
import '../models/Token.dart';
import '../models/event_get_data.dart';
import '../models/route_get_data.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import 'event_page.dart';

class RouteView extends StatefulWidget {
  const RouteView({Key? key}) : super(key: key);

  @override
  State<RouteView> createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> {
  List<RouteGetData> _routes = [];
  late Token _token;
  bool _isLoadingToken = true;
  bool _loadingMore = false;

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
            _loadRoutes();
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
                  onRefresh: _refreshRoutes,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _routes.length + (_loadingMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= _routes.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        RouteGetData route = _routes[index];
                        return GestureDetector(
                          onTap: () {
                            //context.go(Paths.event + '/${event.id}');
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
                                        //adicionar cenas
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                route.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Style.kAccentColor0,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                route.creator,
                                                style: TextStyle(
                                                  color: Style.kAccentColor2,
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

  void _loadRoutes() async {
    List<RouteGetData> routes =
        await BaseClient().getRoutes("/route", _token.tokenID, _token.username);
    if (mounted) {
      setState(() {
        _routes = routes;
      });
    }
  }

  Future<void> _refreshRoutes() async {
    List<RouteGetData> latestEvents =
        await BaseClient().getRoutes("/route", _token.tokenID, _token.username);
    setState(() {
      _routes = latestEvents;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _loadRoutes();
    }
  }
}

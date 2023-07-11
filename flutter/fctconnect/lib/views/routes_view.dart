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
import '../models/route_post_data.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

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

  List<String> routesToDelete = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void addToSelectedRoutes(String creator, String routeName) {
    setState(() {
      routesToDelete.add("$creator-$routeName");
    });
  }

  void removeFromSelectedRoutes(String creator, String routeName) {
    setState(() {
      routesToDelete.remove("$creator-$routeName");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
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
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await BaseClient().deleteRoutes(
                  "/route", _token.username, _token.tokenID, routesToDelete);
              setState(() {
                routesToDelete.clear();
              });
              _loadRoutes();
            },
            child: Icon(
              Icons.delete,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshRoutes,
                  child: ListView.builder(
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      RouteGetData route = _routes[index];
                      bool isSelected = routesToDelete
                          .contains("${route.creator}-${route.name}");
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Style.kAccentColor2.withOpacity(
                                  0.3), // Glass effect by using opacity
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Container(
                              child: Card(
                                color: Colors
                                    .transparent, // To make sure Card takes the glass effect
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: SingleChildScrollView(
                                  child: GestureDetector(
                                    onTap: () {
                                      context.go(Paths.routes +
                                          '/${route.creator}/${route.name}');
                                    },
                                    child: ListTile(
                                      title: Text(route.creator),
                                      subtitle: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Nome do Percurso: ",
                                              ),
                                              Text(
                                                route.name,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          Row(
                                            children: [
                                              Text(
                                                "Criador: ",
                                              ),
                                              Text(
                                                route.creator,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          Row(
                                            children: [
                                              Text(
                                                "Duração Aproximada: ",
                                              ),
                                              Text(
                                                locationsDuration(
                                                            route.durations)
                                                        .toString() +
                                                    " minutos",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Flexible(
                                        child: Column(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isSelected
                                                    ? Icons.check_box
                                                    : Icons
                                                        .check_box_outline_blank,
                                              ),
                                              onPressed: () {
                                                if (isSelected) {
                                                  removeFromSelectedRoutes(
                                                      route.creator,
                                                      route.name);
                                                } else {
                                                  addToSelectedRoutes(
                                                      route.creator,
                                                      route.name);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
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

  int locationsDuration(List<int> durations) {
    int total = 0;
    for (int i in durations) {
      total += i;
    }
    return total;
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

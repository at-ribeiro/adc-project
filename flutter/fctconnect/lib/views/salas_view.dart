import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/salas_list_data.dart';
import 'package:responsive_login_ui/models/paths.dart';
import 'package:responsive_login_ui/views/sala_creator.dart';
import 'package:responsive_login_ui/views/search_salas_view.dart';

import '../constants.dart';
import '../models/Token.dart';
import '../models/sala_get_data.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import 'sala_page.dart';

class SalaView extends StatefulWidget {
  //const SalaView({Key? key}) : super(key: key);
  final String building;

  const SalaView({required this.building});

  @override
  State<SalaView> createState() => _SalaViewState();
}

class _SalaViewState extends State<SalaView> {
  List<SalaGetData> _salas = [];
  late Token _token;
  late String _building;
  bool _isLoadingToken = true;
  bool _loadingMore = false;
  int _lastDisplayedSalaTimestamp = DateTime.now().millisecondsSinceEpoch;

  late ScrollController _scrollController;

  TextEditingController salaController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    _building = widget.building;
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
            _loadSalas();
          });
        });
      });
    } else {
      return Container(
        decoration: kGradientDecorationUp,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshSalas,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _salas.length + (_loadingMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= _salas.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        SalaGetData sala = _salas[index];
                        return GestureDetector(
                          onTap: () {
                            context.go(Paths.buildings + '/${_building}' + '/${sala.id}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: kBorderRadius,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 50.0, sigmaY: 50.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kAccentColor2.withOpacity(0.1),
                                    borderRadius: kBorderRadius,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 7.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sala.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kAccentColor0,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                "capacity: " + sala.capacity.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kAccentColor0,
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

  void _loadSalas() async {
    List<SalaGetData> salas = await BaseClient().getSalas(
      "/rooms",
      _token.tokenID,
      _token.username,
      _building,
     // _lastDisplayedSalaTimestamp.toString(),
    );
    if (mounted) {
      setState(() {
        _salas = salas;
        if (salas.isNotEmpty) {
         // _lastDisplayedSalaTimestamp = salas.last.start;
        }
      });
    }
  }

  Future<void> _refreshSalas() async {
    _lastDisplayedSalaTimestamp = DateTime.now().millisecondsSinceEpoch;
    List<SalaGetData> latestSalas = await BaseClient().getSalas(
      "/rooms",
      _token.tokenID,
      _token.username,
      _building,
     // _lastDisplayedSalaTimestamp.toString(),
    );
    setState(() {
      _salas = latestSalas;
      if (latestSalas.isNotEmpty) {
     //   _lastDisplayedSalaTimestamp = latestSalas.last.start;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _loadSalas();
    }
  }
}

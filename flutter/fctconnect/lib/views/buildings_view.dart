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

class BuildingView extends StatefulWidget {
  const BuildingView({Key? key}) : super(key: key);

  @override
  State<BuildingView> createState() => _BuildingViewState();
}

class _BuildingViewState extends State<BuildingView> {
  List<String> _buildings = ["Edificio I", "test"];
  late Token _token;
  bool _isLoadingToken = true;
  bool _loadingMore = false;
  int _lastDisplayedSalaTimestamp = DateTime.now().millisecondsSinceEpoch;

  late ScrollController _scrollController;

  TextEditingController salaController = TextEditingController();
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
            //_loadSalas();
          });
        });
      });
    } else {
      return Container(
        child: Scaffold(
          floatingActionButton:
              _token.role == "SA" || _token.role == "SECRETARIA"
                  ? FloatingActionButton(
                      backgroundColor: Theme.of(context)
                          .floatingActionButtonTheme
                          .backgroundColor,
                      foregroundColor: Theme.of(context)
                          .floatingActionButtonTheme
                          .foregroundColor,
                      onPressed: () {
                        context.go(Paths.createSala);
                      },
                      child: Icon(Icons.add),
                    )
                  : null,
          body: Column(
            children: [
              Expanded(
                //child: RefreshIndicator(
                //onRefresh: _refreshSalas,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _buildings.length + (_loadingMore ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= _buildings.length) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      String building = _buildings[index];
                      return GestureDetector(
                        onTap: () {
                          context.go(Paths.buildings + '/${building}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
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
                                      const SizedBox(width: 7.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              building,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            // capacity here ?
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
//                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      //_loadSalas();
    }
  }
}

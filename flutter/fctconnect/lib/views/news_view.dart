import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';

import '../models/NewsData.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../widgets/circular_indicator.dart';
import 'news_page.dart';

class NewsView extends StatefulWidget {
  const NewsView({Key? key}) : super(key: key);

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {

  
  late Token _token;
  bool _isLoadingToken = true;
  bool _isLoadingNews = true;
  List<NewsData> _news = [];
  late ScrollController _scrollController;
  int counter = 0;
  static const int LAST = 19;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  Future<List<NewsData>> _loadNews() async {
    setState(() {
      _news = [];
    });
    List<NewsData> news = await BaseClient().fetchNewsFCT(counter);

    return news;
  }

  Widget build(BuildContext context) {

    TextTheme textTheme = Theme.of(context).textTheme;

    if (_isLoadingToken) {
      return TokenGetterWidget(
        onTokenLoaded: (Token token) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
          });
        },
      );
    } else if (_isLoadingNews) {
      return FutureBuilder(
          future: _loadNews(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return ErrorDialog('Algo não correu bem!', 'Voltar', context);
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  setState(() {
                    _news = snapshot.data;
                    _isLoadingNews = false;
                    counter++;
                  });
                });
                return Container(
                  color: Colors.transparent,
                );
              }
            } else {
              return Container(
                  color: Colors.transparent,
                  child:
                      const Center(child: CircularProgressIndicatorCustom()));
            }
          });
    } else {
      return Container(
     
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () {
              setState(() {
                counter = 0;
                _isLoadingNews = true;
              });
              return _loadNews();
            },
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 768),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _news.length,
                  itemBuilder: (BuildContext context, int index) {
                    NewsData news = _news[index];
                    return GestureDetector(
                      onTap: () {
                        context.go(news.newsUrl);
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: Style.kBorderRadius,
                          border: Border.all(
                            width: 1.5,
                            color: Style.kAccentColor0.withOpacity(0.0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Style.kAccentColor2.withOpacity(0.1),
                                borderRadius: Style.kBorderRadius,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: Image.network(
                                              news.imageUrl,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        news.title,
                                        style: textTheme.headline6!.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                    ],
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
          ),
        ),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _loadMoreNews();
    }
  }

  Future<void> _loadMoreNews() async {
    if (counter == LAST) {
      return;
    }
    List<NewsData> news = await BaseClient().fetchNewsFCT(counter);
    setState(() {
      _news.addAll(news);
      counter++;
    });
  }
}

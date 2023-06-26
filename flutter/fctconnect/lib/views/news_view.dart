import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';

import '../models/NewsData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import 'news_page.dart';

class NewsView extends StatefulWidget {
  const NewsView({Key? key}) : super(key: key);

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  late Token _token;
  bool _isLoadingToken = true;
  List<NewsData> _news = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadNews() async {
    List<NewsData> news =
        await BaseClient().fetchNews("/news", _token.tokenID, _token.username);
    if (mounted) {
      setState(() {
        _news = news;
      });
    }
  }

  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(
        onTokenLoaded: (Token token) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _token = token;
              _isLoadingToken = false;
              _loadNews();
            });
          });
        },
      );
    } else {
      return Scaffold(
        body: Container(
          decoration: kGradientDecoration,
          child: _news.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _news.length,
                  itemBuilder: (BuildContext context, int index) {
                    NewsData news = _news[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (ctx) => NewsDetailPage(news: news),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: kBorderRadius,
                          border: Border.all(
                            width: 1.5,
                            color: kAccentColor0.withOpacity(0.0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: kAccentColor2.withOpacity(0.1),
                                borderRadius: kBorderRadius,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Image.network(
                                          news.url,
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: Text(
                                            news.title,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ),
                                      ),
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
      );
    }
  }
}

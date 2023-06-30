import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';

import '../models/NewsData.dart';

class NewsDetailPage extends StatefulWidget {
  final String newsUrl;

  const NewsDetailPage({Key? key, required this.newsUrl}) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late String newsUrl;
  late NewsData news;
  bool _isNewsLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    newsUrl = widget.newsUrl;
    _loadNews();
  }

  Future<NewsData> _loadNews() async {
    NewsData newsData = await BaseClient().fetchSingularNewsFCT(newsUrl);
    return newsData;
  }

  @override
  Widget build(BuildContext context) {
    if (_isNewsLoading) {
      return FutureBuilder(
          future: _loadNews(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return ErrorDialog('Algo correu mal', 'Ok', context);
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  setState(() {
                    news = snapshot.data;
                    _isNewsLoading = false;
                  });
                });
              }
              return Container(
                  color: Colors.transparent,
                  child: const Center(child: CircularProgressIndicator()));
            } else {
              return Container(
                  color: Colors.transparent,
                  child: const Center(child: CircularProgressIndicator()));
            }
          });
    } else {
      return Container(
        decoration: kGradientDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 768), // set max-width here
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kAccentColor0,
                          fontSize: 24.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          news.timestamp,
                          style: const TextStyle(
                            color: kAccentColor2,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      SizedBox(
                        // You can adjust this height
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AspectRatio(
                            aspectRatio: 16 /
                                9, // Replace with the actual aspect ratio of the image
                            child: FittedBox(
                              fit: BoxFit
                                  .cover, // Adjust the fit property as needed
                              child: Image.network(
                                news.imageUrl,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        news.text,
                      
                        style: const TextStyle(
                          color: kAccentColor0,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 95.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

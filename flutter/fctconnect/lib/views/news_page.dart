import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _launchInstagramURL(String url) async {
    Uri instagramURL = Uri.parse(url);
    if (await canLaunchUrl(instagramURL)) {
      await launchUrl(instagramURL);
    } else {
      throw 'Could not launch $instagramURL';
    }
  }

  Future<NewsData> _loadNews() async {
    NewsData newsData = await BaseClient().fetchSingularNewsFCT(newsUrl);
    return newsData;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

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
        child: Scaffold(
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
                        style: textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                            Text(news.timestamp, style: textTheme.bodyText2!),
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
                      for (var paragraph in news.paragraphs!)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: textTheme.bodyText1!.copyWith(
                                fontSize: 16.0,
                              ),
                              children: [
                                TextSpan(
                                    text: '    '), // 4 spaces for indentation
                                TextSpan(text: paragraph),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                                onPressed: () {
                                  _launchInstagramURL(
                                      'https://www.fct.unl.pt$newsUrl');
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.web, size: 50.0),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Ver no site',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/views/event_creator.dart';
import 'package:responsive_login_ui/views/search_event_view.dart';

import '../models/NewsData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';

class NewsView extends StatefulWidget {
  final Token token;

  const NewsView({Key? key, required this.token}) : super(key: key);

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  late Token _token;
  List<NewsData> _news = [];

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _loadNews();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
      ),
      body: _news.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _news.length,
              itemBuilder: (BuildContext context, int index) {
                final news = _news[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (ctx) => NewsDetailPage(news: news)));
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            child: Text(
                              news.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final NewsData news;

  const NewsDetailPage({Key? key, required this.news}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                news.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                DateFormat('dd-MM-yyyy')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(news.timestamp)))
                    .toString(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 400.0, // Replace with your desired height
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Replace with the actual aspect ratio of the image
                  child: FittedBox(
                    fit: BoxFit.contain, // Adjust the fit property as needed
                    child: Image.network(
                      news.url,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                news.text,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

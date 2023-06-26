import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';

import '../models/NewsData.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsData news;

  const NewsDetailPage({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kGradientDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                      color: kAccentColor0,
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
                      color: kAccentColor2,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 400.0, // Replace with your desired height
                    child: AspectRatio(
                      aspectRatio: 16 /
                          9, // Replace with the actual aspect ratio of the image
                      child: FittedBox(
                        fit:
                            BoxFit.contain, // Adjust the fit property as needed
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
                      color: kAccentColor0,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

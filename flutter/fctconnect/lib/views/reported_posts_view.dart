import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/PostReport.dart';

import '../models/AlertPostData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class ReportedPostsPage extends StatefulWidget {
  const ReportedPostsPage({Key? key}) : super(key: key);

  @override
  State<ReportedPostsPage> createState() => _ReportedPostsPageState();
}

class _ReportedPostsPageState extends State<ReportedPostsPage> {
  late Token _token;
  bool _isLoadingToken = true;
  List<PostReport> postReportsList = [];
  List<String> reportsToDelete = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadReports() async {
    List<PostReport> posts = await BaseClient().getPostsReports(
      "/report",
      _token.username,
      _token.tokenID,
    );

    if (posts.isNotEmpty) {
      setState(() {
        postReportsList.addAll(posts);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void addToSelectedReports(String postID) {
    setState(() {
      reportsToDelete.add(postID);
    });
  }

  void removeFromSelectedReports(String postID) {
    setState(() {
      reportsToDelete.remove(postID);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
            _loadReports();
          });
        });
      });
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Posts Reportados'),
          actions: [
            IconButton(
              onPressed: () async {
                await BaseClient().deletePostsReport(
                  "/report",
                  _token.username,
                  _token.tokenID,
                  reportsToDelete,
                );
                setState(() {
                  postReportsList.clear();
                  reportsToDelete.clear();
                });
                _loadReports();
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: postReportsList.length,
          itemBuilder: (context, index) {
            PostReport postsReport = postReportsList[index];
            bool isSelected = reportsToDelete.contains(postsReport.postId);
            return Card(
              child: ListTile(
                title: Text(postsReport.postCreator),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Post ID: ${postsReport.postId}'),
                    Text('Número de reports: ${postsReport.count}'),
                    Text('Reportado por: ${postsReport.reporters}'),
                    Text('Razões: ${postsReport.reportReason}'),
                    Text('Comentários: ${postsReport.reportComment}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onPressed: () {
                    if (isSelected) {
                      removeFromSelectedReports(postsReport.postId);
                    } else {
                      addToSelectedReports(postsReport.postId);
                    }
                  },
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
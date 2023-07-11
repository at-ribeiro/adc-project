import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/models/PostReport.dart';

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
      return Container(

        child: Scaffold(

          floatingActionButton: FloatingActionButton(
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
            child: Icon(Icons.delete, color: Style.kAccentColor0),
          ),
          body: ListView.builder(
            itemCount: postReportsList.length,
            itemBuilder: (context, index) {
              PostReport postsReport = postReportsList[index];
              bool isSelected = reportsToDelete.contains(postsReport.postId);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius:
                      Style.kBorderRadius, // Setting the border radius
                  child: Container(
                    decoration: BoxDecoration(
                      color: Style.kAccentColor0
                          .withOpacity(0.3), // Glass effect by using opacity
                      borderRadius: Style.kBorderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors
                          .transparent, // To make sure Card takes the glass effect
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: Style.kBorderRadius,
                      ),
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

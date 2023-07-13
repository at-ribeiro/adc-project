import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/CommentData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class PostPage extends StatefulWidget {
  final String postUser;
  final String postID;
  const PostPage({required this.postID, required this.postUser});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _areCommentsLoading = true;
  late Token _token;
  bool _isLoadingToken = true;
  String? _loadingError;
  late String _postUser;
  late String _postID;
  List<CommentData> _comments = []; 
  int _lastDisplayedCommentTimestamp = DateTime.now().millisecondsSinceEpoch;
    late ScrollController _scrollController;


  @override
  void initState() {
    super.initState();
    _postUser = widget.postUser;
    _postID = widget.postID;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      getComments();
    }
  }

  Future<void> getComments() async {
    List<CommentData> comments = await BaseClient().getComments(
        '/comment', _token.username, _token.tokenID, _postID, _postUser, _lastDisplayedCommentTimestamp);

    setState(() {
      _comments = comments;
    });

    if (mounted) {
      setState(() {
      _comments = comments;
        if (_comments.isNotEmpty) {
          _lastDisplayedCommentTimestamp = comments.last.timestamp;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        setState(() {
          _token = token;
          _isLoadingToken = false;
          getComments();
        });
      });
    } else if (_loadingError != null) {
      return Center(
        child: Text("Error loading token: $_loadingError"),
      );
    } else {
      return Container(
        child: Scaffold(
          body: contentBody(),
        ),
      );
    }
  }

  Widget _loadProfilePic(String profilePic) {
    if (profilePic.isEmpty) {
      return const CircleAvatar(
        backgroundImage: NetworkImage(
          'https://storage.googleapis.com/fct-connect-estudasses.appspot.com/default_profile.jpg',
        ),
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(
          profilePic,
        ),
      );
    }
  }

  Future<void> _refreshComments() async {
    _lastDisplayedCommentTimestamp = DateTime.now().millisecondsSinceEpoch;
    List<CommentData> latestComments = await BaseClient().getComments(
        '/comment', _token.username, _token.tokenID, _postID, _postUser, _lastDisplayedCommentTimestamp);
    setState(() {
      _comments = latestComments;
      if (latestComments.isNotEmpty) {
        _lastDisplayedCommentTimestamp = latestComments.last.timestamp;
      }
    });
  }

  Widget contentBody() {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
                  onRefresh: _refreshComments,
          child: ListView.builder(
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              CommentData comment = _comments[index];
              return Card(
                margin: EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    width: 1.5,
                    color: Style.kAccentColor2.withOpacity(0.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                    child: Container(
                      color: Style.kAccentColor2.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Row(
                            children: [
                              _loadProfilePic(comment.profilePic ?? ''),
                              SizedBox(width: 8.0),
                              Text(comment.user),
                            ],
                          ),
                          subtitle: Text(comment.text, style: textTheme.headline6),
                          trailing: Text(
                            DateFormat('HH:mm - dd-MM-yyyy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  comment.timestamp),
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
        Container(
          color: Theme.of(context).navigationBarTheme.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: Style.kBorderRadius,
                    color: Style.kAccentColor2.withOpacity(0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: Style.kBorderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.comment,
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
                          ),
                          hintText: 'Comente algo...',
                          border: InputBorder.none,
                        ),
                        controller: _commentController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Escreva algo';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: () {
                  String c = _commentController.text;
                  CommentData comment = CommentData(
                    user: _token.username,
                    text: c,
                    timestamp: DateTime.now().millisecondsSinceEpoch,
                  );
                  if (c != '') {
                    BaseClient()
                        .addComment(
                      '/comment',
                      _token.username,
                      _token.tokenID,
                      _postID,
                      _postUser,
                      comment,
                    );                      
                    _commentController.clear();
                    _refreshComments();
                   
                  }
                },
                icon: Icon(Icons.send,
                    color: Theme.of(context).appBarTheme.foregroundColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

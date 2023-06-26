import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';

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
  List<CommentData> _comments = []; // List to store comments

  @override
  void initState() {
    super.initState();
    _postUser = widget.postUser;
    _postID = widget.postID;
    getComments(); // Load token on initialization
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Method to fetch comments (replace with your implementation)
  Future<void> getComments() async {
    // Call the BaseClient method to fetch comments
    List<CommentData> comments = await BaseClient().getComments(
        '/comment', _token.username, _token.tokenID, _postID, _postUser);

    setState(() {
      _comments = comments;
    });
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
        decoration: kGradientDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ContentBody(),
        ),
      );
    }
  }

  Widget ContentBody() {
    return Column(
      children: [
        Expanded(
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
                    color: kAccentColor0.withOpacity(0.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                    child: Container(
                      color: kAccentColor0.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/default_profile.jpg',
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(comment.user),
                            ],
                          ),
                          subtitle: Text(comment.text),
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
        Container(
          color: kPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: kBorderRadius,
                    color: kAccentColor0.withOpacity(0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: kBorderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextFormField(
                        style: const TextStyle(
                          color: kAccentColor0,
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.comment,
                            color: kAccentColor1,
                          ),
                          hintText: 'Comente algo...',
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: kBorderRadius,
                            borderSide: BorderSide(
                              color:
                                  kAccentColor1, // Set your desired focused color here
                            ),
                          ),
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
                    )
                        .then((_) {
                      _commentController.clear();
                      getComments(); // Fetch the updated comments
                    });
                  }
                },
                icon: Icon(Icons.send, color: kAccentColor0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

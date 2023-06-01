import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/FeedData.dart';

import '../models/CommentData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';

class PostPage extends StatefulWidget {
  final Token token;
  final String postUser;
  final String postID;
  const PostPage(
      {required this.token, required this.postID, required this.postUser});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _commentController = TextEditingController();
  late Token _token;
  late String _postUser;
  late String _postID;
  List<CommentData> _comments = []; // List to store comments

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _postUser = widget.postUser;
    _postID = widget.postID;

    getComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Method to fetch comments (replace with your implementation)
  void getComments() async {
    // Call the BaseClient method to fetch comments
    List<CommentData> comments = await BaseClient().getComments(
        '/comment', _token.username, _token.tokenID, _postID, _postUser);

    setState(() {
      _comments = comments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentários'),
      ),
      body: ContentBody(),
    );
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
                child: ListTile(
                  title: Text(comment.user),
                  subtitle: Text(comment.text),
                  trailing: Text(DateFormat('HH:mm - dd-MM-yyyy').format(
                    DateTime.fromMillisecondsSinceEpoch(comment.timestamp),
                  )),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Comente algo...',
                    border: OutlineInputBorder(),
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
                icon: Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

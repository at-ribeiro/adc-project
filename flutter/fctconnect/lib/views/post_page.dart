import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/CommentData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class PostPage extends StatefulWidget {
  final String postUser;
  final String postID;
  const PostPage(
      {required this.postID, required this.postUser});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _commentController = TextEditingController();
  late Token _token;
  bool _isLoadingToken = true;
  late String _postUser;
  late String _postID;
  List<CommentData> _comments = []; // List to store comments

  @override
  void initState() {
    super.initState();
    _postUser = widget.postUser;
    _postID = widget.postID;

    
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
   if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
            getComments();
          });
        });
      });
    }else
    {return Scaffold(
      appBar: AppBar(
        title: Text('Comentários'),
      ),
      body: ContentBody(),
    );}
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

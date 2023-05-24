import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/FeedData.dart';

import '../models/Token.dart';

class PostPage extends StatefulWidget {
  final Token token;
  const PostPage({required this.token});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _commentController = TextEditingController();
  late Token _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
          child: SizedBox(), // or use Expanded(child: SizedBox())
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
                  String comment = _commentController.text;
                  // TODO adicionar comentario
                  _commentController.clear();
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

import 'dart:typed_data';

import 'package:responsive_login_ui/models/FeedData.dart';

import '../models/Post.dart';
import 'base_client.dart';

class PostActions {
  static Future<int> doPost(String postContent, Uint8List? imageData,
      String? fileName, String username, String tokenId) async {
    Post post = Post(
        post: postContent,
        imageData: imageData,
        username: username,
        fileName: fileName);
    int response = await BaseClient().createPost("/post", tokenId, post);

    return response;
  }

  static Future<void> deletePost(String  postID, user, tokenId) async {
    await BaseClient().deletePost("/post", postID, user, tokenId);


  }
  }

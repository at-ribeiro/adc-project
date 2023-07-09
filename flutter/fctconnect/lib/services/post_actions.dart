import 'dart:typed_data';
import '../models/Post.dart';
import 'base_client.dart';

class PostActions {
  static Future<int> doPost(
      String postContent,
      Uint8List? fileData,
      String? fileName,
      String? mediaType,
      String? type,
      String username,
      String tokenId) async {

    Post post = Post(
        post: postContent,
        fileData: fileData,
        fileName: fileName,
        type: type,
        username: username,
        mediaType: mediaType);
        
    int response = await BaseClient().createPost("/post", tokenId, post);

    return response;
  }

  static Future<void> deletePost(String postID, user, tokenId) async {
    await BaseClient().deletePost("/post", postID, user, tokenId);
  }
}

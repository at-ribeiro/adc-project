import 'dart:convert';
import 'dart:typed_data';

class Post {
  String post;
  Uint8List? imageData;
  String? fileName;
  String username;

  Post({required this.post, this.imageData, required this.username, this.fileName});

  Map<String, dynamic> toMap() {
    return {
      'post': post,
      'username': username,
    };
  }

  String toJson() => json.encode(toMap());
}

import 'dart:convert';
import 'dart:io';

class Post {
  String post;
  File? image;
  String username;

  Post({required this.post, required this.image, required this.username});

  Map<String, dynamic> toMap() {
    return {
      'post': post,
      'username': username,
    };
  }

  String toJson() => json.encode(toMap());
}
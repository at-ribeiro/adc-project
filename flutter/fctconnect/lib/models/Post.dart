import 'dart:convert';
import 'dart:typed_data';

class Post {
  String post;
  String username;
  Uint8List? fileData;
  String? fileName;
  String? mediaType;
  String? type;

  Post(
      {required this.post,
      required this.username,
      this.fileData,
      this.fileName,
      this.mediaType,
      this.type});

  Map<String, dynamic> toMap() {
    return {
      'post': post,
      'username': username,
    };
  }

  String toJson() => json.encode(toMap());
}

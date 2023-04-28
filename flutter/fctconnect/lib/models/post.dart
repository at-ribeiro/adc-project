// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson());

class Post {
    String username;
    String email;
    String userFullname;
    String password;
    String passwordV;

    Post({
        required this.username,
        required this.email,
        required this.userFullname,
        required this.password,
        required this.passwordV,
    });

    factory Post.fromJson(Map<String, dynamic> json) => Post(
        username: json["username"],
        email: json["email"],
        userFullname: json["user_fullname"],
        password: json["password"],
        passwordV: json["passwordV"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "user_fullname": userFullname,
        "password": password,
        "passwordV": passwordV,
    };
} 
// To parse this JSON data, do
//
//     final registerUser = registerUserFromJson(jsonString);

import 'dart:convert';

RegisterUser registerUserFromJson(String str) => RegisterUser.fromJson(json.decode(str));

String registerUserToJson(RegisterUser data) => json.encode(data.toJson());

class RegisterUser {
    String username;
    String fullname;
    String password;
    String passwordV;
    String email;

    RegisterUser({
        required this.username,
        required this.fullname,
        required this.password,
        required this.passwordV,
        required this.email,
    });

    factory RegisterUser.fromJson(Map<String, dynamic> json) => RegisterUser(
        username: json["username"],
        fullname: json["fullname"],
        password: json["password"],
        passwordV: json["passwordV"],
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "fullname": fullname,
        "password": password,
        "passwordV": passwordV,
        "email": email,
    };
}

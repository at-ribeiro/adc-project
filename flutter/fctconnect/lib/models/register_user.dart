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
    String role;
    String state;
    String privacy;

    RegisterUser({
        required this.username,
        required this.fullname,
        required this.password,
        required this.passwordV,
        required this.email,
        required this.role,
        required this.state,
        required this.privacy,
    });

    factory RegisterUser.fromJson(Map<String, dynamic> json) => RegisterUser(
        username: json["username"],
        fullname: json["fullname"],
        password: json["password"],
        passwordV: json["passwordV"],
        email: json["email"],
        role: json["role"],
        state: json["state"],
        privacy: json["privacy"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "fullname": fullname,
        "password": password,
        "passwordV": passwordV,
        "email": email,
        "role": role,
        "state": state,
        "privacy": privacy,
    };
}
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/Post.dart';
import '../models/Token.dart';

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';


const String baseUrl = 'https://fct-connect-2023.oa.r.appspot.com/rest';


class BaseClient{
var client = http.Client();


  Future<dynamic> get(String api, String token) async{

    var url = Uri.parse(baseUrl + api);

    var _headers = {
      'Authorization': token
    };
    var response = await client.get(url, headers: _headers);
    if (response.statusCode == 200){
      return response.body;
    }else{
      //throw exception
    }
  }

  Future<dynamic> post(String api, dynamic object) async{
    var _body = object;

    var _headers ={
      "Content-Type": "application/json; charset=UTF-8"
        };
    var url = Uri.parse(baseUrl + api);

    var response = await http.post(url, headers: _headers, body: jsonEncode(_body));
    if (response.statusCode == 200){
      return response.body;
    }else{
      //throw exception
      return null;
    }
  }

  Future<dynamic> doLogout(String api, String username, String tokenID) async{
    var _headers ={
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      };
    var url = Uri.parse(baseUrl + api + '/' + username);

    var response = await http.delete(url, headers: _headers, );

    if (response.statusCode == 200){
      return response.body;
    }else{
      //throw exception
      return null;
    }
  }

Future<Token> postLogin(String api, dynamic object) async {
  var _body = object;

  var _headers ={
    "Content-Type": "application/json; charset=UTF-8"
  };
  var url = Uri.parse(baseUrl + api);

  var response = await http.post(url, headers: _headers, body: jsonEncode(_body));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    Token token = Token(
      username: jsonResponse['username'],
      role: jsonResponse['role'],
      tokenID: jsonResponse['tokenID'],
      creationDate: jsonResponse['creationDate'],
      expirationDate: jsonResponse['expirationDate'],
    );
    return token;
  } else{
    // throw exception
   throw Exception("Error: ${response.statusCode} - ${response.reasonPhrase}");
  }
}




Future<int> createPost(String api, String tokenID, Post post) async {
  var _headers = {
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": tokenID,
  };

  var jsonBody = {
    "post": post.post,
    "username": post.username,
  };

  if (post.image != null) {
    List<int> imageBytes = await post.image!.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    jsonBody["image"] = base64Image;
  }

  var response = await http.post(
    Uri.parse(baseUrl + api),
    headers: _headers,
    body: json.encode(jsonBody),
  );

  return response.statusCode;
}




  Future<dynamic> put(String api) async{}

  Future<dynamic> delete(String api) async{}

}
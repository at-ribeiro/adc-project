import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/Token.dart';


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
    var url = Uri.parse(baseUrl + api + '?username=' + username);

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
    print (response.statusCode);
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


Future<dynamic> createPost(String api, String username, String tokenID) async{
    var _headers ={
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      };
    var url = Uri.parse(baseUrl + api + '?username=' + username);

    var response = await http.delete(url, headers: _headers, );

    if (response.statusCode == 200){
      return response.body;
    }else{
      //throw exception
      return null;
    }
  }

  Future<dynamic> put(String api) async{}

  Future<dynamic> delete(String api) async{}

}
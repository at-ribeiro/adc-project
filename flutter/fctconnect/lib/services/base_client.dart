import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/Token.dart';


const String baseUrl = 'http://fct-connect-2023.oa.r.appspot.com/rest';


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
  } else {
    // throw exception
    throw Exception('Failed to login');
  }
}

  Future<dynamic> put(String api) async{}

  Future<dynamic> delete(String api) async{}

}
import 'dart:convert';

import 'package:http/http.dart' as http; 


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
            "Content-Type": "application/json"
        };
    var url = Uri.parse(baseUrl + api);

    var response = await http.post(url,headers: _headers, body: _body);
    if (response.statusCode == 201 || response.statusCode == 200){
      return response.body;
    }else{
      //throw exception
      return response.body;
    }
  }

  Future<dynamic> put(String api) async{}

  Future<dynamic> delete(String api) async{}

}
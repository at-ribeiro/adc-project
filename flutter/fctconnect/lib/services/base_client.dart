import 'dart:convert';

import 'package:http/http.dart' as http; 


const String baseUrl = 'fct-connect-2023.oa.r.appspot.com/rest';


class BaseClient{
var client = http.Client();


  Future<dynamic> get(String api, String token) async{

    var uri = Uri.parse(baseUrl + api);

    var _headers = {
      'Authorization': token
    };
    var response = await client.get(uri, headers: _headers);
    if (response.statusCode == 200){
      return response.body;
    }else{
      //throw exception
    }
  }

  Future<dynamic> post(String api, dynamic object) async{
    var _body = json.encode(object);
    
    var uri = Uri.parse(baseUrl + api);

    var response = await client.post(uri, body: _body);
    if (response.statusCode == 201 || response.statusCode == 200){
      return response.body;
    }else{
      //throw exception
    }
  }

  Future<dynamic> put(String api) async{}

  Future<dynamic> delete(String api) async{}

}
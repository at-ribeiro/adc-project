import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:responsive_login_ui/models/events_list_data.dart';


import '../models/FeedData.dart';
import '../models/NewsData.dart';
import '../models/Post.dart';
import '../models/Token.dart';

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import '../models/event_data.dart';
import '../models/profile_info.dart';


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
      throw extension("Something went wrong");
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
    }else if (response.statusCode == 409) {
      //throw exception
     throw '409';
    }
  }

  Future<dynamic> doLogout(String api, String username, String tokenID) async{
    var _headers ={
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      };
    var url = Uri.parse('$baseUrl$api/$username');

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
    "Content-Type": "multipart/form-data",
    "Authorization": tokenID,
  };

  var request = http.MultipartRequest('POST', Uri.parse(baseUrl + api));
  request.headers.addAll(_headers);

  request.fields['post'] = json.encode(post.toJson());
  request.fields['username'] = post.username;

  if (post.imageData != null) {
    var multipartFile = http.MultipartFile.fromBytes(
      'image',
      post.imageData!,
      filename: "${post.fileName}.jpg",
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);
  }

  var response = await request.send();

  return response.statusCode;
}

Future<List<FeedData>> getFeed(String api, String tokenID, String username, String time) async {
  var _headers ={
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": tokenID,
  };
  var url = Uri.parse('$baseUrl$api/$username?timestamp=$time');

  var response = await http.get(url, headers: _headers);
  if (response.statusCode == 200) {
    
    final jsonList = json.decode(response.body) as List<dynamic>;
    final postList = jsonList.map((json) => FeedData.fromJson(json)).toList();

    return postList;

  } else{
    // throw exception
    throw Exception("Error: ${response.statusCode} - ${response.reasonPhrase}");
  }
}

  Future<dynamic> put(String api) async{}

  Future<dynamic> delete(String api) async{}

Future<List<NewsData>> fetchNews(String api, String tokenID, String username) async {
  var _headers ={
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": tokenID,
  };
  var url = Uri.parse("$baseUrl$api?username=$username");

  var response = await http.get(url, headers: _headers);
  if (response.statusCode == 200) {
    
    final jsonList = json.decode(response.body) as List<dynamic>;
    final newsList = jsonList.map((json) => NewsData.fromJson(json)).toList();

    return newsList;

  } else{
    // throw exception
    throw Exception("Error: ${response.statusCode} - ${response.reasonPhrase}");
  }
}

Future<int> createEvent(String api, String tokenID, EventData event) async {
  var _headers = {
    "Content-Type": "multipart/form-data",
    "Authorization": tokenID,
  };

  var request = http.MultipartRequest('POST', Uri.parse(baseUrl + api + '/' + event.creator));
  request.headers.addAll(_headers);

  request.fields['event'] = json.encode(event.toJson());

  if (event.imageData != null) {
    var multipartFile = http.MultipartFile.fromBytes(
      'image',
      event.imageData!,
      filename: "${event.fileName}.jpg",
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);
  }

  var response = await request.send();

  return response.statusCode;
}

  Future<List<EventsListData>> getEvents(String api, String tokenID, String username, String time) async {
   var _headers ={
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": tokenID,
  };
  var url = Uri.parse('$baseUrl$api/$username?timestamp=$time');

  var response = await http.get(url, headers: _headers);
  if (response.statusCode == 200) {
    
    final jsonList = json.decode(response.body) as List<dynamic>;
    final eventsList = jsonList.map((json) => EventsListData.fromJson(json)).toList();

    return eventsList;

  } else{
    // throw exception
    throw Exception("Error: ${response.statusCode} - ${response.reasonPhrase}");
  }

}
Future<ProfileInfo> fetchInfo(String api, String tokenID, String username) async {
  var _headers ={
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": tokenID,
  };
  var url = Uri.parse('$baseUrl$api/$username?searcher=$username');

  var response = await http.get(url, headers: _headers);
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final profileInfo = ProfileInfo.fromJson(jsonData);
    return profileInfo;
  } else {
    throw Exception("Error: ${response.statusCode} - ${response.reasonPhrase}");
  }
}}
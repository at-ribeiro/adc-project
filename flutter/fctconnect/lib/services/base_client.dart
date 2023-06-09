import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:responsive_login_ui/models/events_list_data.dart';

import 'package:responsive_login_ui/models/user_query_data.dart';

import '../models/AlertPostData.dart';
import '../models/CommentData.dart';
import '../models/FeedData.dart';
import '../models/NewsData.dart';
import '../models/Post.dart';
import '../models/Token.dart';

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import '../models/event_data.dart';
import '../models/profile_info.dart';

const String baseUrl = 'https://fct-connect-estudasses.oa.r.appspot.com/rest';

class BaseClient {
  var client = http.Client();

  Future<dynamic> get(String api, String token) async {
    var url = Uri.parse(baseUrl + api);

    var _headers = {'Authorization': token};
    var response = await client.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      //throw exception
      throw extension("Something went wrong");
    }
  }

  Future<dynamic> post(String api, dynamic object) async {
    var _body = object;

    var _headers = {"Content-Type": "application/json; charset=UTF-8"};
    var url = Uri.parse(baseUrl + api);

    var response =
        await http.post(url, headers: _headers, body: jsonEncode(_body));
    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 409) {
      //throw exception
      throw '409';
    }
  }

  Future<dynamic> doLogout(String api, String username, String tokenID) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username');

    var response = await http.delete(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      //throw exception
      return null;
    }
  }

  Future<Token> postLogin(String api, dynamic object) async {
    var _body = object;

    var _headers = {"Content-Type": "application/json; charset=UTF-8"};
    var url = Uri.parse(baseUrl + api);

    var response =
        await http.post(url, headers: _headers, body: jsonEncode(_body));
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
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
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

  Future<List<FeedData>> getFeedorPost(String api, String tokenID,
      String username, String time, String searching) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": searching,
    };
    var url = Uri.parse('$baseUrl$api/$username?timestamp=$time');

    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      final postList = jsonList.map((json) => FeedData.fromJson(json)).toList();

      return postList;
    } else {
      // throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<List<NewsData>> fetchNews(
      String api, String tokenID, String username) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse("$baseUrl$api?username=$username");

    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      final newsList = jsonList.map((json) => NewsData.fromJson(json)).toList();

      return newsList;
    } else {
      // throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<int> createEvent(String api, String tokenID, EventData event) async {
    var _headers = {
      "Content-Type": "multipart/form-data",
      "Authorization": tokenID,
    };

    var request = http.MultipartRequest(
        'POST', Uri.parse(baseUrl + api + '/' + event.creator));
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

  Future<List<EventData>> getEvents(
      String api, String tokenID, String username, String time) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username?timestamp=$time');

    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      final eventsList =
          jsonList.map((json) => EventData.fromJson(json)).toList();

      return eventsList;
    } else {
      // throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

   Future<EventData> getEvent(
      String api, String tokenID, String id) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$id');

    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final event = EventData.fromJson(jsonData);

      return event;
    } else {
      // throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  

  Future<ProfileInfo> fetchInfo(
      String api, String tokenID, String username, String searches) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username?searcher=$searches');

    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final profileInfo = ProfileInfo.fromJson(jsonData);
      return profileInfo;
    } else {
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<List<UserQueryData>> searchUser(String query, String api) async {
    var url = Uri.parse('$baseUrl$api/user?query=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      // Replace this with your actual data parsing
      final jsonList = json.decode(response.body) as List<dynamic>;
      final usersList =
          jsonList.map((json) => UserQueryData.fromJson(json)).toList();

      return usersList;
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> follow(
      String api, String username, String tokenID, String following) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username/$following');

    var response = await http.post(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      //throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<dynamic> unfollow(
      String api, String username, String tokenID, String following) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username/$following');

    var response = await http.delete(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      //throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<bool> doesUserFollow(
      String api, String username, String tokenID, String following) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username/$following');

    var response = await http.get(
      url,
      headers: _headers,
    );

    return response.statusCode == 200;
  }

  Future<bool> isInEvent(String api, String username, String tokenID) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username');

    var response = await http.get(
      url,
      headers: _headers,
    );

    return response.statusCode == 200;
  }

  Future<dynamic> joinEvent(
      String api, String username, String tokenID, EventData event) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username');

    var response = await http.post(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      //throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  leaveEvent(String s, String t, String u, EventData event) {}

  Future<dynamic> likePost(String api, String username, String tokenID,
      String postID, String postUser) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url =
        Uri.parse('$baseUrl$api/$username?post=$postID&creator=$postUser');

    var response = await http.put(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      //throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<List<CommentData>> getComments(
      String api, String username, String tokenID, String postID, String postUser) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$postUser/$postID?searcher=$username');

    var response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      final commentsList =
          jsonList.map((json) => CommentData.fromJson(json)).toList();
      return commentsList;
    } else {
      //throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }


Future<dynamic> addComment(
    String api, String username, String tokenID, String postID, String postUser, CommentData comment) async {
  var _headers = {
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": tokenID,
  };
  var url = Uri.parse('$baseUrl$api/$postUser/$postID');

  var commentJson = jsonEncode({
    'user': comment.user,
    'text': comment.text,
    'timestamp': comment.timestamp,
  });

  var response = await http.post(
    url,
    headers: _headers,
    body: commentJson,
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    // Throw exception
    throw Exception(
        "Error: ${response.statusCode} - ${response.reasonPhrase}");
  }
}

Future<dynamic> createReport(
    String api, String username, String tokenID, AlertPostData report) async {
  var _headers = {
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": tokenID,
  };

  var url = Uri.parse('$baseUrl$api/$username');

  var reportJson = jsonEncode({
    'creator': report.creator,
    'location': report.location,
    'description': report.description,
    'timestamp': report.timestamp,
  });

  var response = await http.post(
    url,
    headers: _headers,
    body: reportJson,
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    // Throw exception
    throw Exception(
        "Error: ${response.statusCode} - ${response.reasonPhrase}");
  }
}

Future<List<AlertPostData>> getReports(
      String api, String username, String tokenID) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api?searcher=$username');

    var response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      final reportsList =
          jsonList.map((json) => AlertPostData.fromJson(json)).toList();
      return reportsList;
    } else {
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }



Future<dynamic> deleteReports(
  String api, String username, String tokenID, List<int> ids) async {
  var _headers = {
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": tokenID,
  };

  var url = Uri.parse('$baseUrl$api');

  var response = await http.delete(
    url,
    headers: _headers,
    body: json.encode({"ids": ids}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    // Throw exception
    throw Exception(
        "Error: ${response.statusCode} - ${response.reasonPhrase}");
  }
}



}

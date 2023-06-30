import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:responsive_login_ui/models/ActivityData.dart';

import 'package:responsive_login_ui/models/location_get_data.dart';
import 'package:responsive_login_ui/models/route_get_data.dart';

import 'package:html/dom.dart' as dom;
import 'package:html/dom.dart' as html;


import 'package:responsive_login_ui/models/user_query_data.dart';

import '../models/AlertPostData.dart';
import '../models/CommentData.dart';
import '../models/FeedData.dart';
import '../models/NewsData.dart';
import '../models/Post.dart';
import '../models/PostReport.dart';
import '../models/Token.dart';

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import '../models/change_pwd_data.dart';
import '../models/event_get_data.dart';
import '../models/event_post_data.dart';
import '../models/profile_info.dart';
import '../models/update_data.dart';

const String baseUrl = 'https://fct-connect-estudasses.oa.r.appspot.com/rest';
const String fctUrl = 'https://www.fct.unl.pt';

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
        profilePic: '',
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
      "Authorization": tokenID,
    };

    var request = http.MultipartRequest('POST', Uri.parse(baseUrl + api));
    request.headers.addAll(_headers);

    request.fields['post'] = json.encode(post.toJson());
    request.fields['username'] = post.username;

    if (post.fileData != null) {
      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        post.fileData!,
        filename: "${post.fileName}",
        contentType: MediaType(post.type!, post.mediaType!),
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

  Future<int> createEvent(
      String api, String tokenID, EventPostData event) async {
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

  Future<List<EventGetData>> getEvents(
      String api, String tokenID, String username, String time) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api/$username?timestamp=$time');

    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final jsonString = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonString);
      final List<EventGetData> eventsList = List<EventGetData>.from(
          data.map((json) => EventGetData.fromJson(json)));
      return eventsList;
    } else {
      // throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<EventGetData> getEvent(String api, id, tokenID, user) async {
    Map<String, String>? _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": user,
    };
    var url = Uri.parse('$baseUrl$api/$id');

    var response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final jsonString = utf8.decode(response.bodyBytes);
      final jsonData = json.decode(jsonString);
      final event = EventGetData.fromJson(jsonData);
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
      final jsonData = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> parsedJson = json.decode(jsonData);
      final profileInfo = ProfileInfo.fromJson(parsedJson);
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
      final jsonString = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonString);
      final List<UserQueryData> usersList = List<UserQueryData>.from(
          data.map((json) => UserQueryData.fromJson(json)));
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
      String api, String username, String tokenID, EventPostData event) async {
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

  leaveEvent(String s, String t, String u, EventPostData event) {}

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

  Future<List<CommentData>> getComments(String api, String username,
      String tokenID, String postID, String postUser) async {
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
      final jsonString =
          utf8.decode(response.bodyBytes); // Specify the correct encoding
      final data = jsonDecode(jsonString);
      final List<CommentData> commentsList = List<CommentData>.from(
          data.map((json) => CommentData.fromJson(json)));
      return commentsList;
    } else {
      //throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<dynamic> addComment(String api, String username, String tokenID,
      String postID, String postUser, CommentData comment) async {
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
      "User": username,
    };
    var url = Uri.parse('$baseUrl$api');

    var response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonString =
          utf8.decode(response.bodyBytes); // Specify the correct encoding
      final data = jsonDecode(jsonString);
      final List<AlertPostData> reportsList = List<AlertPostData>.from(
          data.map((json) => AlertPostData.fromJson(json)));
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
      "User": username,
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

  Future<void> deletePost(String api, postID, username, tokenId) async {
    Map<String, String>? _headers = {
      "Content-Type": "charset=UTF-8",
      "Authorization": tokenId,
      "User": username,
    };

    var url = Uri.parse('$baseUrl$api/$username?id=$postID');

    var response = await http.delete(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      // Throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<dynamic> reportPost(
      String api, username, tokenID, id, postUser, reason, comment) async {
    Map<String, String>? _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };

    var url = Uri.parse('$baseUrl$api/$id');

    var reportJson = jsonEncode({
      'creator': username,
      'postId': id,
      'postCreator': postUser,
      'reason': reason,
      'comment': comment,
    });

    var response = await http.post(
      url,
      headers: _headers,
      body: reportJson,
    );

    if (response.statusCode != 200) {
      // Throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<dynamic> createActivity(String api, String username, String tokenID,
      ActivityData activity) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };

    var url = Uri.parse('$baseUrl$api');

    var activityJson = jsonEncode({
      'activityName': activity.activityName,
      'from': activity.from,
      'to': activity.to,
      'background': activity.background,
      'creationTime': activity.creationTime,
    });

    var response = await http.post(
      url,
      headers: _headers,
      body: activityJson,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      // Throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<dynamic> deleteActivity(
      String api, String username, String tokenId, String activityID) async {
    Map<String, String>? _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenId,
      "User": username,
    };

    var url = Uri.parse('$baseUrl$api/$activityID');

    var response = await http.delete(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      // Throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<dynamic> updateActivity(String api, String username, String tokenID,
      ActivityData activity) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };

    String activityID = activity.creationTime;
    var url = Uri.parse('$baseUrl$api/$activityID');

    var activityJson = jsonEncode({
      'activityName': activity.activityName,
      'from': activity.from,
      'to': activity.to,
      'background': activity.background,
      'creationTime': activity.creationTime,
    });

    var response = await http.put(
      url,
      headers: _headers,
      body: activityJson,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      // Throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<List<ActivityData>> getActivities(
      String api, String username, String tokenID) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };
    var url = Uri.parse('$baseUrl$api');

    var response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      final activitiesList =
          jsonList.map((json) => ActivityData.fromJson(json)).toList();
      return activitiesList;
    } else {
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<List<PostReport>> getPostsReports(
      String api, String username, String tokenID) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };
    var url = Uri.parse('$baseUrl$api');

    var response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonString =
          utf8.decode(response.bodyBytes); // Specify the correct encoding
      final data = jsonDecode(jsonString);
      final List<PostReport> posts =
          List<PostReport>.from(data.map((json) => PostReport.fromJson(json)));
      return posts;
    } else {
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<dynamic> deletePostsReport(
      String api, String username, String tokenID, List<String> ids) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
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

  Future<dynamic> updateUser(
      String api, UpdateData data, String tokenID, String username) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };
    var url = Uri.parse('$baseUrl$api/$username');

    var userJson = jsonEncode({
      'username': data.username,
      'fullname': data.fullname,
      'email': data.email,
      'phone': data.phone,
      'about_me': data.about_me,
      'city': data.city,
      'department': data.department,
      'course': data.course,
      'year': data.year,
      'purpose': data.purpose,
      'office': data.office,
      'privacy': data.privacy,
    });

    var response = await http.put(url, headers: _headers, body: userJson);
    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 409) {
      //throw exception
      throw '409';
    }
  }

  static Future<int> updatePic(
      String api, tokenID, username, filename, Uint8List image) async {
    Map<String, String> _headers = {"Authorization": tokenID, "User": username};

    var request = http.MultipartRequest(
        'POST', Uri.parse(baseUrl + api + "/" + username));
    request.headers.addAll(_headers);

    // Attach the image as a multipart file to the request
    request.files.add(http.MultipartFile.fromBytes(
      'image', // field name of the file
      image,
      filename: "$filename.jpg",
      contentType: MediaType('image', 'jpeg'),
    ));

    // Send the request
    var response = await request.send();

    return response.statusCode;
  }

  Future<String> getProfilePic(
      String api, String tokenID, String username) async {
    Map<String, String> _headers = {"Authorization": tokenID, "User": username};

    var url = Uri.parse(baseUrl + api + "/" + username);
    var response = await client.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      //throw exception
      throw extension("Something went wrong");
    }
  }


  Future<dynamic> changePwd(
      String api, ChangePwdData data, String tokenID, String username) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };
    var url = Uri.parse('$baseUrl$api');

    var userJson = jsonEncode({
      'oldPassword': data.oldPassword,
      'newPassword': data.newPassword,
      'passwordV': data.passwordV,
    });

    var response = await http.put(url, headers: _headers, body: userJson);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.statusCode;
    }
  }

  Future<dynamic> deleteAccount(
      String api, String tokenID, String username) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };
    var url = Uri.parse('$baseUrl$api/$username');

    var response = await http.delete(url, headers: _headers);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.statusCode;
    }
  }

  Future<List<LocationGetData>> getLocations(
      String api, String tokenID, String username, String type) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };
    var url = Uri.parse('$baseUrl$api?type=$type');

    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final jsonString = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonString);
      final List<LocationGetData> locationsList = List<LocationGetData>.from(
          data.map((json) => LocationGetData.fromJson(json)));
      return locationsList;
    } else {
      // throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<List<RouteGetData>> getRoutes(
      String api, String tokenID, String username) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
    };
    var url = Uri.parse('$baseUrl$api');

    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final jsonString = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonString);
      final List<RouteGetData> routesList = List<RouteGetData>.from(
          data.map((json) => RouteGetData.fromJson(json)));
      return routesList;
    } else {
      // throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<dynamic> createRoute(
      String api, String username, String tokenID, RouteGetData route) async {
    var _headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": tokenID,
      "User": username,
    };

    var url = Uri.parse('$baseUrl$api');

    var activityJson = jsonEncode({
      'creator': route.creator,
      'name': route.name,
      'participants': route.participants,
      'locations': route.locations,
    });

    var response = await http.post(
      url,
      headers: _headers,
      body: activityJson,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      // Throw exception
      throw Exception(
          "Error: ${response.statusCode} - ${response.reasonPhrase}");
    }

  Future fetchNewsFCT(int counter) async {
    List<NewsData> news = [];
    final url;
    if (counter == 0) {
      url = Uri.parse('$fctUrl/noticias');
    } else {
      url = Uri.parse('$fctUrl/noticias?page=$counter');
    }

    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);
    final titles = html
        .querySelectorAll(' div.views-field-title > span > a')
        .map((e) => e.innerHtml.trim())
        .toList();

    final imageUrl = html
        .querySelectorAll(
            'div.noticia-imagem.views-field-field-imagem-fid.col-tn-12.col-xs-6.col-sm-12 > span > a > img')
        .map((e) => e.attributes['src'])
        .toList();
    final text = html
        .querySelectorAll(' div.views-field-field-resumo-value > span > p')
        .map((e) => e.innerHtml.trim())
        .toList();
    final timestamp = html
        .querySelectorAll('div.views-field-created > span')
        .map((e) => e.innerHtml.trim())
        .toList();
    final lastElement = html
        .querySelectorAll(
            ' div > div.clearfix > div > div.item-list > ul > li.pager-last.last > a')
        .map((e) => e.innerHtml.trim())
        .toList();
    final newsUrls = html
        .querySelectorAll(
            'div.noticia-imagem.views-field-field-imagem-fid.col-tn-12.col-xs-6.col-sm-12 > span > a')
        .map((e) => e.attributes['href'])
        .toList();

    print(newsUrls);

    news = List.generate(
        titles.length,
        (index) => NewsData(
              title: titles[index],
              text: text[index],
              imageUrl: imageUrl[index]!,
              timestamp: timestamp[index].toString(),
              newsUrl: newsUrls[index]!,
              path: titles[index]
                  .toLowerCase()
                  .replaceAll(new RegExp(r'\s'), '-'),
            ));

    return news;
  }

  Future fetchSingularNewsFCT(String urlString) async {
    Uri url = Uri.parse(fctUrl + urlString);
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final titleElement = html.querySelector('div.col-tn-12.col-sm-7 > h1');
    String title = titleElement?.text.trim() ?? "Title not found";

    final imageElement = html.querySelector('div.noticia-imagem > img');
    String imageUrl = imageElement?.attributes['src'] ?? "Image URL not found";

    final textContainer = html.querySelector('div.noticia-corpo');
    String text = "";

    if (textContainer != null) {
      // Concatenating all the paragraphs in the 'noticia-corpo' div
      textContainer.querySelectorAll('p').forEach((element) {
        text += element.text.trim() + " "; // Using .text instead of .innerHtml
      });
    } else {
      text = "Text not found";
    }

    final timestampElement = html.querySelector('div > p');
    String timestamp = timestampElement?.text.trim() ?? "Timestamp not found";

    print(timestamp);

    return NewsData(
      title: title,
      text: text,
      imageUrl: imageUrl,
      timestamp: timestamp,
      newsUrl: urlString,
      path: title.toLowerCase().replaceAll(new RegExp(r'\s'), '-'),
    );
  }
}

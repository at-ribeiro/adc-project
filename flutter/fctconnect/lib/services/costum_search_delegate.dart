import 'package:flutter/material.dart';
import 'package:responsive_login_ui/models/user_query_data.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:responsive_login_ui/views/others_profile.dart';

import '../models/Token.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back_ios),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Typically you would navigate to another page or show the selected result
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Start typing to search'));
    } else {
      return FutureBuilder<List<UserQueryData>>(
        future: BaseClient().searchUser(query, "/search"),
        builder: (BuildContext context,
            AsyncSnapshot<List<UserQueryData>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: GestureDetector(
                    child: Text(snapshot.data![index].username),
                    onTap: () async {
                      var results = await Future.wait([
                        SessionManager.get('CD'),
                        SessionManager.get('ED'),
                        SessionManager.get('Role'),
                        SessionManager.get('Token'),
                        SessionManager.get('Username')
                      ]);

                      var _token = Token(
                          creationDate: int.parse(results[0]!),
                          expirationDate: int.parse(results[1]!),
                          role: results[2]!,
                          tokenID: results[3]!,
                          username: results[4]!);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherProfile(token: _token),
                        ),
                      );
                    },
                  ),
                  subtitle: Text(snapshot.data![index].fullname),
                );
              },
            );
          }
        },
      );
    }
  }
}

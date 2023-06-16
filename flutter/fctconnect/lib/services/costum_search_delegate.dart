import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/models/paths.dart';
import 'package:responsive_login_ui/models/user_query_data.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/views/messages/new_message.dart';

import '../data/cache_factory_provider.dart';

import '../models/Token.dart';

class CustomSearchDelegate extends SearchDelegate {
  final String type;

  CustomSearchDelegate(this.type);

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
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () async {
                      var cd = await CacheDefault.cacheFactory.get('Creationd');
                      var ed =
                          await CacheDefault.cacheFactory.get('Expirationd');
                      var role = await CacheDefault.cacheFactory.get('Role');
                      var tokenID =
                          await CacheDefault.cacheFactory.get('Token');
                      var username =
                          await CacheDefault.cacheFactory.get('Username');

                      var _token = Token(
                        creationDate: int.parse(cd!),
                        expirationDate: int.parse(ed!),
                        role: role!,
                        tokenID: tokenID!,
                        username: username!,
                      );
                 switch(type){
                          case 'msg':
                            Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                builder: (ctx) => NewMessage(
                                ),
                              ),
                            );
                            break;
                            case "profile":
                        
                        if (_token.username == snapshot.data![index].username) {
                          context.go(Paths.myProfile);
                        } else {
                          context.go(Paths.otherProfile+"?username=${snapshot.data![index].username}" );
                      }
                      break;
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/default_profile.jpg',
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(5)),
                          Column(children: [
                            Text(snapshot.data![index].fullname),
                            Text(snapshot.data![index].username),
                          ]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      );
    }
  }
}

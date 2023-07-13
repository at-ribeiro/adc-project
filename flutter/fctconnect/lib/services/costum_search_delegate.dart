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
  String? username;

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


  Widget _loadProfilePic(String profilePic) {
    if (profilePic.isEmpty) {
      return const CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(
          'https://storage.googleapis.com/fct-connect-estudasses.appspot.com/default_profile.jpg',
        ),
      );
    } else {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(
          profilePic,
        ),
      );
    }
  }

  Widget _buildSearchContent(BuildContext context) {
    if (query.isEmpty) {
      return Center(
          child: Text(
        'Escreva alguma coisa para pesquisar',
      ));
    } else {
      return FutureBuilder<List<UserQueryData>>(
        future: BaseClient().searchUser(
          query,
          "/search",
          username!,
        ),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                  ),
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
                        profilePic: '',
                      );
                      switch (type) {
                        case 'msg':
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (ctx) => NewMessage(),
                            ),
                          );
                          break;
                        case "profile":
                          if (_token.username ==
                              snapshot.data![index].username) {
                            close(context, null);
                            context.go(Paths.myProfile);
                          } else {
                            close(context, null);
                            context.go(Paths.otherProfile +
                                "/${snapshot.data![index].username}");
                          }
                          break;
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(20), // Make card bigger
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0.2),
                            child: _loadProfilePic(
                                snapshot.data![index].profilePic),
                          ),
                          Padding(
                              padding: EdgeInsets.all(
                                  10)), // Increase padding between Avatar and Text
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data![index].username,
                                  style: TextStyle(
                                      fontSize: 18,),
                                ),
                                Text(
                                  snapshot.data![index].fullname,
                                  style: TextStyle(
                                      fontSize: 12,),
                                ),
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

  @override
  Widget buildSuggestions(BuildContext context) {
    fetchUsername();
    return Container(
      // Setting the gradient background
      child: _buildSearchContent(context), // The actual search content
    );
  }

  Future<void> fetchUsername() async {
    username = await CacheDefault.cacheFactory.get('Username');
  }
}

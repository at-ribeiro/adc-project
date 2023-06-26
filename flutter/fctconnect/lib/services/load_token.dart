import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../models/Token.dart';
import '../models/paths.dart';

class TokenGetterWidget extends StatelessWidget {
  final ValueChanged<Token> onTokenLoaded;

  TokenGetterWidget({required this.onTokenLoaded, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadToken(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                context.go(Paths.login);
              });
              return Container(
                decoration: kGradientDecorationUp,
              );
            } else {
              Token token = snapshot.data;
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                onTokenLoaded(token);
              });
              if (token.expirationDate <
                  DateTime.now().millisecondsSinceEpoch) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  context.go(Paths.login);
                });
                return Container(
                  decoration: kGradientDecorationUp,
                );
              } else if (token.tokenID == null || token.tokenID == "") {
                return Container(
                  decoration: kGradientDecorationUp,
                );
              }

              return Container(
                decoration: kGradientDecorationUp,
              );
            }
          } else {
            return Container(
                decoration: kGradientDecorationUp,
                child: const Center(child: CircularProgressIndicator()));
          }
        });
  }

  // _loadToken method here...
}

Future<Token> _loadToken() async {
  try {
    String username = await CacheDefault.cacheFactory.get("Username") as String;
    String role = await CacheDefault.cacheFactory.get("Role") as String;
    String tokenID = await CacheDefault.cacheFactory.get("Token") as String;
    String creationDate =
        await CacheDefault.cacheFactory.get("Creationd") as String;
    String expirationDate =
        await CacheDefault.cacheFactory.get("Expirationd") as String;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String profilePiC = await prefs.getString("ProfilePic") as String;

    Token token = Token(
        username: username,
        role: role,
        tokenID: tokenID,
        creationDate: int.parse(creationDate),
        expirationDate: int.parse(expirationDate),
        profilePic: profilePiC);

    return token;
  } catch (e) {
    return Future.error(e);
  }
}

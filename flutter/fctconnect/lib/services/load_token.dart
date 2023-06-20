import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../models/Token.dart';

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
              context.go("/login");
              return Container(
                decoration: kGradientDecorationUp,
              );
            } else {
              Token token = snapshot.data;
              if (token.expirationDate <
                  DateTime.now().millisecondsSinceEpoch) {
                String errorText = "Sessão expirada";
                return AlertDialog(
                  shape: const RoundedRectangleBorder(
                    borderRadius: kBorderRadius,
                  ),
                  backgroundColor: kAccentColor0.withOpacity(0.3),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        errorText,
                        style: const TextStyle(color: kAccentColor0),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Volte ao login'),
                      ),
                    ],
                  ),
                );
              } else if (token.tokenID == null || token.tokenID == "") {
                context.go("/login");
                return Container(
                  decoration: kGradientDecorationUp,
                );
              }
              onTokenLoaded(token); // Call the callback
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
    Token token = Token(
        username: username,
        role: role,
        tokenID: tokenID,
        creationDate: int.parse(creationDate),
        expirationDate: int.parse(expirationDate));
    return token;
  } catch (e) {
    return Future.error(e);
  }
}

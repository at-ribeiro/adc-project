import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              return AlertDialog(
                title: Text('Não estás logado!'),
                content: Text('Volta para trás e faz login.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.go("/login");
                    },
                    child: Text('Voltar ao login.'),
                  ),
                ],
              );
            } else {
              Token token = snapshot.data;
              if (token.expirationDate <
                  DateTime.now().millisecondsSinceEpoch) {
                return AlertDialog(
                  title: Text('Sessão expirada!'),
                  content: Text('Volta para trás e faz login.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.go("/login");
                      },
                      child: Text('Voltar ao login.'),
                    ),
                  ],
                );
              }
              onTokenLoaded(token); // Call the callback
              return Container();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
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

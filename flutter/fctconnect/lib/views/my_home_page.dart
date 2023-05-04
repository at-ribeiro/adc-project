import 'package:flutter/material.dart';


import '../models/Token.dart';

class MyHomePage extends StatelessWidget {
  final Future<Token> token;

  const MyHomePage({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Token>(
        future: token,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Token token = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${token.username}'),
                  Text('Role: ${token.role}'),
                  Text('Token ID: ${token.tokenID}'),
                  Text('Creation Date: ${DateTime.fromMillisecondsSinceEpoch(token.creationDate as int)}'),
                  Text('Expiration Date: ${DateTime.fromMillisecondsSinceEpoch(token.expirationDate as int)}'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

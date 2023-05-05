import 'package:flutter/material.dart';
import '../models/Token.dart';

class MyHomePage extends StatelessWidget {
  final Future<Token> token;

  const MyHomePage({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: FutureBuilder<Token>(
        future: token,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Token token = snapshot.data!;
            String username = token.username;
            String role = token.role;
            String tokenID = token.tokenID;
            DateTime creationDate =
                DateTime.fromMillisecondsSinceEpoch(token.creationDate as int);
            DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(
                token.expirationDate as int);
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/default_profile.jpg'),
                        ),
                        const SizedBox(height: 10),
                        Text(username
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Eventos'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Grupos'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
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
                  Text(
                      'Creation Date: ${DateTime.fromMillisecondsSinceEpoch(token.creationDate as int)}'),
                  Text(
                      'Expiration Date: ${DateTime.fromMillisecondsSinceEpoch(token.expirationDate as int)}'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

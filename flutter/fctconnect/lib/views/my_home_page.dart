import 'package:flutter/material.dart';
import '../models/Token.dart';

class MyHomePage extends StatefulWidget {
  final Future<Token> token;

  const MyHomePage({Key? key, required this.token}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Token _token;
  String _postText = '';

  @override
  void initState() {
    super.initState();
    widget.token.then((value) {
      setState(() {
        _token = value;
      });
    });
  }

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
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // set the initial index to 0
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Navigate to home page
          } else if (index == 1) {
            // Display post modal
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => _buildPostModal(context),
            );
          } else if (index == 2) {
            // Navigate to profile page
          }
        },
      ),
    );
  }

  Widget _buildDrawer() {
    if (_token != null) {
      String username = _token.username;
      String role = _token.role;
      String tokenID = _token.tokenID;
      DateTime creationDate =
          DateTime.fromMillisecondsSinceEpoch(_token.creationDate as int);
      DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(
          _token.expirationDate as int);
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
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/default_profile.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(username),
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
    } else {
      return const Drawer();
    }
  }

  Widget _buildBody() {
    if (_token != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${_token.username}'),
            Text('Role: ${_token.role}'),
            Text('Token ID: ${_token.tokenID}'),
            Text(
                'Creation Date: ${DateTime.fromMillisecondsSinceEpoch(_token.creationDate as int)}'),
            Text(
                'Expiration Date: ${DateTime.fromMillisecondsSinceEpoch(_token.expirationDate as int)}'),
          ],
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildPostModal(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(16.0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _postText = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'O que se passa na FC?',
                  border: OutlineInputBorder(),
                ),
                minLines: 5,
                maxLines: 10,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                //fazer a chamada rest
              },
              child: const Text('Post'),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
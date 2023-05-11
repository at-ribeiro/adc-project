import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import '../models/Post.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import 'login_view.dart';
import 'event_view.dart';

class MyHomePage extends StatefulWidget {
  final Token token;


  const MyHomePage({Key? key, required this.token}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Token _token;
  String _postText = '';
  File? _imageFile;

  late DropzoneViewController dropControler;

  @override
  void initState(){
  
    super.initState();
  
        _token = widget.token;
 
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
    String username = _token.username;
    return Drawer(
      child: Column(
        children: [
          IntrinsicWidth(
            stepWidth: double.infinity,
            child: DrawerHeader(
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
            ), // Set the width of the DrawerHeader to the maximum available width
          ),
          ListTile(
            title: const Text('Eventos'),
            onTap: () {
              Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (ctx) => EventView()));
            },
          ),
          ListTile(
            title: const Text('Grupos'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          ListTile(
            title: const Text('Sair'),
            onTap: () {
              BaseClient().doLogout("/logout", _token.username, _token.tokenID);
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (ctx) => const LoginView()));
            },
          ),
        ],
      ),
    );
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

  void _selectImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  setState(() {
    _imageFile = pickedFile != null ? File(pickedFile.path) : null;
  });
}

void _takePhoto() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
  setState(() {
    _imageFile = pickedFile != null ? File(pickedFile.path) : null;
  });
}

Widget _buildPostModal(BuildContext context) {
  return SingleChildScrollView(
    child: Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(children: [
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
              hintText: 'O que se passa na FCT?',
              border: OutlineInputBorder(),
            ),
            minLines: 5,
            maxLines: 10,
          ),
        ),
        const SizedBox(height: 16.0),
        if (_imageFile != null) Image.file(_imageFile!),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Post post = Post(post: _postText, image: _imageFile, username: _token.username);
                BaseClient().createPost("/post", _token.tokenID, post);
              },
              child: const Text('Post'),
            ),
            ElevatedButton(
              onPressed: () {
                _selectImage();
              },
              child: const Text('Select Image'),
            ),
            ElevatedButton(
              onPressed: () {
                _takePhoto();
              },
              child: const Text('Take Photo'),
            ),
          ],
        ),
      ]),
    ),
  );
}
}

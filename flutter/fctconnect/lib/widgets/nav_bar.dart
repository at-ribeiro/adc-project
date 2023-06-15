import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/services/image_up.dart';

import '../models/Post.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/post_actions.dart';
import '../services/load_token.dart';

class NavigationBarModel extends StatefulWidget {
  final int currentIndex;

  NavigationBarModel({this.currentIndex = 0});

  @override
  State<NavigationBarModel> createState() => _NavigationBarModelState();
}

class _NavigationBarModelState extends State<NavigationBarModel> {
  late Token _token;
  late int _currentIndex;
  bool _isLoadingToken = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
        });
      });
    } else {
      return BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper, color: Colors.black),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add, color: Colors.black),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            context.go(Paths.homePage);
          } else if (index == 1) {
            context.go(Paths.noticias);
          } else if (index == 2) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => _buildPostModal(context),
            );
          } else if (index == 3) {
            context.go(Paths.myProfile);
          }
        },
      );
    }
  }

  Widget _buildPostModal(BuildContext context) {
    TextEditingController _postTextController = TextEditingController();
    ImageUp _imageUp = ImageUp();
    Uint8List? _imageData;
    String? _fileName;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(16.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _postTextController,
              decoration: const InputDecoration(
                hintText: 'O que se passa na FCT?',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Diga alguma coisa';
                }
                return null;
              },
              minLines: 5,
              maxLines: 10,
            ),
          ),
          const SizedBox(height: 30.0),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              ElevatedButton(
                onPressed: () async {
                  if (_postTextController.text.isEmpty) {
                    return;
                  }
                  int response = await PostActions.doPost(
                      _postTextController.text,
                      _imageData,
                      _fileName,
                      _token.username,
                      _token.tokenID);
                      if (response == 200) {
                        Navigator.pop(context);
                      }
                },
                child: const Text('Post'),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              ElevatedButton(
                onPressed: () async {
                  var imageDataMap = await _imageUp.pickImage();
                  if (imageDataMap.isNotEmpty) {
                    _imageData = imageDataMap['imageData'];
                    _fileName = imageDataMap['fileName'];
                  }
                },
                child: const Text('Select Image'),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () async {
                    var imageDataMap = await _imageUp.takePicture();
                    if (imageDataMap.isNotEmpty) {
                      _imageData = imageDataMap['imageData'];
                      _fileName = imageDataMap['fileName'];
                    }
                  },
                  child: const Text('Take Photo'),
                ),
              if (_imageData != null) Image.memory(_imageData!),
            ],
          ),
        ]),
      ),
    );
  }
}

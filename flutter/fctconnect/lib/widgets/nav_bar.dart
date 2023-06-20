import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/services/image_up.dart';
import 'package:responsive_login_ui/views/my_home_page.dart';

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
      return Container(
        color: kPrimaryColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: GNav(
            backgroundColor: kPrimaryColor,
            activeColor: kAccentColor1,
            
            tabBackgroundColor: kSecondaryColor,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            
            onTabChange: (index) {
              if (index == 0) {
                context.go(Paths.homePage);
              } else if (index == 1) {
                context.go(Paths.noticias);
              } else if (index == 2) {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30.0)),
                  ),
                  isScrollControlled: true,
                  builder: (context) => _buildPostModal(context),
                  
                );
              
              } else if (index == 3) {
                context.go(Paths.myProfile);
              }
            },
            tabs: [
              GButton(
                iconColor: kAccentColor0,
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                iconColor: kAccentColor0,
                icon: Icons.newspaper,
                text: 'Noticias',
              ),
              GButton(
                iconColor: kAccentColor0,
                icon: Icons.post_add,
                text: 'Post',
              ),
              GButton(
                iconColor: kAccentColor0,
                icon: Icons.person,
                text: 'Perfil',
              ),
            ],
          ),
        ),
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
            child:  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: kAccentColor0.withOpacity(0.3),
                    ),
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextFormField(
                          style: TextStyle(
                            color: kAccentColor0,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(20),
                            hintText: 'O que se passa na FCT?',
                            border: InputBorder.none,
                          ),
                          controller: _postTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Diga alguma coisa...';
                            } 
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 30.0),
      
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

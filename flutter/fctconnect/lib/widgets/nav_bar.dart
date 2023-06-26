import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/services/media_up.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/post_actions.dart';
import '../services/load_token.dart';

class NavigationBarModel extends StatefulWidget {
  final String location;

  NavigationBarModel({required this.location});

  @override
  State<NavigationBarModel> createState() => _NavigationBarModelState();
}

class _NavigationBarModelState extends State<NavigationBarModel> {
  late int _selectedIndex;
  late String _location;
  late Token _token;
  bool _isLoadingToken = true;

  @override
  void initState() {
    super.initState();
    _location = widget.location;
    // You can initialize _selectedIndex here based on the _location
    if (_location == Paths.homePage) {
      _selectedIndex = 0;
    } else if (_location == Paths.noticias) {
      _selectedIndex = 1;
    } else if (_location == Paths.post) {
      _selectedIndex = 2;
    } else if (_location == Paths.myProfile) {
      _selectedIndex = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
          }
        });
      });
    } else {
      int auxIndex = _selectedIndex;
      return ClipRRect(
        
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: NavigationBar(
          backgroundColor: kPrimaryColor,
          animationDuration: const Duration(seconds: 1),
          indicatorColor: kAccentColor1,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == 0) {
              context.go(Paths.homePage);
            } else if (index == 1) {
              context.go(Paths.noticias);
            } else if (index == 2) {
              showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: kBorderRadius),
                  backgroundColor: kPrimaryColor,
                  context: context,
                  builder: (BuildContext context) {
                    return _buildPostModal(context);
                  });
              index = auxIndex;
            } else if (index == 3) {
              context.go(Paths.myProfile);
            }
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: _navBarItems,
        ),
      );
    }
  }

  static const _navBarItems = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined, color: kAccentColor0),
      label: 'Home',
      selectedIcon: Icon(Icons.home_rounded),
    ),
    NavigationDestination(
        icon: Icon(Icons.newspaper_outlined, color: kAccentColor0),
        label: 'Noticias',
        selectedIcon: Icon(Icons.newspaper_rounded)),
    NavigationDestination(
        icon: Icon(Icons.post_add_outlined, color: kAccentColor0),
        label: 'Post',
        selectedIcon: Icon(Icons.post_add)),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  Widget _buildPostModal(BuildContext context) {
    TextEditingController _postTextController = TextEditingController();
    MediaUp _mediaUp = MediaUp();
    Uint8List? _data;
    String? _fileName;
    String? _mediaType;
    String? _type;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(16.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: kBorderRadius,
                color: kAccentColor0.withOpacity(0.3),
              ),
              height: 150,
              child: ClipRRect(
                borderRadius: kBorderRadius,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  if (_postTextController.text.isEmpty) {
                    return;
                  }
                  int response = await PostActions.doPost(
                      _postTextController.text,
                      _data,
                      _fileName,
                      _mediaType,
                      _type,
                      _token.username,
                      _token.tokenID);
                  if (response == 200) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Post'),
              ),
              SizedBox(width: 30.0),
              ElevatedButton(
                onPressed: () async {
                  var imageDataMap = await _mediaUp.pickFile(MediaType.image);
                  if (imageDataMap.isNotEmpty) {
                    _data = imageDataMap['fileData'];
                    _fileName = imageDataMap['fileName'];
                    _mediaType = imageDataMap['mediaType'];
                    _type = imageDataMap['type'];
                  }
                },
                child: const Text('Selecione a Imagem'),
              ),
              SizedBox(width: 30.0),
              ElevatedButton(
                onPressed: () async {
                  var videoDataMap = await _mediaUp.pickFile(MediaType.video);
                  if (videoDataMap.isNotEmpty) {
                    _data = videoDataMap['fileData'];
                    _fileName = videoDataMap['fileName'];
                    _mediaType = videoDataMap['mediaType'];
                    _type = videoDataMap['type'];
                  }
                },
                child: const Text('Selecione o Video'),
              ),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () async {
                    var imageDataMap = await _mediaUp.takePicture();
                    if (imageDataMap.isNotEmpty) {
                      _data = imageDataMap['fileData'];
                      _fileName = imageDataMap['fileName'];
                      _mediaType = imageDataMap['mediaType'];
                      _type = imageDataMap['type'];
                    }
                  },
                  child: const Text('Tire uma Foto'),
                ),
              if (_data != null) Image.memory(_data!),
              SizedBox(width: 30.0),
            ],
          ),
          SizedBox(height: 20.0)
        ]),
      ),
    );
  }
}

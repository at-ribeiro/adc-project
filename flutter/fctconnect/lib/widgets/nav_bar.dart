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
    } else if (_location == Paths.createPost) {
      _selectedIndex = 2;
    } else if (_location == Paths.myProfile) {
      _selectedIndex = 3;
    } else {
      _selectedIndex = 0; // or any other default value that suits your needs
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
          animationDuration: const Duration(seconds: 1),
          // indicatorColor: Style.kAccentColor1,
          selectedIndex: _selectedIndex,

          onDestinationSelected: (index) {
            if (index == 0) {
              context.go(Paths.homePage);
            } else if (index == 1) {
              context.go(Paths.noticias);
            } else if (index == 2) {
              context.go(Paths.createPost);
              // showModalBottomSheet(
              //     shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
              //     backgroundColor: kPrimaryColor,
              //     context: context,
              //     builder: (BuildContext context) {
              //       context.go(Paths.createPost);
              //       return Container();
              //     });
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

  static final _navBarItems = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      label: 'Home',
      selectedIcon: Icon(Icons.home_rounded),
    ),
    NavigationDestination(
        icon: Icon(Icons.newspaper_outlined),
        label: 'Noticias',
        selectedIcon: Icon(Icons.newspaper_rounded)),
    NavigationDestination(
        icon: Icon(Icons.post_add_outlined),
        label: 'Post',
        selectedIcon: Icon(Icons.post_add)),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];
}

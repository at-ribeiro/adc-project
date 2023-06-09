import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/paths.dart';

class NavigationBarModel extends StatelessWidget {
  final int currentIndex;

  NavigationBarModel({this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.shifting,
      currentIndex: currentIndex,
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
          // showModalBottomSheet(
          //   context: context,
          //   isScrollControlled: true,
          //   builder: (context) => _buildPostModal(context),
          // );
        } else if (index == 3) {
          context.go(Paths.myProfile);
        }
      },
    );
  }
}


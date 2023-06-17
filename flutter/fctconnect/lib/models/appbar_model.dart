import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/costum_search_delegate.dart';
import '../services/load_token.dart';
import 'Token.dart';

class AppBarModel extends StatefulWidget {
  const AppBarModel({super.key});

  @override
  State<AppBarModel> createState() => _AppBarModelState();
}

class _AppBarModelState extends State<AppBarModel> {
  bool _isLoadingToken = true;
  late Token _token;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          Color.fromARGB(0, 0, 0, 0), // Set the background color to transparent
      elevation: 0, // Remove the elevation
      title: const Text(''),
      actions: [
        IconButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: CustomSearchDelegate("profile"),
            );
          },
          icon: Icon(Icons.search),
        )
      ],
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
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.topRight,
            colors: [
              kPrimaryColor.withOpacity(0.5),
            ],
          ),
        ),
      ),
    );
  }
}

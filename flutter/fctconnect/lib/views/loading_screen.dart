import 'package:flutter/material.dart';

import '../models/Token.dart';

  
class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
    late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 8, 89, 251),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

void afterLogin(Future<Token> token) async {

Token _token = await token;

              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (ctx) => MyHomePage(
                        token: response
                    )
                ),
              );

}
}








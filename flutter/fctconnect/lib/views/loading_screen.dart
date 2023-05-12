import 'package:flutter/material.dart';
import 'package:responsive_login_ui/views/login_view.dart';

import '../models/Token.dart';
import 'my_home_page.dart';
import 'login_view.dart';

class LoadingScreen extends StatefulWidget {
  final Future<Token> token;

  const LoadingScreen({Key? key, required this.token}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.delayed(
        Duration(seconds: 1)); // Simulating an asynchronous operation
    try {
      final token = await widget.token;

    } catch (error) {
      setState(() {
        _showError = true;
      });
      showErrorMessage();
    }
  }

  void showErrorMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Username ou password errados! \n Tente outra vez.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginView(),
                  ),
                );
              },
              child: Text('Voltar ao Login!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _showError
            ? CircularProgressIndicator()
            : FutureBuilder<Token>(
                future: widget.token,
                builder: (BuildContext context, AsyncSnapshot<Token> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While waiting for the future to complete, show a loading indicator
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // If an error occurred while fetching the token, show the loading indicator and handle the error with showDialog
                    return CircularProgressIndicator();
                  } else {
                    // When the future completes successfully, navigate to the home page
                    final token = snapshot.data;
                    return MyHomePage(token: token!);
                  }
                }),
      ),
    );
  }
}

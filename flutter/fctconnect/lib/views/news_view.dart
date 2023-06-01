import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:responsive_login_ui/views/event_creator.dart';
import 'package:responsive_login_ui/views/my_home_page.dart';
import 'package:responsive_login_ui/views/search_event_view.dart';

import '../models/NewsData.dart';
import '../models/Post.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import 'my_profile.dart';

class NewsView extends StatefulWidget {
  final Token token;

  const NewsView({Key? key, required this.token}) : super(key: key);

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  late Token _token;
  List<NewsData> _news = [];
  
  String _postText = '';
  Uint8List? _imageData;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _loadNews();
  }

  Future<void> _loadNews() async {
    List<NewsData> news =
        await BaseClient().fetchNews("/news", _token.tokenID, _token.username);
    if (mounted) {
      setState(() {
        _news = news;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
      ),
      body: _news.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _news.length,
              itemBuilder: (BuildContext context, int index) {
                final news = _news[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (ctx) => NewsDetailPage(news: news)));
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.network(
                              news.url,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                news.title,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: NavigationBody(),
    );
  }

  Widget NavigationBody() {
    return BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: 0, // set the initial index to 0
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
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (ctx) => MyHomePage()));
          } else if (index == 1) {
            
          } else if (index == 2) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => _buildPostModal(context),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (ctx) => MyProfile()));
          }
        },
      );
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
          const SizedBox(height: 30.0),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              ElevatedButton(
                onPressed: () async {
                  Post post = Post(
                      post: _postText,
                      imageData: _imageData,
                      username: _token.username,
                      fileName: _fileName);
                  int response = await BaseClient()
                      .createPost("/post", _token.tokenID, post);

                  if (response == 200) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } else {
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Erro'),
                          content: Text('Algo nao correu bem!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Tente outra vez'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Post'),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              ElevatedButton(
                onPressed: () {
                  _pickImage();
                },
                child: const Text('Select Image'),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () {
                    _takePicture();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = Uint8List.fromList(fileData);
        _fileName = pickedFile.path.split('/').last;
      });
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = Uint8List.fromList(fileData);
        _fileName = pickedFile.path.split('/').last;
      });
    }
  }
}



class NewsDetailPage extends StatelessWidget {
  final NewsData news;

  const NewsDetailPage({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  news.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  DateFormat('dd-MM-yyyy')
                      .format(DateTime.fromMillisecondsSinceEpoch(
                          int.parse(news.timestamp)))
                      .toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: 400.0, // Replace with your desired height
                  child: AspectRatio(
                    aspectRatio: 16 /
                        9, // Replace with the actual aspect ratio of the image
                    child: FittedBox(
                      fit: BoxFit.contain, // Adjust the fit property as needed
                      child: Image.network(
                        news.url,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  news.text,
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

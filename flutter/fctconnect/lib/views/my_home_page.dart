import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import '../models/FeedData.dart';
import '../models/Post.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import 'login_view.dart';
import 'event_view.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  final Token token;

  const MyHomePage({Key? key, required this.token}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Token _token;
  String _postText = '';
  Uint8List? _imageData;
  String? _fileName;
  List<FeedData> _posts = [];
  bool _loadingMore = false;
  String _lastDisplayedMessageTimestamp =
      DateTime.now().millisecondsSinceEpoch.toString();

  late DropzoneViewController dropControler;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length + (_loadingMore ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index >= _posts.length) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              FeedData post = _posts[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/default_profile.jpg',
                        ),
                      ),
                      const SizedBox(width: 7.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                              child: Text(post.user),
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  25.0, 8.0, 8.0, 8.0),
                              child: Text(post.text),
                            ),
                            const SizedBox(height: 8.0),
                            post.url.isNotEmpty
                                ? AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Image.network(
                                        post.url,
                                        fit: BoxFit.cover,
                                        height: 240.0,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                DateFormat('dd-MM-yyyy HH:mm:ss').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(post.timestamp),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
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
              Navigator.push(
                  context, CupertinoPageRoute(builder: (ctx) => EventView()));
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

  Future<void> _loadPosts() async {
    List<FeedData> posts = await BaseClient().getFeed("/feed", _token.tokenID,
        _token.username, _lastDisplayedMessageTimestamp);
    if (mounted) {
      setState(() {
        _posts = posts;
        if (posts.isNotEmpty) {
          _lastDisplayedMessageTimestamp = posts.last.timestamp;
        }
      });
    }
  }

  Future<void> _refreshPosts() async {
    _lastDisplayedMessageTimestamp =
        DateTime.now().millisecondsSinceEpoch.toString();
    List<FeedData> latestPosts = await BaseClient().getFeed("/feed",
        _token.tokenID, _token.username, _lastDisplayedMessageTimestamp);
    setState(() {
      _posts = latestPosts;
      if (latestPosts.isNotEmpty) {
        _lastDisplayedMessageTimestamp = latestPosts.last.timestamp;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _loadPosts();
    }
  }
}

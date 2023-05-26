import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:responsive_login_ui/views/map_view.dart';
import 'package:responsive_login_ui/views/post_page.dart';
import '../models/FeedData.dart';
import '../models/Post.dart';
import '../models/Token.dart';
import '../services/base_client.dart';
import '../services/costum_search_delegate.dart';

import 'login_view.dart';
import 'event_view.dart';
import 'package:intl/intl.dart';
import 'my_profile.dart';
import 'news_view.dart';

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
  late ScrollController _scrollController;

  late DropzoneViewController dropControler;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    SessionManager.storeSession('session', '/home');
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.token != oldWidget.token) {
      setState(() {
        _token = widget.token;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
              icon: Icon(Icons.search)
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
      ),
      drawer: _buildDrawer(),
      body: ContentBody(),
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
        } else if (index == 1) {
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (ctx) => NewsView(token: _token)));
        } else if (index == 2) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => _buildPostModal(context),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (ctx) => MyProfile(token: _token)));
        }
      },
    );
  }

  Widget ContentBody() {
    return RefreshIndicator(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 8.0, 0.0),
                                child: Text(post.user),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 8.0, 0.0),
                                child: Text(
                                  DateFormat('HH:mm - dd-MM-yyyy').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(post.timestamp),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
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
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (post.likes.contains(_token.username)) {
                                      post.likes.remove(_token.username);
                                    } else {
                                      post.likes.add(_token.username);
                                    }
                                    BaseClient().likePost("/feed",
                                        _token.username, _token.tokenID, post.id, post.user);
                                  });
                                },
                                icon: Icon(
                                  post.likes.contains(_token.username)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                              ),
                              Text(post.likes.length.toString()),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (ctx) => PostPage(token: _token, postID: post.id, postUser: post.user),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.comment_outlined),
                              ),
                            ],
                          ),
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
            title: const Text('Mapa'),
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (ctx) => MapScreen()));
            },
          ),
          ListTile(
            title: const Text('Eventos'),
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (ctx) => EventView(token: _token)));
            },
          ),
          ListTile(
            title: const Text('Grupos'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Calendário'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          ListTile(
            title: const Text('Sair'),
            onTap: () async {
              BaseClient().doLogout("/logout", _token.username, _token.tokenID);

              SessionManager.storeSession('session', '/');
              if (kIsWeb) {
                SessionManager.storeSession('isLoggedIn', 'false');
                SessionManager.delete('Username');
                SessionManager.delete('Token');
                SessionManager.delete('ED');
                SessionManager.delete('CD');
                SessionManager.delete('Role');
              }

              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (ctx) => const LoginView()));
            },
          ),
        ],
      ),
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

  Future<void> _loadPosts() async {
    List<FeedData> posts = await BaseClient().getFeedorPost(
      "/feed",
      _token.tokenID,
      _token.username,
      _lastDisplayedMessageTimestamp,
      _token.username,
    );

    if (posts.isNotEmpty) {
      setState(() {
        _lastDisplayedMessageTimestamp = posts.last.timestamp;
        _posts.addAll(posts);
      });
    }
  }

  Future<void> _refreshPosts() async {
    _lastDisplayedMessageTimestamp =
        DateTime.now().millisecondsSinceEpoch.toString();
    List<FeedData> latestPosts = await BaseClient().getFeedorPost(
      "/feed",
      _token.tokenID,
      _token.username,
      _lastDisplayedMessageTimestamp,
      _token.username,
    );
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

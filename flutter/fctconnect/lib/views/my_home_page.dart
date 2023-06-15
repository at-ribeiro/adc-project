import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:responsive_login_ui/views/map_view.dart';
import 'package:responsive_login_ui/views/messages/messages_view.dart';
import 'package:responsive_login_ui/views/post_page.dart';
import 'package:responsive_login_ui/views/report_view.dart';
import 'package:responsive_login_ui/views/reports_list_view.dart';
import '../models/FeedData.dart';
import '../models/Post.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../services/costum_search_delegate.dart';
import '../data/cache_factory_provider.dart';
import '../services/load_token.dart';
import 'calendar_view.dart';
import 'calendar/calendar_widget.dart';
import 'login_view.dart';
import 'event_view.dart';
import 'package:intl/intl.dart';
import 'my_profile.dart';
import 'news_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Token _token;
  bool _isLoadingToken = true;
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
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    CacheDefault.cacheFactory.set("Session", "/homepage");
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  // @override
  // void didUpdateWidget(MyHomePage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.token != oldWidget.token) {
  //     setState(() {
  //       _token = widget.token;
  //     });
  //   }
  // }

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
      _loadPosts();
      return Scaffold(
        appBar: AppBar(
          title: const Text(''),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: CustomSearchDelegate("profile"));
                },
                icon: Icon(Icons.search))
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
        // bottomNavigationBar: NavigationBody(),
      );
    }
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
                child: Stack(
                  children: [
                    Row(
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
                              const SizedBox(height: 8.0),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 8.0, 8.0),
                                child: Text(post.user),
                              ),
                              const SizedBox(height: 8.0),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 8.0, 8.0),
                                child: Text(
                                  post.text,
                                  style: TextStyle(fontSize: 16.0),
                                ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (post.likes
                                                .contains(_token.username)) {
                                              post.likes
                                                  .remove(_token.username);
                                            } else {
                                              post.likes.add(_token.username);
                                            }
                                            BaseClient().likePost(
                                              "/feed",
                                              _token.username,
                                              _token.tokenID,
                                              post.id,
                                              post.user,
                                            );
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
                                          context.push(
                                            context.namedLocation(Paths.post,
                                                pathParameters: <String,
                                                    String>{
                                                  'id': post.id,
                                                  'user': post.user,
                                                }),
                                          );
                                        },
                                        icon: Icon(Icons.comment_outlined),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 8.0,
                                    right: 8.0,
                                    child: Align(
                                    alignment: Alignment.topRight,
                                    child: PopupMenuButton(
                                      icon: Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'report') {
                                          _showReportDialog(context, post.id, post.user);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'report',
                                          child: Text('Report'),
                                        ),
                                      ],
                                    ),
                                  ),)
                                ],
                              ),

                              const SizedBox(height: 8.0),
                              
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 0.0, 8.0, 8.0),
                                  child: Text(
                                    DateFormat('HH:mm - dd-MM-yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(post.timestamp),
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  void _showReportDialog(BuildContext context, String id, String postUser) {
  TextEditingController _reasonController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  String? selectedReason;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedReason,
              onChanged: (String? newValue) {
                setState(() {
                  selectedReason = newValue;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: 'Assédio',
                  child: Text('Assédio'),
                ),
                DropdownMenuItem<String>(
                  value: 'Fraude',
                  child: Text('Fraude'),
                ),
                DropdownMenuItem<String>(
                  value: 'Spam',
                  child: Text('Spam'),
                ),
                DropdownMenuItem<String>(
                  value: 'Desinformação',
                  child: Text('Desinformação'),
                ),
                DropdownMenuItem<String>(
                  value: 'Discurso de ódio',
                  child: Text('Discurso de ódio'),
                ),
                DropdownMenuItem<String>(
                  value: 'Ameaças ou violência',
                  child: Text('Ameaças ou violência'),
                ),
                DropdownMenuItem<String>(
                  value: 'Conteúdo sexual',
                  child: Text('Conteúdo sexual'),
                ),
              ],
              decoration: InputDecoration(
                labelText: 'Razão',
              ),
            ),
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comentários (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Voltar'),
          ),
          TextButton(
            onPressed: () async {
              await BaseClient().reportPost(
                "/report",
                _token.username,
                _token.tokenID,
                id,
                postUser,
                selectedReason ?? '',
                _commentController.text,
              );
              Navigator.of(context).pop();
            },
            child: Text('Submeter'),
          ),
        ],
      );
    },
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
                  Text(username, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ), // Set the width of the DrawerHeader to the maximum available width
          ),
          ListTile(
            title: const Text('Mapa'),
            onTap: () {
              context.go(Paths.mapas);
            },
          ),
          ListTile(
            title: const Text('Eventos'),
            onTap: () {
              context.go(Paths.events);
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
              context.go(Paths.calendar);
            },
          ),
          ListTile(
            title: const Text('Mensagens'),
            onTap: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (ctx) => MessagesView()));
            },
          ),
          const Spacer(),
          ListTile(
            title: const Text('Report'),
            onTap: () {
              context.go(Paths.report);
            },
          ),
          ListTile(
            title: const Text('Lista de Anomalias'),
            onTap: () {
              context.go(Paths.listReports);
            },
          ),
          ListTile(
            title: const Text('Posts Reportados'),
            onTap: () {
              context.go(Paths.reportedPosts);
            },
          ),
          ListTile(
            title: const Text('Sair'),
            onTap: () async {
              BaseClient().doLogout("/logout", _token.username, _token.tokenID);

              CacheDefault.cacheFactory.logout();
              CacheDefault.cacheFactory.delete('isLoggedIn');

              context.go(Paths.login);
            },
          ),
        ],
      ),
    );
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

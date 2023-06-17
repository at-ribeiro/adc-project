import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/Themes/theme_manager.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/services/session_manager.dart';
import 'package:responsive_login_ui/views/map_view.dart';
import 'package:responsive_login_ui/views/messages/messages_view.dart';
import 'package:responsive_login_ui/views/post_page.dart';
import 'package:responsive_login_ui/views/report_view.dart';
import 'package:responsive_login_ui/views/reports_list_view.dart';
import '../main.dart';
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
  late ThemeManager _themeManager;
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
    _themeManager = Provider.of<ThemeManager>(context, listen: false);
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
        extendBody: true,
        body: Stack(
          children: [
            Container(
              decoration: kGradientDecoration,
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            ContentBody(),
          ],
        ),
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
            return Container(
              margin: EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  width: 1.5,
                  color: Color.fromARGB(255, 120, 119, 119).withOpacity(0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(167, 71, 86, 125).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        'https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/default_profile.jpg',
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Center(
                                      heightFactor:
                                          2.4, // You can adjust this to get the alignment you want
                                      child: Text(post.user),
                                    ),
                                  ],
                                ),
                                PopupMenuButton(
                                  icon: Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    if (value == 'report') {
                                      _showReportDialog(
                                          context, post.id, post.user);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'report',
                                      child: Text('Report'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            if (post.url.isNotEmpty)
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Image.network(
                                    post.url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8.0),
                            Text(
                              post.text,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (post.likes
                                              .contains(_token.username)) {
                                            post.likes.remove(_token.username);
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
                                              pathParameters: <String, String>{
                                                'id': post.id,
                                                'user': post.user,
                                              }),
                                        );
                                      },
                                      icon: Icon(Icons.comment_outlined),
                                    ),
                                  ],
                                ),
                                Text(
                                  DateFormat('HH:mm  dd/MM/yyyy').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(post.timestamp),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showReportDialog(BuildContext context, String id, String postUser) {
    TextEditingController _commentController = TextEditingController();

    String? selectedReason;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Report Post'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    ExpansionTile(
                      title: Text(selectedReason ?? 'Select Reason'),
                      children: [
                        ListTile(
                          title: Text('Assédio'),
                          onTap: () {
                            setState(() {
                              selectedReason = 'Assédio';
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Fraude'),
                          onTap: () {
                            setState(() {
                              selectedReason = 'Fraude';
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Spam'),
                          onTap: () {
                            setState(() {
                              selectedReason = 'Spam';
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Desinformação'),
                          onTap: () {
                            setState(() {
                              selectedReason = 'Desinformação';
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Discurso de ódio'),
                          onTap: () {
                            setState(() {
                              selectedReason = 'Discurso de ódio';
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Ameaças ou violência'),
                          onTap: () {
                            setState(() {
                              selectedReason = 'Ameaças ou violência';
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Conteúdo sexual'),
                          onTap: () {
                            setState(() {
                              selectedReason = 'Conteúdo sexual';
                            });
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Comentários (opcional)',
                      ),
                    ),
                  ],
                ),
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
                    // You should put your function to report post here
                    Navigator.of(context).pop();
                  },
                  child: Text('Submeter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer() {
    ThemeManager themeManager = context.watch<ThemeManager>();
    bool isDarkModeOn = themeManager.themeMode == ThemeMode.dark;
    String username = _token.username;
    return Drawer(
      child: Column(
        children: [
          IntrinsicWidth(
            stepWidth: double.infinity,
            child: DrawerHeader(
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/default_profile.jpg'),
                  ),
                  const SizedBox(height: 5),
                  Text(username, style: const TextStyle(fontSize: 18)),
                  Switch(
                    value: isDarkModeOn,
                    onChanged: (value) {
                      _themeManager.toggleTheme(value);
                    },
                  ),
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

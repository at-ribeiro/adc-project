import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/Themes/theme_manager.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/views/video_player.dart';
import '../models/FeedData.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../data/cache_factory_provider.dart';
import '../services/load_token.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Token _token;
  late ThemeManager _themeManager;
  bool _isLoadingToken = true;
  List<FeedData> _posts = [];
  bool _loadingMore = false;
  String _lastDisplayedMessageTimestamp =
      DateTime.now().millisecondsSinceEpoch.toString();
  late ScrollController _scrollController;

  bool _isDarKThem = true;

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

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        setState(() {
          _token = token;
          _isLoadingToken = false;
        });
      });
    } else {
      _loadPosts();
      return Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            // Here's where you add the gradient
            // Positioned.fill(
            //   child: DecoratedBox(decoration: Style.kGradientDecoration),
            // ),
            // Positioned.fill(
            //   child: BackdropFilter(
            //     filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            //     child: Container(
            //       color: Colors.transparent,
            //     ),
            //   ),
            // ),
            Center(
              // Center the ContentBody widget
              child: Container(
                constraints: BoxConstraints(maxWidth: 800), // Set max width
                child: ContentBody(),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _loadProfilePic(FeedData post) {
    if (post == null || post.profilePic.isEmpty) {
      return const CircleAvatar(
        backgroundImage: NetworkImage(
          'https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/default_profile.jpg',
        ),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          post.profilePic,
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
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  width: 1.5,
                  color: Style.kAccentColor0.withOpacity(0.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Style.kAccentColor2.withOpacity(0.3),
                      borderRadius: Style.kBorderRadius,
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
                                    _loadProfilePic(post),
                                    SizedBox(width: 8.0),
                                    Center(
                                      heightFactor: 2.4,
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
                            if (post.url.contains('.mp4') ||
                                post.url.contains('.mov') ||
                                post.url.contains('.avi') ||
                                post.url.contains('.mkv'))
                              Center(
                                child: VideoPlayerWidget(
                                  videoUrl: post.url,
                                ),
                              ),
                            if ((!post.url.contains('.mp4') &&
                                    !post.url.contains('.mov') &&
                                    !post.url.contains('.avi') &&
                                    !post.url.contains('.mkv')) &&
                                post.url != '')
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ClipRRect(
                                          borderRadius: Style.kBorderRadius,
                                          child: Dialog(
                                            child: Container(
                                              child: ClipRRect(
                                                borderRadius:
                                                    Style.kBorderRadius,
                                                child: Image.network(
                                                  post.url,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: SizedBox(
                                    height:
                                        300.0, // Replace with your desired height
                                    child: AspectRatio(
                                      aspectRatio: 16 /
                                          9, // Replace with the actual aspect ratio of the image
                                      child: FittedBox(
                                        fit: BoxFit
                                            .contain, // Adjust the fit property as needed
                                        child: Image.network(
                                          post.url,
                                        ),
                                      ),
                                    ),
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
                                        context.go(
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

  Future<String> getProfilePicPost(String username) async {
    String profilePic = '';
    await BaseClient()
        .getProfilePic(
      "/profilePic",
      username,
      _token.tokenID,
    )
        .then((value) {
      profilePic = value;
    });
    return profilePic;
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
                    BaseClient().reportPost(
                        "/report",
                        _token.username,
                        _token.tokenID,
                        id,
                        postUser,
                        selectedReason,
                        _commentController.text);
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

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_login_ui/data/cache_factory_provider.dart';

import 'package:responsive_login_ui/models/profile_info.dart';

import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/profile_info.dart';
import '../models/FeedData.dart';

import '../models/Post.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../services/post_actions.dart';
import 'edit_profile_page.dart';
import 'my_home_page.dart';
import 'news_view.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late Token _token;
  bool _isLoadingToken = true;
  final double coverHeight = 200;
  final double profileHeight = 144;
  String selectedButton = 'Info';
  List<FeedData> _posts = [];
  bool _loadingMore = false;
  String _lastDisplayedMessageTimestamp =
      DateTime.now().millisecondsSinceEpoch.toString();

  String _postText = '';
  Uint8List? _imageData;
  String? _fileName;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (selectedButton != 'Info' &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_loadingMore) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    if (_loadingMore) return;

    setState(() {
      _loadingMore = true;
    });

    List<FeedData> posts = await BaseClient().getFeedorPost(
      "/post",
      _token.tokenID,
      _token.username,
      _lastDisplayedMessageTimestamp,
      _token.username,
    );

    if (posts.isNotEmpty) {
      setState(() {
        _lastDisplayedMessageTimestamp = posts.last.timestamp;
        _posts.addAll(posts);
        _loadingMore = false;
      });
    } else {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  Future<ProfileInfo> _loadInfo() async {
    ProfileInfo info = await BaseClient().fetchInfo(
      "/profile",
      _token.tokenID,
      _token.username,
      _token.username,
    );
    return info;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
          });
        });
      });
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          controller: _scrollController,
          children: <Widget>[
            buildTop(),
            ContentWidget(
              loadInfo: _loadInfo,
              selectedButton: selectedButton,
              onButtonSelected: selectButton,
              token: _token,
            ),
            const SizedBox(height: 16),
            Divider(
              color: Colors.grey,
              thickness: 2.0,
            ),
            const SizedBox(height: 16),
            buildInfoSection(),
            const SizedBox(height: 32),
          ],
        ),
      );
    }
  }

  Widget tokenGetter() {
    return FutureBuilder(
        future: _loadToken(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Não estás logado!'),
                content: Text('Volra para trás e faz login.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.go("/login");
                    },
                    child: Text('Voltar ao login.'),
                  ),
                ],
              );
            } else {
              Token token = snapshot.data;
              if (token.expirationDate <
                  DateTime.now().millisecondsSinceEpoch) {
                return AlertDialog(
                  title: Text('Sessão expirada!'),
                  content: Text('Volra para trás e faz login.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.go("/login");
                      },
                      child: Text('Voltar ao login.'),
                    ),
                  ],
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _token = token;
                  _isLoadingToken = false;
                });
              });
              return Container();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<Token> _loadToken() async {
    try {
      String username =
          await CacheDefault.cacheFactory.get("Username") as String;
      String role = await CacheDefault.cacheFactory.get("Role") as String;
      String tokenID = await CacheDefault.cacheFactory.get("Token") as String;
      String creationDate =
          await CacheDefault.cacheFactory.get("Creationd") as String;
      String expirationDate =
          await CacheDefault.cacheFactory.get("Expirationd") as String;
      Token token = Token(
          username: username,
          role: role,
          tokenID: tokenID,
          creationDate: int.parse(creationDate),
          expirationDate: int.parse(expirationDate));
      return token;
    } catch (e) {
      return Future.error(e);
    }
  }

  Widget buildInfoSection() {
    if (selectedButton == 'Info') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre mim',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Desenvolvedor profissional de flutter',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Departamento',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Informatica',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Ano',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '3º Ano',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Grupos',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Eventos',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    } else {
      if (_posts.isEmpty) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Column(
          children: _posts.map((post) => buildPostCard(post)).toList(),
        );
      }
    }
  }

  Widget buildPostCard(FeedData post) {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
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
                            padding:
                                const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
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
                          
                           
                            Positioned(
                              bottom: 8.0,
                              right: 8.0,
                              child: Text(
                              DateFormat('dd-MM-yyyy HH:mm:ss').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(post.timestamp),
                                ),
                              ),
                            ),
                            )
                         
                          
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Delete button pressed
                PostActions.deletePost(post.id, post.user, _token.tokenID);
                setState(() {
                  // Update the UI by removing the post from the list
                  _posts.remove(post);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void selectButton(String buttonName) {
    setState(() {
      selectedButton = buttonName;
    });
  }

  Widget buildTop() {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(
          top: top,
          child: buildProfileAndEditButton(),
        ),
      ],
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.grey,
        child: Image.network(
          'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/foto-fct.jpg',
          width: double.infinity,
          height: coverHeight,
          fit: kIsWeb ? BoxFit.fitWidth : BoxFit.cover,
        ),
      );

  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: const NetworkImage(
          'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/default_profile.jpg',
        ),
      );

  Widget buildProfileAndEditButton() => Stack(
        children: <Widget>[
          Center(child: buildProfileImage()),
          Positioned(
            left: 200,
            bottom: 10,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'editar perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

class ContentWidget extends StatefulWidget {
  final Future<ProfileInfo> Function() loadInfo;
  final String selectedButton;
  final void Function(String) onButtonSelected;
  final Token token;

  const ContentWidget({
    Key? key,
    required this.loadInfo,
    required this.selectedButton,
    required this.onButtonSelected,
    required this.token,
  }) : super(key: key);

  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  late Future<ProfileInfo> _infoFuture;
  late Token _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _infoFuture = widget.loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileInfo>(
      future: _infoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading profile info'),
          );
        } else if (snapshot.hasData) {
          ProfileInfo info = snapshot.data!;
          return Column(
            children: [
              const SizedBox(height: 8),
              Text(
                info.fullname,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                info.role,
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Divider(
                    thickness: 2.0,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: buildButton(text: 'Posts', value: info.nPosts),
                  ),
                  Divider(
                    thickness: 2.0,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child:
                        buildButton(text: 'Following', value: info.nFollowing),
                  ),
                  Divider(
                    thickness: 2.0,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child:
                        buildButton(text: 'Followers', value: info.nFollowers),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.go(Paths.editProfile);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: () {
                      widget.onButtonSelected('Info');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: () {
                      widget.onButtonSelected('Posts');
                      _MyProfileState myProfileState =
                          context.findAncestorStateOfType<_MyProfileState>()!;
                      myProfileState._loadPosts();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Center(
            child: Text('No profile info available'),
          );
        }
      },
    );
  }

  Widget buildButton({
    required String text,
    required int value,
  }) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
}

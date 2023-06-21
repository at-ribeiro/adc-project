import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/data/cache_factory_provider.dart';

import 'package:responsive_login_ui/models/profile_info.dart';

import 'package:intl/intl.dart';
import '../models/FeedData.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../services/post_actions.dart';

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
  late ScrollController _scrollController;
  ProfileInfo? info;

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
      return Container(
        decoration: kGradientDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                color: kAccentColor0,
                thickness: 2.0,
              ),
              const SizedBox(height: 16),
              if (_token.role == "ALUNO") buildInfoAlunoSection(_loadInfo),
              if (_token.role == "PROFESSOR")
                buildInfoProfessorSection(_loadInfo),
              if (_token.role == "EXTERNO") buildInfoExternoSection(_loadInfo),
              const SizedBox(height: 32),
            ],
          ),
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
                content: Text('Volta para trás e faz login.'),
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
                  content: Text('Volta para trás e faz login.'),
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

  Widget buildInfoProfessorSection(Future<ProfileInfo> Function() info) {
    return FutureBuilder<ProfileInfo>(
      future: info(),
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
                    info.about_me,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Departamento',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.department,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Gabinente',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.office,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Contacto',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.email,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cidade',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.city,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          } else {
            return Column(
              children: _posts.map((post) => buildPostCard(post)).toList(),
            );
          }
        } else {
          return Center(
            child: Text('No profile info available'),
          );
        }
      },
    );
  }

  Widget buildInfoAlunoSection(Future<ProfileInfo> Function() info) {
    return FutureBuilder<ProfileInfo>(
      future: info(),
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
                    info.about_me,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Departamento',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.department,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Curso',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.course,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ano',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.year,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cidade',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.city,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Grupos: ${info.nGroups}",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Núcleos: ${info.nNucleos}",
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
        } else {
          return Center(
            child: Text('No profile info available'),
          );
        }
      },
    );
  }

  Widget buildInfoExternoSection(Future<ProfileInfo> Function() info) {
    return FutureBuilder<ProfileInfo>(
      future: info(),
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
                    info.about_me,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cidade',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.city,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Propósito',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    info.purpose,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          } else {
            return Column(
              children: _posts.map((post) => buildPostCard(post)).toList(),
            );
          }
        } else {
          return Center(
            child: Text('No profile info available'),
          );
        }
      },
    );
  }

  Widget buildPostCard(FeedData post) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          width: 1.5,
          color: kAccentColor0.withOpacity(0.0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
          child: Container(
            decoration: BoxDecoration(
              color: kAccentColor2.withOpacity(0.1),
              borderRadius: kBorderRadius,
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
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    if (post.url.isNotEmpty)
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ClipRRect(
                                  borderRadius: kBorderRadius,
                                  child: Dialog(
                                    child: Container(
                                      child: ClipRRect(
                                        borderRadius: kBorderRadius,
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
                            height: 300.0, // Replace with your desired height
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        DateFormat('HH:mm  dd/MM/yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(post.timestamp),
                          ),
                        ),
                        style: TextStyle(fontSize: 12.0),
                      ),
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
        color: kAccentColor0,
        child: Image.network(
          'https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/foto-fct.jpg',
          width: double.infinity,
          height: coverHeight,
          fit: kIsWeb ? BoxFit.fitWidth : BoxFit.cover,
        ),
      );

  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: kAccentColor0,
        backgroundImage: const NetworkImage(
          'https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/default_profile.jpg',
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
                  backgroundColor: kAccentColor0,
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
                info.username,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kAccentColor0),
              ),
              const SizedBox(height: 8),
              Text(
                info.role,
                style: const TextStyle(fontSize: 20, color: kAccentColor2),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Divider(
                    thickness: 2.0,
                    color: kAccentColor0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: buildButton(text: 'Posts', value: info.nPosts),
                  ),
                  Divider(
                    thickness: 2.0,
                    color: kAccentColor0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child:
                        buildButton(text: 'Following', value: info.nFollowing),
                  ),
                  Divider(
                    thickness: 2.0,
                    color: kAccentColor0,
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
                      widget.onButtonSelected('Info');
                    },
                    child: Text(
                      'Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAccentColor0,
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
                    child: Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAccentColor0,
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

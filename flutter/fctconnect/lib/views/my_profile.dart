import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/profile_info.dart';
import '../models/FeedData.dart';
import '../models/Token.dart';
import '../services/base_client.dart';

class MyProfile extends StatefulWidget {
  final Token token;

  const MyProfile({Key? key, required this.token}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late Token _token;
  final double coverHeight = 200;
  final double profileHeight = 100;
  String selectedButton = 'Info';

  List<FeedData> _posts = [];
  bool _loadingMore = false;
  String _lastDisplayedMessageTimestamp =
      DateTime.now().millisecondsSinceEpoch.toString();
  late ScrollController _scrollController;

  @override
void initState() {
  super.initState();
  _token = widget.token;
  _scrollController = ScrollController();
  _scrollController.addListener(_onScroll);
}


  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
  List<FeedData> posts = await BaseClient().getFeedorPost(
    "/post",
    _token.tokenID,
    _token.username,
    _lastDisplayedMessageTimestamp,
  );

  if (posts.isNotEmpty) {
    setState(() {
      _lastDisplayedMessageTimestamp = posts.last.timestamp;
      _posts.addAll(posts);
    });
  }
}



  Future<ProfileInfo> _loadInfo() async {
    ProfileInfo info = await BaseClient()
        .fetchInfo("/profile", _token.tokenID, _token.username);
    return info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        children: <Widget>[
          buildTop(),
          ContentWidget(
            loadInfo: _loadInfo,
            selectedButton: selectedButton,
            onButtonSelected: selectButton,
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
              'Desenvolvedor profissional de flutter ',
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
              'Ano ',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '3º Ano',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Grupos ',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Eventos ',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    } else {
      List<Widget> userPosts = [];
      for (FeedData post in _posts) {
        userPosts.add(
          Card(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
          ),
        );
      }
      return Column(children: userPosts);
    }
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
          child: buildProfileImage(),
        ),
      ],
    );
  }

  Widget buildButton({
    required String text,
    required int value,
  }) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        //TODO: Add functionality to onPressed
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
}

class ContentWidget extends StatefulWidget {
  final Future<ProfileInfo> Function() loadInfo;
  final String selectedButton;
  final void Function(String) onButtonSelected;

  const ContentWidget({
    Key? key,
    required this.loadInfo,
    required this.selectedButton,
    required this.onButtonSelected,
  }) : super(key: key);

  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  late Future<ProfileInfo> _infoFuture;

  @override
  void initState() {
    super.initState();
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
        //TODO: Add functionality to onPressed
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

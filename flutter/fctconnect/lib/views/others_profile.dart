import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/models/profile_info.dart';
import 'package:responsive_login_ui/models/FeedData.dart';
import 'package:responsive_login_ui/models/Token.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/views/video_player.dart';

import '../services/load_token.dart';

class OtherProfile extends StatefulWidget {
  final String name;

  const OtherProfile({Key? key, required this.name}) : super(key: key);

  @override
  State<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
  late String name;
  String onButtonSelected = 'Info';
  Uint8List? _imageData;
  late Token _token;
  bool _isLoading = false;
  bool _infoIsLoading = true;
  bool _isLoadingToken = true;
  final double coverHeight = 200;
  final double profileHeight = 144;
  List<FeedData> _posts = [];
  bool _loadingMore = false;
  String _lastDisplayedMessageTimestamp =
      DateTime.now().millisecondsSinceEpoch.toString();
  late ScrollController _scrollController;
  late ProfileInfo info;
  late bool _followStatus;
  late bool _disableStatus;
  String followButton = '';

  @override
  void initState() {
    super.initState();
    name = widget.name;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (onButtonSelected != 'Info' &&
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
      name,
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
    ProfileInfo infoAux = await BaseClient()
        .fetchInfo("/profile", _token.tokenID, name, _token.username);
    return infoAux;
  }

  Future<bool> _isFollowing() async {
    bool _followStatuAux = await BaseClient().doesUserFollow(
        "/follow", _token.username, _token.tokenID, widget.name);
    return _followStatuAux;
  }

  Future<bool> _isActivated() async {
    bool _activatedStatus = await BaseClient().isAccountEnabled(
        "/update/state", _token.username, _token.tokenID, widget.name);
    return _activatedStatus;
  }

  Widget _loadProfilePic() {
    if (info == null || info.profilePicUrl.isEmpty) {
      return const CircleAvatar(
        backgroundImage: NetworkImage(
          'https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/default_profile.jpg',
        ),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          info.profilePicUrl,
        ),
      );
    }
  }

  Future<bool> _buttonStatusType() {
    if (_token.role == "SECRETARIA" || _token.role == "SA") {
      return _isActivated();
    } else {
      return _isFollowing();
    }
  }

  void _toggleDisableAccount() {
    if (_disableStatus == true) {
      BaseClient().disableAccount(
          "/update/deactivate", _token.username, _token.tokenID, info.username);
    } else {
      BaseClient().enableAccount(
          "/update/activate", _token.username, _token.tokenID, info.username);
    }
    setState(() {
      _disableStatus = !_disableStatus;
    });
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
    } else if (_infoIsLoading) {
      return FutureBuilder(
          future: Future.wait([_loadInfo(), _buttonStatusType()]),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                const Text('Algo correu mal.');
                return Container(
                  decoration: kGradientDecoration,
                );
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  setState(() {
                    info = snapshot.data![0];

                    if (_token.role == "SECRETARIA" || _token.role == "SA") {
                      _disableStatus = snapshot.data![1];
                    } else {
                      _followStatus = snapshot.data![1];
                    }
                    _infoIsLoading = false;
                  });
                });
                return Container(
                  decoration: kGradientDecorationUp,
                );
              }
            } else {
              return Container(
                  decoration: kGradientDecorationUp,
                  child: const Center(child: CircularProgressIndicator()));
            }
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
              const SizedBox(height: 16),
              buildButtons(context),
              Divider(
                color: kAccentColor0,
                thickness: 2.0,
              ),
              const SizedBox(height: 16),
              if (info.role == "ALUNO") buildInfoAlunoSection(info),
              if (info.role == "PROFESSOR") buildInfoProfessorSection(info),
              if (info.role == "EXTERNO") buildInfoExternoSection(info),
              SizedBox(height: 30),
            ],
          ),
        ),
      );
    }
  }

  Widget buildInfoProfessorSection(ProfileInfo info) {
    if (onButtonSelected == 'Info') {
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
  }

  Widget buildInfoAlunoSection(ProfileInfo info) {
    if (onButtonSelected == 'Info') {
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
      }
      return Column(
        children: _posts.map((post) => buildPostCard(post)).toList(),
      );
    }
  }

  Widget buildInfoExternoSection(ProfileInfo info) {
    if (onButtonSelected == 'Info') {
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
  }

  Widget buildPostCard(FeedData post) {
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
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
                            _loadProfilePic(),
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

  Widget buildTop() {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: Center(
            child: buildCoverImage(),
          ),
        ),
        Positioned(
          top: top,
          child: Center(
            child: buildProfileImage(),
          ),
        ),
      ],
    );
  }

  Widget buildCoverImage() {
    if (info.coverPicUrl.isEmpty) {
      return Container(
        color: kAccentColor0,
        child: Image.network(
          'https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/foto-fct.jpg',
          width: double.infinity,
          height: coverHeight,
          fit: kIsWeb ? BoxFit.fitWidth : BoxFit.cover,
        ),
      );
    } else {
      return Container(
        color: kAccentColor0,
        child: Image.network(
          info.coverPicUrl,
          width: double.infinity,
          height: coverHeight,
          fit: kIsWeb ? BoxFit.fitWidth : BoxFit.cover,
        ),
      );
    }
  }

  Widget buildProfileImage() {
    if (info.profilePicUrl.isEmpty) {
      return CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: kAccentColor0,
        backgroundImage: const NetworkImage(
          'https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/default_profile.jpg',
        ),
      );
    } else {
      return CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: kAccentColor0,
        backgroundImage: NetworkImage(
          info.profilePicUrl,
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_imageData != null) {
      return Container(
        width: 400,
        height: 400,
        child: ClipRRect(
            borderRadius: kBorderRadius,
            child: Image.memory(_imageData!, fit: BoxFit.fill)),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          info.username,
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: kAccentColor0),
        ),
        const SizedBox(height: 8),
        Text(
          info.role,
          style: const TextStyle(fontSize: 20, color: kAccentColor2),
        ),
        const SizedBox(height: 16),
        if (_token.role != "SECRETARIA" && _token.role != "SA")
          Center(
            child: ElevatedButton(
              onPressed: _toggleFollow,
              child: Text(
                _followStatus ? 'Unfollow' : 'Follow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kAccentColor0,
                ),
              ),
            ),
          ),
        if (_token.role == "SECRETARIA" || _token.role == "SA")
          Center(
            child: ElevatedButton(
              onPressed: _toggleDisableAccount,
              child: Text(
                _disableStatus ? 'Desativar Conta' : 'Ativar Conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
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
              child: buildButton(text: 'Following', value: info.nFollowing),
            ),
            Divider(
              thickness: 2.0,
              color: kAccentColor0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: buildButton(text: 'Followers', value: info.nFollowers),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  onButtonSelected = 'Info';
                });
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
                setState(() {
                  onButtonSelected = 'Posts';
                });
                _loadPosts();
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
        SizedBox(height: 16),
      ],
    );
  }

  void _toggleFollow() {
    if (_followStatus == true) {
      BaseClient()
          .unfollow("/follow", _token.username, _token.tokenID, info.username);
      info.nFollowers--;
    } else {
      BaseClient()
          .follow("/follow", _token.username, _token.tokenID, info.username);
      info.nFollowers++;
    }

    setState(() {
      _followStatus = !_followStatus;
    });
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_login_ui/models/profile_info.dart';

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
  final double profileHeight = 144;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
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
        padding: EdgeInsets.zero,
        children: <Widget>[
          buildTop(),
          buildContent(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget buildContent() {
    return FutureBuilder<ProfileInfo>(
      future: _loadInfo(),
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
              const SizedBox(
                height: 8,
              ),
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
              NumbersWidget(info),
              const Divider(),
              const SizedBox(height: 16),
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

  Widget buildBody() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
        ],
      );

  Widget NumbersWidget(ProfileInfo info) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
            child: buildButton(text: 'Following', value: info.nFollowing),
          ),
          Divider(
            thickness: 2.0,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: buildButton(text: 'Followers', value: info.nFollowers),
          ),
        ],
      );

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
        )
      ],
    );
  }

  Widget buildButton({
    required String text,
    required int value,
  }) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        //TODO fazer cenas no on pressed
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                '$value',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(fontSize: 16),
              )
            ]),
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
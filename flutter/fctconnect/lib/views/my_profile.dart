import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_login_ui/models/profile_info.dart';

import 'package:intl/intl.dart';
import 'package:responsive_login_ui/views/video_player.dart';
import '../constants.dart';
import '../models/FeedData.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String onButtonSelected = 'Info';
  Uint8List? _imageData;
  String? _fileName;
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

  @override
  void initState() {
    super.initState();
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
    ProfileInfo infoAux = await BaseClient().fetchInfo(
      "/profile",
      _token.tokenID,
      _token.username,
      _token.username,
    );
    return infoAux;
  }

  Widget _loadProfilePic() {
    if (info == null || info.profilePicUrl.isEmpty) {
      return const CircleAvatar(
        backgroundImage: NetworkImage(
          'https://storage.googleapis.com/fct-connect-estudasses.appspot.com/default_profile.jpg',
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

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = Uint8List.fromList(fileData);
        _fileName = pickedFile.path.split('/').last;
        _isLoading = false;
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

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
          future: _loadInfo(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                const Text('Algo correu mal.');
                return Container();
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  setState(() {
                    info = snapshot.data;
                    _infoIsLoading = false;
                  });
                });
                return Container();
              }
            } else {
              return Container(
                  child: const Center(child: CircularProgressIndicator()));
            }
          });
    } else {
      return Container(
        child: Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            controller: _scrollController,
            children: <Widget>[
              buildTop(),
              const SizedBox(height: 16),
              buildButtons(context),
              Divider(
                thickness: 2.0,
              ),
              const SizedBox(height: 16),
              if (_token.role == "ALUNO")
                buildInfoAlunoSection(info, textTheme),
              if (_token.role == "PROFESSOR")
                buildInfoProfessorSection(info, textTheme),
              if (_token.role == "EXTERNO")
                buildInfoExternoSection(info, textTheme),
              SizedBox(height: 100),
            ],
          ),
        ),
      );
    }
  }

  Widget buildInfoProfessorSection(ProfileInfo info, TextTheme textTheme) {
    if (onButtonSelected == 'Info') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre mim',
              style: textTheme.headline6,
            ),
            Text(
              info.about_me,
              style: textTheme.bodyText1,
            ),
            SizedBox(height: 16),
            Text(
              'Departamento',
              style: textTheme.headline6,
            ),
            Text(
              info.department,
              style: textTheme.bodyText1,
            ),
            SizedBox(height: 16),
            Text(
              'Gabinente',
              style: textTheme.headline6,
            ),
            Text(
              info.office,
              style: textTheme.bodyText1,
            ),
            SizedBox(height: 16),
            Text(
              'Contacto',
              style: textTheme.headline6,
            ),
            Text(
              info.email,
              style: textTheme.bodyText1,
            ),
            SizedBox(height: 16),
            Text(
              'Cidade',
              style: textTheme.headline6,
            ),
            Text(
              info.city,
              style: textTheme.bodyText1,
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    } else {
      return Container(
        constraints: BoxConstraints(maxWidth: 800),
        child: Column(
          children: _posts.map((post) => buildPostCard(post)).toList(),
        ),
      );
    }
  }

  Widget buildInfoAlunoSection(ProfileInfo info, TextTheme textTheme) {
    if (onButtonSelected == 'Info') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre mim',
              style: textTheme.headline6,
            ),
            Text(
              info.about_me,
              style: textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Departamento',
              style: textTheme.headline6,
            ),
            Text(
              info.department,
              style: textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Curso',
              style: textTheme.headline6,
            ),
            Text(
              info.course,
              style: textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Ano',
              style: textTheme.headline6,
            ),
            Text(
              info.year,
              style: textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Cidade',
              style: textTheme.headline6,
            ),
            Text(
              info.city,
              style: textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    } else {
      if (_posts.isEmpty) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Container(
        constraints: BoxConstraints(maxWidth: 800),
        child: Column(
          children: _posts.map((post) => buildPostCard(post)).toList(),
        ),
      );
    }
  }

  Widget buildInfoExternoSection(ProfileInfo info, TextTheme textTheme) {
    if (onButtonSelected == 'Info') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre mim',
              style: textTheme.headline6,
            ),
            Text(
              info.about_me,
              style: textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Cidade',
              style: textTheme.headline6,
            ),
            Text(
              info.city,
              style: textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Propósito',
              style: textTheme.headline6,
            ),
            Text(
              info.purpose,
              style: textTheme.bodyText1!.copyWith(fontSize: 16),
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    } else {
      return Container(
        constraints: BoxConstraints(maxWidth: 800),
        child: Column(
          children: _posts.map((post) => buildPostCard(post)).toList(),
        ),
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
          color: Style.kAccentColor0.withOpacity(0.0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
          child: Container(
            decoration: BoxDecoration(
              color: Style.kAccentColor2.withOpacity(0.1),
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
                            _loadProfilePic(),
                            SizedBox(width: 8.0),
                            Center(
                              heightFactor:
                                  2.4, // You can adjust this to get the alignment you want
                              child: Text(post.user),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              BaseClient().deletePost("/post", post.id,
                                  _token.username, _token.tokenID);
                              setState(() {
                                _posts.remove(post);
                                info.nPosts--;
                              });
                            },
                            icon: Icon(Icons.delete))
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
                                        borderRadius: Style.kBorderRadius,
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
          child: buildCover(),
        ),
        Positioned(
          top: top,
          child: buildProfileAndEditButton(),
        ),
      ],
    );
  }

  Widget buildCover() => Stack(
        children: <Widget>[
          Center(
            child: GestureDetector(
              child: buildCoverImage(),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: Style.kBorderRadius,
                      ),
                      backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mudar a imagem de capa',
                            style: TextStyle(color: Style.kAccentColor0),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    _pickImage();
                                  },
                                  child: Text(
                                    'Carregar imagem',
                                    style:
                                        TextStyle(color: Style.kAccentColor0),
                                  )),
                              if (!kIsWeb) SizedBox(width: 16),
                              if (!kIsWeb)
                                ElevatedButton(
                                    onPressed: () {
                                      _takePicture();
                                    },
                                    child: Text(
                                      'Tirar foto',
                                      style:
                                          TextStyle(color: Style.kAccentColor0),
                                    ))
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildImagePreview(),
                          SizedBox(height: 16),
                          Center(
                            child: Row(
                              children: [
                                saveButton(context, '/coverPic'),
                                SizedBox(
                                  width: 16,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Cancelar',
                                    style:
                                        TextStyle(color: Style.kAccentColor0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );

  Widget buildCoverImage() {
    if (info.coverPicUrl.isEmpty) {
      return Container(
        color: Style.kAccentColor0,
        child: Image.network(
          'https://storage.googleapis.com/fct-connect-estudasses.appspot.com/foto-fct.jpg',
          width: double.infinity,
          height: coverHeight,
          fit: kIsWeb ? BoxFit.fitWidth : BoxFit.cover,
        ),
      );
    } else {
      return Container(
        color: Style.kAccentColor0,
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
        backgroundColor: Style.kAccentColor0,
        backgroundImage: const NetworkImage(
          'https://storage.googleapis.com/fct-connect-estudasses.appspot.com/default_profile.jpg',
        ),
      );
    } else {
      return CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Style.kAccentColor0,
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
            borderRadius: Style.kBorderRadius,
            child: Image.memory(_imageData!, fit: BoxFit.fill)),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildProfileAndEditButton() => Stack(
        children: <Widget>[
          Center(
            child: GestureDetector(
              child: buildProfileImage(),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: Style.kBorderRadius,
                      ),
                      backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mudar Imagem de perfil',
                            style: TextStyle(color: Style.kAccentColor0),
                          ),
                          const SizedBox(height: 15),
                          Column(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    _pickImage();
                                  },
                                  child: Text(
                                    'Carregar imagem',
                                    style:
                                        TextStyle(color: Style.kAccentColor0),
                                  )),
                              if (!kIsWeb) SizedBox(width: 16),
                              if (!kIsWeb)
                                ElevatedButton(
                                    onPressed: () {
                                      _takePicture();
                                    },
                                    child: Text(
                                      'Tirar foto',
                                      style:
                                          TextStyle(color: Style.kAccentColor0),
                                    ))
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildImagePreview(),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Center(
                              child: Row(
                                children: [
                                  saveButton(context, '/profilePic'),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Cancelar',
                                      style:
                                          TextStyle(color: Style.kAccentColor0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );

  ElevatedButton saveButton(BuildContext context, String api) {
    return ElevatedButton(
      onPressed: () {
        if (_imageData == null) {
          // Show a dialog telling the user to select an image
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content:
                    Text("Por favor, selecione uma imagem antes de salvar."),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return FutureBuilder<int>(
                future: BaseClient.updatePic(api, _token.tokenID,
                    _token.username, _fileName, _imageData!),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: Style.kBorderRadius,
                      ),
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text("Uploading..."),
                        ],
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data == 200) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: Style.kBorderRadius,
                        ),
                        backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Imagem mudada com sucesso',
                              style: TextStyle(color: Style.kAccentColor0),
                            ),
                            SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                context.go(Paths.myProfile);
                              },
                              child: Text(
                                'Ok',
                                style: TextStyle(color: Style.kAccentColor0),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: Style.kBorderRadius,
                        ),
                        backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Algo não correu bem!',
                              style: TextStyle(color: Style.kAccentColor0),
                            ),
                            SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Voltar',
                                style: TextStyle(color: Style.kAccentColor0),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    setState(() {
                      _imageData = null;
                    });
                  } else {
                    return Container();
                  }
                },
              );
            },
          );
        }
      },
      child: Text(
        'Guardar',
        style: TextStyle(color: Style.kAccentColor0),
      ),
    );
  }

  Widget buildButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          info.username,
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Style.kAccentColor0),
        ),
        const SizedBox(height: 8),
        Text(
          info.role,
          style: TextStyle(fontSize: 20, color: Style.kAccentColor2),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Divider(
              thickness: 2.0,
              color: Style.kAccentColor0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: buildButton(text: 'Posts', value: info.nPosts),
            ),
            Divider(
              thickness: 2.0,
              color: Style.kAccentColor0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0),
              child: buildButton(text: 'Following', value: info.nFollowing),
            ),
            Divider(
              thickness: 2.0,
              color: Style.kAccentColor0,
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
                  color: Style.kAccentColor0,
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
                  color: Style.kAccentColor0,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
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

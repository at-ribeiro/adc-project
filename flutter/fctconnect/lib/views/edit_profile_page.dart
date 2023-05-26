import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:responsive_login_ui/models/profile_info.dart';

import 'package:intl/intl.dart';
import 'package:responsive_login_ui/models/profile_info.dart';
import '../constants.dart';
import '../models/FeedData.dart';

import '../models/Token.dart';
import '../services/base_client.dart';

class EditProfile extends StatefulWidget {
  final Token token;

  const EditProfile({Key? key, required this.token}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  late Token _token;
  final double coverHeight = 200;
  final double profileHeight = 144;
  late ScrollController _scrollController;
  late Future<ProfileInfo> _profielInfo;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _profielInfo = _loadInfo();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    super.dispose();
  }

  void _onScroll() {}

  Future<ProfileInfo> _loadInfo() async {
    ProfileInfo info = await BaseClient().fetchInfo(
        "/profile", _token.tokenID, _token.username, _token.username);
    fullNameController.text = info.fullname;
    return info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        controller: _scrollController,
        children: <Widget>[
          buildTop(),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            style: kTextFormFieldStyle(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: 'Full Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            controller: fullNameController,
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter username';
              } else {
                return null;
              }
            },
          ),
          SizedBox(height: 16),
          confirmButton(),
        ],
      ),
    );
  }

  ElevatedButton confirmButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(Color.fromARGB(198, 0, 54, 250)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          var _body = {
            "fullname": fullNameController.text,
          };

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return FutureBuilder(
                future: BaseClient().post("/register/", _body),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AlertDialog(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 10),
                          Text('Loading...'),
                        ],
                      ),
                    );
                  } else {
                    String showErrorMessage;
                    if (snapshot.hasError) {
                      switch (snapshot.error) {
                        case '409':
                          showErrorMessage = "username ou email já existem!";
                          break;
                        default:
                          showErrorMessage =
                              "Algo não está certo, tente outra vez!";
                          break;
                      }

                      return AlertDialog(
                        title: Text('Error'),
                        content: Text(showErrorMessage),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    } else {
                      AlertDialog(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 10),
                            Text('A sua informação foi mudada com sucesso!'),
                          ],
                        ),
                      );
                    }
                  }
                  return Container();
                },
              );
            },
          );
        }
      },
      child: const Text('Confirmar'),
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

  Widget buildCoverImage() => GestureDetector(
        onTap: () {
          _pickImage();
        },
        child: Container(
          color: Colors.grey,
          child: Image.network(
            'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/foto-fct.jpg',
            width: double.infinity,
            height: coverHeight,
            fit: kIsWeb ? BoxFit.fitWidth : BoxFit.cover,
          ),
        ),
      );

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      setState(() {
        // _imageData = Uint8List.fromList(fileData);
        // _fileName = pickedFile.path.split('/').last;
      });
    }
  }

  Widget buildProfileImage() => GestureDetector(
        onTap: () {
          _pickImage();
        },
        child: Center(
          child: CircleAvatar(
            radius: profileHeight / 2,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: const NetworkImage(
              'https://storage.googleapis.com/staging.fct-connect-2023.appspot.com/default_profile.jpg',
            ),
          ),
        ),
      );
}

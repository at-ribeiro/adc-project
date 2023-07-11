import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_login_ui/views/video_player.dart';
import 'package:video_player/video_player.dart';
import '../constants.dart';
import '../models/Token.dart';
import '../services/load_token.dart';
import '../services/media_up.dart';
import '../services/post_actions.dart';

class PostCreator extends StatefulWidget {
  const PostCreator({Key? key}) : super(key: key);

  @override
  State<PostCreator> createState() => _PostCreatorState();
}

class _PostCreatorState extends State<PostCreator> {
  MediaUp _mediaUp = MediaUp();

  late Token _token;
  bool _isPosting = false;
  Uint8List? _imageData;
  String? _fileName;
  String? _mediaType;
  String? _type;
  PlatformFile? _videoFile;

  VideoPlayerController? _videoPlayerController;

  bool _isLoadingToken = true;

  final TextEditingController _postTextController = TextEditingController();

  late ScrollController _scrollController;
  GoogleMapController? _mapController;

  Set<Marker> _markers = {};

  @override
  void initState() {
    _scrollController = ScrollController();

    super.initState();
  }

  @override
  void dispose() {
    _postTextController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String mediaType) async {
    FileType fileType;
    if (mediaType == 'image') {
      fileType = FileType.image;
    } else {
      fileType = FileType.video;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      Uint8List imageData = file.bytes!;
      String fileName = file.name;
      String fileExtension = fileName.split('.').last;

      setState(() {
        _imageData = imageData;
        _fileName = fileName;
        _mediaType = fileExtension;
        _type = mediaType;
      });

      if (mediaType == 'video') {
        setState(() {
          _videoFile = file!;
        });
      }
    }
  }

  bool _isImageLoading = false;

  Widget _buildMediaPreview() {
    if (_type == 'image' && _imageData != null) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 500,
            maxWidth: 500,
          ),
          child: ClipRRect(
            borderRadius: Style.kBorderRadius,
            child: Image.memory(_imageData!, fit: BoxFit.contain),
          ),
        ),
      );
    } else if (_type == 'video' && _imageData != null) {
      if (kIsWeb) {
        String base64String = base64Encode(_videoFile!.bytes!);
        return Center(
          child: Container(
            constraints: BoxConstraints(maxHeight: 350),
            child: VideoPlayerWidget(
              videoUrl: 'data:video/mp4;base64,$base64String',
            ),
          ),
        );
      } else {
        return Center(
          child: Container(
            constraints: BoxConstraints(maxHeight: 350),
            child: VideoPlayerWidget(file: File(_videoFile!.path!)),
          ),
        );
      }
    } else if (_isImageLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return SizedBox.shrink();
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
      });
    }
  }

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
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: "O que se passa no campus?",
                        ),
                        controller: _postTextController,
                      ),
                      SizedBox(height: 10),
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Center(child: _buildMediaPreview()),
                      ),
                      if (_isPosting) CircularProgressIndicator()
                    ],
                  ),
                ),
              ),
              _buildButtons(),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () async {
              _pickFile('image');
            },
            child: Icon(Icons.image),
            tooltip: 'Escolher uma imagem',
            // You can replace this with your own text
          ),
          SizedBox(width: 30), // Gives some space between the buttons
          FloatingActionButton(
            onPressed: () async {
              _pickFile('video');
            },
            child: Icon(Icons.videocam),
            tooltip: 'Escolher um video',
            // You can replace this with your own text
          ),
          if (!kIsWeb)
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: FloatingActionButton(
                onPressed: () async {
                  var imageDataMap = await _mediaUp.takePicture();
                  if (imageDataMap.isNotEmpty) {
                    _imageData = imageDataMap['fileData'];
                    _fileName = imageDataMap['fileName'];
                    _mediaType = imageDataMap['mediaType'];
                    _type = imageDataMap['type'];
                  }
                },
                child: Icon(Icons.camera_alt),
                tooltip: 'Tirar uma foto',
                // You can replace this with your own text
              ),
            ),
          SizedBox(width: 30),
          FloatingActionButton(
            onPressed: _isPosting ? null : doPost,
            child: Icon(Icons.publish),
            tooltip: 'Publicar',
          ),
        ],
      ),
    );
  }

  void doPost() async {
    print('doPost called...');
    setState(() {
      _isPosting = true;
    });

    try {
      int result = await _post();
      print('doPost result: $result');
      // rest of your code...
    } catch (e) {
      print('doPost error: $e');
      // rest of your code...
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  // FutureBuilder doPost() {
  //   return FutureBuilder<int>(
  //     future: _post(), // this will hold the future returned by doPost
  //     builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         // return a button that indicates loading while the future is not completed
  //         return ElevatedButton(
  //           onPressed: null,
  //           child: CircularProgressIndicator(),
  //         );
  //       } else if (snapshot.hasError) {
  //         return ErrorDialog('Erro ao publicar evento', 'Ok', context);
  //       } else {
  //         if (snapshot.data == 200) {
  //           context.go(Paths.homePage);
  //           return Container();
  //         } else {
  //           return ErrorDialog('Erro ao publicar evento', 'Ok', context);
  //         }
  //       }
  //     },
  //   );
  // }

  Future<int> _post() async {
    print('Starting post...');
    int result = await PostActions.doPost(_postTextController.text, _imageData,
        _fileName, _mediaType, _type, _token.username, _token.tokenID);

    print('Post completed with result: $result');
    return result;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('Evento'),
          position: position,
          // Set other marker properties as needed
        ),
      };
    });
  }
}

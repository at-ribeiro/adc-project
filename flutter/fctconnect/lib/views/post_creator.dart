import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_login_ui/views/video_player.dart';
import 'package:video_player/video_player.dart';
import '../constants.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/load_token.dart';
import '../services/media_up.dart';
import '../services/post_actions.dart';
import '../widgets/error_dialog.dart';

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

  bool _isLoading = false;

  VideoPlayerController? _videoPlayerController;

  bool _isLoadingToken = true;

  final TextEditingController _postTextController = TextEditingController();
  int _characterCount = 0;
  final int _maxCharacterLimit = 300;

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
        _mediaType =
            fileExtension; // Assign the file extension as the media type
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

  Future<int> _post() async {
    try {
      print('Starting post...');
      int result = await PostActions.doPost(
          _postTextController.text,
          _imageData,
          _fileName,
          _mediaType,
          _type,
          _token.username,
          _token.tokenID);

      print('Post completed with result: $result');
      return result;
    } catch (e) {
      print('Error posting: $e');
      return 500;
    }
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
        WidgetsBinding.instance!.addPostFrameCallback((_) {
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
                        maxLength: _maxCharacterLimit,
                        onChanged: (text) {
                          setState(() {
                            _characterCount = text.length;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "O que se passa no campus?",
                          counterText: '$_characterCount/$_maxCharacterLimit',
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
                    _mediaType = imageDataMap['mediaType'].toString();
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
            onPressed: () async {
              setState(() {
                _isLoading = true; // Show the loading circle
              });

              // Perform your post logic here
              if (_postTextController.text.isNotEmpty) {
                if (_postTextController.text.length > _maxCharacterLimit) {
                  showDialog(
                      context: context,
                      builder: (context) => ErrorDialog(
                          'O texto não pode ter mais de $_maxCharacterLimit caracteres.',
                          'Ok',
                          context));
                  return;
                }
                try {
                  int response = await PostActions.doPost(
                      _postTextController.text,
                      _imageData,
                      _fileName,
                      _mediaType,
                      _type,
                      _token.username,
                      _token.tokenID);

                  if (response == 200 || response == 204) {
                    context.go(Paths.homePage);
                  } else {
                    print('Error creating post.=====' + response.toString());
                    showDialog(
                        context: context,
                        builder: (context) => ErrorDialog(
                            'Erro ao criar evento.', 'Ok', context));
                  }
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          ErrorDialog('Erro ao criar post.', 'Ok', context));
                } finally {
                  setState(() {
                    _isLoading = false; // Hide the loading circle
                  });
                }
              } else {
                showDialog(
                    context: context,
                    builder: (context) => ErrorDialog(
                        'Verifique se escreveu alguma coisa no Post.',
                        'Ok',
                        context));
              }
            },
            child: _isLoading
                ? CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ) // Show the loading circle
                : Icon(Icons.upload),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/views/video_player.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import 'package:video_player/video_player.dart';
import '../constants.dart';
import '../models/Token.dart';
import '../models/event_post_data.dart';
import '../models/paths.dart';
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
      return Container(
        constraints: BoxConstraints(
          maxHeight: 500,
          maxWidth: 500,
        ),
        child: ClipRRect(
            borderRadius: kBorderRadius,
            child: Image.memory(_imageData!, fit: BoxFit.contain)),
      );
    } else if (_type == 'video' && _imageData != null) {
      if (kIsWeb) {
        String base64String = base64Encode(_videoFile!.bytes!);
        return Container(
          constraints: BoxConstraints(maxHeight: 350),
          child: VideoPlayerWidget(
            videoUrl: 'data:video/mp4;base64,$base64String',
          ),
        );
      } else {
        return Container(
          constraints: BoxConstraints(maxHeight: 350),
          child: VideoPlayerWidget(file: File(_videoFile!.path!)),
        );
      }
    } else if (_isImageLoading) {
      return CircularProgressIndicator();
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
      return Container(
        decoration: kGradientDecorationUp,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMediaPreview(),
                  SizedBox(height: 20.0),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: kBorderRadius,
                      border: Border.all(
                        color:
                            kAccentColor1, // Set your desired border color here
                      ),
                      color: kAccentColor0.withOpacity(0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: kBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextFormField(
                          style: TextStyle(
                            color: kAccentColor0,
                          ),
                          maxLines: null, // Allow unlimited lines
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.description, color: kAccentColor1),
                            hintText: 'Descrição',
                            border: InputBorder.none,
                          ),
                          controller: _postTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione uma descrição para o evento';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(height: 20),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          _pickFile('image');
                        },
                        child: const Text('Selecione a Imagem'),
                      ),
                      SizedBox(height: 15.0), // Separator
                      ElevatedButton(
                        onPressed: () async {
                          _pickFile('video');
                        },
                        child: const Text('Selecione o Video'),
                      ),
                      SizedBox(height: 15.0), // Separator
                      if (!kIsWeb)
                        ElevatedButton(
                          onPressed: () async {
                            var imageDataMap = await _mediaUp.takePicture();
                            if (imageDataMap.isNotEmpty) {
                              _imageData = imageDataMap['fileData'];
                              _fileName = imageDataMap['fileName'];
                              _mediaType = imageDataMap['mediaType'];
                              _type = imageDataMap['type'];
                            }
                          },
                          child: const Text('Tire uma Foto'),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isPosting ? null : doPost,
                    child: _isPosting
                        ? CircularProgressIndicator(color: kAccentColor1)
                        : Text('Publicar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
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

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import 'package:responsive_login_ui/widgets/error_dialog.dart';
import '../constants.dart';
import '../models/Token.dart';
import '../models/event_post_data.dart';
import '../models/paths.dart';
import '../services/load_token.dart';

class EventCreator extends StatefulWidget {
  const EventCreator({Key? key}) : super(key: key);

  @override
  State<EventCreator> createState() => _EventCreatorState();
}

class _EventCreatorState extends State<EventCreator> {
  late Token _token;
  Uint8List? _imageData;
  late String _fileName;

  bool _isLoading = false;
  bool _isLoadingToken = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startingDateController = TextEditingController();
  final TextEditingController _endingDateController = TextEditingController();

  late DateTime _startingDate;
  late DateTime _endingDate;

  late ScrollController _scrollController;
  GoogleMapController? _mapController;

  Set<Marker> _markers = {};

  @override
  void initState() {
    _scrollController = ScrollController();
    _startingDate = DateTime.now();
    _endingDate = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startingDateController.dispose();
    _endingDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = Uint8List.fromList(fileData);
        _fileName = pickedFile.path.split('/').last;
      });
    }
  }

  bool _isImageLoading = false;

  Widget _buildImagePreview() {
    if (_imageData != null) {
      return Container(
        width: 440, // Adj ust the width as needed
        height: 300, // Adjust the height as needed
        child: ClipRRect(
            borderRadius: kBorderRadius,
            child: Image.memory(_imageData!, fit: BoxFit.fill)),
      );
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

  Future<void> _showDatePicker(
      BuildContext context, TextEditingController controller) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        controller.text = selectedDate.toString();
        if (controller == _startingDateController) {
          _startingDate = selectedDate;
        } else if (controller == _endingDateController) {
          _endingDate = selectedDate;
        }
      });
    }
  }

  bool _validateDates() {
    if (_startingDateController.text.isEmpty ||
        _endingDateController.text.isEmpty) {
      return false;
    }

    DateFormat format = DateFormat('yyyy-MM-dd – kk:mm');
    DateTime startDate = format.parse(_startingDateController.text);
    DateTime endDate = format.parse(_endingDateController.text);

    // This will check if the end date is later than or equal to the start date
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: kBorderRadius,
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
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.title, color: kAccentColor1),
                            hintText: 'Título do evento',
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: kBorderRadius,
                              borderSide: BorderSide(
                                color:
                                    kAccentColor1, // Set your desired focused color here
                              ),
                            ),
                          ),
                          controller: _titleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione o titulo para o evento';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
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
                          controller: _descriptionController,
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: kBorderRadius,
                      color: kAccentColor0.withOpacity(0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: kBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextField(
                          readOnly: true,
                          controller: _startingDateController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today,
                                color: kAccentColor1),
                            hintText: 'Data de começo',
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: kBorderRadius,
                              borderSide: BorderSide(color: kAccentColor1),
                            ),
                          ),
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (date != null) {
                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                DateTime selectedDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute);
                                _startingDateController.text =
                                    DateFormat('yyyy-MM-dd – kk:mm').format(
                                        selectedDateTime); // You can use any date format you want
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: kBorderRadius,
                      color: kAccentColor0.withOpacity(0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: kBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextField(
                          readOnly: true,
                          controller: _endingDateController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today,
                                color: kAccentColor1),
                            hintText: 'Data de fim',
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: kBorderRadius,
                              borderSide: BorderSide(color: kAccentColor1),
                            ),
                          ),
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (date != null) {
                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                DateTime selectedDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute);
                                _endingDateController.text =
                                    DateFormat('yyyy-MM-dd – kk:mm').format(
                                        selectedDateTime); // You can use any date format you want
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 300,
                    width: 500,
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onTap: _onMapTap,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(38.661022, -9.204441), zoom: 16),
                      markers: _markers,
                    ),
                  ),
                  SizedBox(height: 20),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _pickImage();
                        },

                        child: const Text(
                            'Selecione um icon para Evento'),

                      ),
                      SizedBox(width: 20),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0)),
                      if (!kIsWeb)
                        ElevatedButton(
                          onPressed: () {
                            _takePicture();
                          },
                          child: const Text('Take Photo'),
                        ),
                    ],
                  ),
                  _buildImagePreview(),
                  SizedBox(height: 20),
                  ElevatedButton(
  onPressed: () async {
    if (_validateDates()) {
      if (_fileName.isNotEmpty) {
        if (_markers.isNotEmpty) {
          setState(() {
            _isLoading = true; // Show the loading circle
          });

          EventPostData event = EventPostData(
            creator: _token.username,
            title: _titleController.text,
            imageData: _imageData,
            fileName: _fileName,
            description: _descriptionController.text,
            start: _startingDate.millisecondsSinceEpoch,
            end: _endingDate.millisecondsSinceEpoch,
            lat: _markers.first.position.latitude,
            lng: _markers.first.position.longitude,
          );
          try {
            var response = await BaseClient()
                .createEvent("/events", _token.tokenID, event);

            if (response == 200 || response == 204) {
              context.go(Paths.events);
            } else {
              showDialog(
                  context: context,
                  builder: (context) => ErrorDialog(
                      'Erro ao criar evento.', 'Ok', context));
            }
          } catch (e) {
            showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                    'Erro ao criar evento.', 'Ok', context));
          } finally {
            setState(() {
              _isLoading = false; // Hide the loading circle
            });
          }
        } else {
          showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                  'Verifique se selecionou uma localização para o evento.',
                  'Ok',
                  context));
        }
      } else {
        showDialog(
            context: context,
            builder: (context) => ErrorDialog(
                'Adicione uma imagem ao evento',
                'Ok',
                context));
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => ErrorDialog(
              'Verifique se a data de início é antes da data do fim.',
              'Ok',
              context));
    }
  },
  child: _isLoading
      ? CircularProgressIndicator(color: kAccentColor1,) // Show the loading circle
      : Text('Criar evento'),
),

                ],
              ),
            ),
          ),
        ),
      );
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
}

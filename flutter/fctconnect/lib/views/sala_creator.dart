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
import '../models/sala_post_data.dart';
import '../models/paths.dart';
import '../services/load_token.dart';

class SalaCreator extends StatefulWidget {
  const SalaCreator({Key? key}) : super(key: key);

  @override
  State<SalaCreator> createState() => _SalaCreatorState();
}

class _SalaCreatorState extends State<SalaCreator> {
  late Token _token;
  bool _isLoadingToken = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  late ScrollController _scrollController;
  GoogleMapController? _mapController;

  Set<Marker> _markers = {};

  @override
  void initState() {
    _scrollController = ScrollController();
    //_startingDate = DateTime.now();
    //_endingDate = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    //_endingDateController.dispose();
    super.dispose();
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
                            hintText: 'Nome da sala',
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
                              return 'Indique o nome da sala';
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
                            hintText: 'Edifício',
                            border: InputBorder.none,
                          ),
                          controller: _descriptionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione o edifício da sala';
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
                        child: TextFormField(
                          style: TextStyle(
                            color: kAccentColor0,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.title, color: kAccentColor1),
                            hintText: 'Capacidade da sala',
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: kBorderRadius,
                              borderSide: BorderSide(
                                color:
                                    kAccentColor1, // Set your desired focused color here
                              ),
                            ),
                          ),
                          controller: _capacityController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione a capacidade da sala';
                            } else {
                              return null;
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
                  ElevatedButton(
                    onPressed: () {
                      //if (_validateDates()) {
                        //if (_fileName.isNotEmpty) {
                          if (_markers.isNotEmpty) {
                            SalaPostData sala = SalaPostData(
                              name: _titleController.text,
                              building: _descriptionController.text,
                              lat: _markers.first.position.latitude,
                              lng: _markers.first.position.longitude,
                              capacity: int.parse(_capacityController.text),
                            );
                            var response = BaseClient()
                                .createSala("/rooms", _token.username, _token.tokenID, sala);

                            if (response == 200 || response == 204) {
                              //context.go(Paths.salas);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => ErrorDialog(
                                      'Erro ao criar sala.', 'Ok', context));
                            }
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => ErrorDialog(
                                    'Verifique se selecionou uma localização para a sala.',
                                    'Ok',
                                    context));
                          }
                        //} 
                      },
                    //},
                    child: Text('Criar sala'),
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
          markerId: MarkerId('Sala'),
          position: position,
          // Set other marker properties as needed
        ),
      };
    });
  }
}
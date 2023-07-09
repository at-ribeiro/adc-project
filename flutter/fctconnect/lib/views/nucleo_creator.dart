import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_login_ui/models/nucleos_data.dart';

import '../constants.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import '../widgets/circular_indicator.dart';
import '../widgets/error_dialog.dart';

class NuceloCreator extends StatefulWidget {
  const NuceloCreator({super.key});

  @override
  State<NuceloCreator> createState() => _NuceloCreatorState();
}

class _NuceloCreatorState extends State<NuceloCreator> {
  TextEditingController nameController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController foundationController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController adminController = TextEditingController();
  TextEditingController websiteController = TextEditingController();

  Uint8List? _imageData;
  late String _fileName;

  Token? _token;

  bool _isLoadingToken = true;
  bool _isLoading = false;
  bool isExpandedType = false;

  List<String> types = [
    'Cultural',
    'Academico',
    'Recreativo',
    'Associação-Parceira'
  ];

  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    nameController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
    foundationController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    emailController.dispose();
    typeController.dispose();
    adminController.dispose();
    websiteController.dispose();

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
            borderRadius: Style.kBorderRadius,
            child: Image.memory(_imageData!, fit: BoxFit.fill)),
      );
    } else if (_isImageLoading) {
      return CircularProgressIndicatorCustom();
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
          });
        });
      });
    } else {
      return Container(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor,
            foregroundColor:
                Theme.of(context).floatingActionButtonTheme.foregroundColor,
            child: _isLoading
                ? CircularProgressIndicator() // Show the loading circle
                : Icon(
                    Icons.add,
                  ),
            onPressed: () async {
              if (_token == null) {
                setState(() {
                  _isLoadingToken = true;
                });
              }
              if (_imageData == null || _fileName.isEmpty) {
                showDialog(
                    context: context,
                    builder: (context) =>
                        ErrorDialog('Imagem não selecionada', 'Ok', context));
              } else {
                setState(() {
                  _isLoading = true; // Show the loading circle
                });

                NucleosData nucleo = NucleosData(
                  admin: adminController.text,
                  name: nameController.text,
                  type: typeController.text,
                  email: emailController.text,
                  subtitle: subtitleController.text,
                  description: descriptionController.text,
                  foundation: foundationController.text,
                  facebook: facebookController.text,
                  instagram: instagramController.text,
                  website: websiteController.text,
                  imageData: _imageData,
                  fileName: _fileName,
                );

                var response = await BaseClient().createNucleo(
                    '/nucleos', _token!.tokenID, _token!.username, nucleo);

                if (response == 200 || response == 204) {
                  context.go(Paths.nucleos);
                } else {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          ErrorDialog('Erro ao criar evento.', 'Ok', context));
                }
                setState(() {
                  _isLoading = false; // Hide the loading circle
                });
              }
              setState(() {
                _isLoading = false; // Hide the loading circle
              });
            },
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.group,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'Nome do Núcleo',
                                ),
                                controller: nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione um nome para o núcleo';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'Nome do Presidente',
                                  border: InputBorder.none,
                                ),
                                controller: adminController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione um nome para o presidente do núcleo';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'Email do núcleo',
                                  border: InputBorder.none,
                                ),
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione um email para o núcleo';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.title,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'Subtitulo do núcleo',
                                  border: InputBorder.none,
                                ),
                                controller: subtitleController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione um nome para o presidente do núcleo';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                maxLines: null, // Allow unlimited lines
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.description,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'Descrição',
                                  border: InputBorder.none,
                                ),
                                controller: descriptionController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione uma descrição para o núcleo';
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
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.title,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'Data de Criação',
                                  border: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(),
                                ),
                                controller: foundationController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione uma data de criação para o núcleo';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Theme(
                                data: ThemeData(
                                  canvasColor: Style.kAccentColor2,
                                  popupMenuTheme: PopupMenuThemeData(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: Style.kBorderRadius,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  child: DropdownButtonHideUnderline(
                                    child: ExpansionTile(
                                      initiallyExpanded: isExpandedType,
                                      title: typeController.text.isEmpty
                                          ? Text(
                                              "Tipo de Núcleo",
                                            )
                                          : Text(
                                              typeController.text,
                                            ),
                                      leading: Icon(Icons.style,
                                          color: Theme.of(context)
                                              .inputDecorationTheme
                                              .prefixStyle!
                                              .color),
                                      children:
                                          types.map<Widget>((String value) {
                                        return ListTile(
                                          title: Text(
                                            value,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              typeController.text = value;
                                              isExpandedType = false;
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(FontAwesomeIcons.instagram,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'Instagram',
                                  border: InputBorder.none,
                                ),
                                controller: instagramController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    instagramController.text = '';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(FontAwesomeIcons.facebook,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'Facebook',
                                  border: InputBorder.none,
                                ),
                                controller: facebookController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    facebookController.text = '';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: Style.kBorderRadius,
                            color: Style.kAccentColor2.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: Style.kBorderRadius,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.web,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .prefixStyle!
                                          .color),
                                  hintText: 'WebSite',
                                  border: InputBorder.none,
                                ),
                                controller: websiteController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    websiteController.text = '';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _pickImage();
                              },
                              child:
                                  const Text('Selecione um icon para Evento'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildImagePreview(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/models/location_get_data.dart';
import 'package:responsive_login_ui/models/route_get_data.dart';
import 'package:responsive_login_ui/services/base_client.dart';
import '../constants.dart';
import '../models/Token.dart';
import '../models/paths.dart';
import '../services/load_token.dart';

class RouteCreator extends StatefulWidget {
  const RouteCreator({Key? key}) : super(key: key);

  @override
  State<RouteCreator> createState() => _RouteCreatorState();
}

class _RouteCreatorState extends State<RouteCreator> {
  late Token _token;

  bool _isLoadingToken = true;
  List<LocationGetData> locationsListRestauracao = [];
  List<LocationGetData> locationsListEdificios = [];
  List<LocationGetData> locationsListTransporte = [];
  List<LocationGetData> locationsListEventos = [];

  List<String> locationsToAdd = [];
  TextEditingController routeNameController = TextEditingController();

  bool _isFirstLoadRest = true;
  bool _isFirstLoadEd = true;
  bool _isFirstLoadEv = true;
  bool _isFirstLoadTrans = true;

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    routeNameController.dispose();
    super.dispose();
  }

  void addToSelectedLocations(String name) {
    setState(() {
      locationsToAdd.add(name);
    });
  }

  void removeFromLocations(String name) {
    setState(() {
      locationsToAdd.remove(name);
    });
  }

  Future<void> _loadLocations(String type) async {
    List<LocationGetData> locations = await BaseClient().getLocations(
      "/location",
      _token.tokenID,
      _token.username,
      type,
    );

    if (locations.isNotEmpty) {
      setState(() {
        if (type == "RESTAURACAO") {
          locationsListRestauracao = locations;
        } else if (type == "EDIFICIO") {
          locationsListEdificios = locations;
        } else if (type == "TRANSPORTE") {
          locationsListTransporte = locations;
        } else if (type == "EVENTO") {
          locationsListEventos = locations;
        }
      });
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
        decoration: kGradientDecorationUp,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            controller: _scrollController, // Use the scroll controller
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
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
                            hintText: 'Título do Percurso',
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: kBorderRadius,
                              borderSide: BorderSide(
                                color: kAccentColor1,
                                // Set your desired focused color here
                              ),
                            ),
                          ),
                          controller: routeNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione o titulo para o percurso';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ExpansionTile(
                  title: Text('RESTAURAÇÃO'),
                  onExpansionChanged: (expanded) {
                    if (expanded && _isFirstLoadRest) {
                      _isFirstLoadRest = false;
                      _loadLocations("RESTAURACAO");
                    }
                  },
                  children: [
                    if (_isFirstLoadRest)
                      CircularProgressIndicator()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: locationsListRestauracao.length,
                        itemBuilder: (context, index) {
                          LocationGetData locationData =
                              locationsListRestauracao[index];
                          bool isSelected =
                              locationsToAdd.contains(locationData.name);
                          return ListTile(
                            title: Text(locationData.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Localização: ${locationData.latitude}, ${locationData.longitude}',
                                ),
                                Text('Tipo de localização: Restauração'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  removeFromLocations(locationData.name);
                                } else {
                                  addToSelectedLocations(locationData.name);
                                }
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 10.0),
                ExpansionTile(
                  title: Text('EDIFÍCIOS'),
                  onExpansionChanged: (expanded) {
                    if (expanded && _isFirstLoadEd) {
                      _isFirstLoadEd = false;
                      _loadLocations("EDIFICIO");
                    }
                  },
                  children: [
                    if (_isFirstLoadEd)
                      CircularProgressIndicator()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: locationsListEdificios.length,
                        itemBuilder: (context, index) {
                          LocationGetData locationData =
                              locationsListEdificios[index];
                          bool isSelected =
                              locationsToAdd.contains(locationData.name);
                          return ListTile(
                            title: Text(locationData.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Localização: ${locationData.latitude}, ${locationData.longitude}',
                                ),
                                Text('Tipo de localização: Edifício'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  removeFromLocations(locationData.name);
                                } else {
                                  addToSelectedLocations(locationData.name);
                                }
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 10.0),
                ExpansionTile(
                  title: Text('TRANSPORTES'),
                  onExpansionChanged: (expanded) {
                    if (expanded && _isFirstLoadTrans) {
                      _isFirstLoadTrans = false;
                      _loadLocations("TRANSPORTE");
                    }
                  },
                  children: [
                    if (_isFirstLoadTrans)
                      CircularProgressIndicator()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: locationsListTransporte.length,
                        itemBuilder: (context, index) {
                          LocationGetData locationData =
                              locationsListTransporte[index];
                          bool isSelected =
                              locationsToAdd.contains(locationData.name);
                          return ListTile(
                            title: Text(locationData.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Localização: ${locationData.latitude}, ${locationData.longitude}',
                                ),
                                Text('Tipo de localização: Transporte'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  removeFromLocations(locationData.name);
                                } else {
                                  addToSelectedLocations(locationData.name);
                                }
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 10.0),
                ExpansionTile(
                  title: Text('EVENTOS'),
                  onExpansionChanged: (expanded) {
                    if (expanded && _isFirstLoadEv) {
                      _isFirstLoadEv = false;
                      _loadLocations("EVENTO");
                    }
                  },
                  children: [
                    if (_isFirstLoadEv)
                      CircularProgressIndicator()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: locationsListEventos.length,
                        itemBuilder: (context, index) {
                          LocationGetData locationData =
                              locationsListEventos[index];
                          bool isSelected =
                              locationsToAdd.contains(locationData.name);
                          return ListTile(
                            title: Text(locationData.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Localização: ${locationData.latitude}, ${locationData.longitude}',
                                ),
                                Text('Tipo de localização: Evento'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  removeFromLocations(locationData.name);
                                } else {
                                  addToSelectedLocations(locationData.name);
                                }
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (locationsToAdd.isNotEmpty &&
                          routeNameController.text.isNotEmpty) {
                            RouteGetData route = RouteGetData(
                              creator: _token.username,
                              name: routeNameController.text,
                              locations: locationsToAdd,
                              participants: [_token.username],
                            );
                          
                        setState(() {
                          locationsToAdd.clear();
                          routeNameController.clear();
                        });
                      }
                    },
                    child: Text('Criar Percurso'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

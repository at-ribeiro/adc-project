import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_login_ui/models/location_get_data.dart';
import 'package:responsive_login_ui/models/route_post_data.dart';
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
  List<int> locationsToAddDuration = [];
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

  int getDurationInMinutes(String duration) {
    int durationMin = 0;
    if (duration == "15 min") {
      durationMin = 15;
    } else if (duration == "30 min") {
      durationMin = 30;
    } else if (duration == "1 hora") {
      durationMin = 60;
    } else if (duration == "2 hora") {
      durationMin = 120;
    } else if (duration == "3 hora") {
      durationMin = 180;
    }
    return durationMin;
  }

  void addToSelectedLocations(String name, String duration) {
    setState(() {
      locationsToAdd.add(name);
      locationsToAddDuration.add(getDurationInMinutes(duration));
    });
  }

  void removeFromLocations(String name) {
    setState(() {
      final index = locationsToAdd.indexOf(name);
      if (index != -1) {
        locationsToAdd.removeAt(index);
        locationsToAddDuration.removeAt(index);
      }
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
            controller: _scrollController,
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
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Localização: ${locationData.latitude}, ${locationData.longitude}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tipo de localização: ${locationData.type}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Duração:',
                                          style: TextStyle(fontSize: 16)),
                                      DropdownButton<String>(
                                        value: locationData.duration,
                                        items: <String>[
                                          '0 min',
                                          '15 min',
                                          '30 min',
                                          '1 hora',
                                          '2 hora',
                                          '3 hora'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            locationData.duration = newValue!;
                                            if (locationsToAdd.indexOf(locationData.name) != -1) {
                                              locationsToAddDuration[locationsToAdd.indexOf(locationData.name)] = getDurationInMinutes(locationData.duration);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                  addToSelectedLocations(
                                    locationData.name,
                                    locationData
                                        .duration, 
                                  );
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
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Localização: ${locationData.latitude}, ${locationData.longitude}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tipo de localização: ${locationData.type}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Duração:',
                                          style: TextStyle(fontSize: 16)),
                                      DropdownButton<String>(
                                        value: locationData.duration,
                                        items: <String>[
                                          '0 min',
                                          '15 min',
                                          '30 min',
                                          '1 hora',
                                          '2 hora',
                                          '3 hora'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            locationData.duration = newValue!;
                                            if (locationsToAdd.indexOf(locationData.name) != -1) {
                                              locationsToAddDuration[locationsToAdd.indexOf(locationData.name)] = getDurationInMinutes(locationData.duration);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                  addToSelectedLocations(
                                    locationData.name,
                                    locationData
                                        .duration, 
                                  );
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
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Localização: ${locationData.latitude}, ${locationData.longitude}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tipo de localização: ${locationData.type}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Duração:',
                                          style: TextStyle(fontSize: 16)),
                                      DropdownButton<String>(
                                        value: locationData.duration,
                                        items: <String>[
                                          '0 min',
                                          '15 min',
                                          '30 min',
                                          '1 hora',
                                          '2 hora',
                                          '3 hora'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            locationData.duration = newValue!;
                                            if (locationsToAdd.indexOf(locationData.name) != -1) {
                                              locationsToAddDuration[locationsToAdd.indexOf(locationData.name)] = getDurationInMinutes(locationData.duration);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                  addToSelectedLocations(
                                    locationData.name,
                                    locationData
                                        .duration, 
                                  );
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
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Localização: ${locationData.latitude}, ${locationData.longitude}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tipo de localização: ${locationData.type}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Duração:',
                                          style: TextStyle(fontSize: 16)),
                                      DropdownButton<String>(
                                        value: locationData.duration,
                                        items: <String>[
                                          '0 min',
                                          '15 min',
                                          '30 min',
                                          '1 hora',
                                          '2 hora',
                                          '3 hora'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            locationData.duration = newValue!;
                                            if (locationsToAdd.indexOf(locationData.name) != -1) {
                                              locationsToAddDuration[locationsToAdd.indexOf(locationData.name)] = getDurationInMinutes(locationData.duration);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                  addToSelectedLocations(
                                    locationData.name,
                                    locationData
                                        .duration, 
                                  );
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
                        RoutePostData route = RoutePostData(
                          creator: _token.username,
                          name: routeNameController.text,
                          locations: locationsToAdd.toList(),
                          durations: locationsToAddDuration.toList(),
                          participants: [_token.username],
                        );

                        setState(() {
                          locationsToAdd.clear();
                          locationsToAddDuration.clear();
                          routeNameController.clear();
                          BaseClient().createRoute(
                              "/route", _token.username, _token.tokenID, route);
                          context.go(Paths.routes);
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

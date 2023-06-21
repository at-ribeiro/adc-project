import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:responsive_login_ui/views/directions_repository.dart';

import '../models/directions_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<CameraPosition> _initialCameraPositionFuture;
  GoogleMapController? _mapController;
  late Marker originMarker;
  late double lat;
  late double long;
  CameraPosition? _initialCameraPosition;
  String showCaminhoButton = '';

  Directions? _info;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initialCameraPositionFuture = _getInitialCameraPosition();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<CameraPosition> _getInitialCameraPosition() async {
    Position position = await _getCurrentLocation();
    lat = position.latitude;
    long = position.longitude;

    originMarker = Marker(
      markerId: MarkerId('origem'),
      position: LatLng(lat, long),
      infoWindow: InfoWindow(title: 'Origem'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    _markers.add(originMarker);

    addPublicTransportationMarkers();

    addRestaurantMarkers();

    addBuildingMarkers();

    return CameraPosition(
      target: LatLng(lat, long),
      zoom: 16,
    );
  }

  void addBuildingMarkers() {
    Marker edificio3 = Marker(
      markerId: MarkerId('edificio3'),
      position: LatLng(38.663162, -9.207244),
      infoWindow: InfoWindow(title: 'Edifício III'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio3';
        });
      },
    );
    _markers.add(edificio3);

    Marker edificio4 = Marker(
      markerId: MarkerId('edificio4'),
      position: LatLng(38.662877, -9.207251),
      infoWindow: InfoWindow(title: 'Edifício IV'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio4';
        });
      },
    );
    _markers.add(edificio4);
    
    Marker edificio5 = Marker(
      markerId: MarkerId('edificio5'),
      position: LatLng(38.663340, -9206874),
      infoWindow: InfoWindow(title: 'Edifício V'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio5';
        });
      },
    );
    _markers.add(edificio5);
    
    Marker edificio11 = Marker(
      markerId: MarkerId('edificio11'),
      position: LatLng(38.662927, -9.206631),
      infoWindow: InfoWindow(title: 'Edifício XI'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio11';
        });
      },
    );
    _markers.add(edificio11);
    
    Marker departamental = Marker(
      markerId: MarkerId('departamental'),
      position: LatLng(38.662569, -9.207492),
      infoWindow: InfoWindow(title: 'Departamental'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'departamental';
        });
      },
    );
    _markers.add(departamental);
    
    Marker edificio9 = Marker(
      markerId: MarkerId('edificio9'),
      position: LatLng(38.660202, -9.207044),
      infoWindow: InfoWindow(title: 'Edifício IX'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio9';
        });
      },
    );
    _markers.add(edificio9);
    
    Marker edificio8 = Marker(
      markerId: MarkerId('edificio8'),
      position: LatLng(38.660186, -9.206754),
      infoWindow: InfoWindow(title: 'Edifício VIII'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio8';
        });
      },
    );
    _markers.add(edificio8);
    
    Marker edificio7 = Marker(
      markerId: MarkerId('edificio7'),
      position: LatLng(38.660769, -9.205788),
      infoWindow: InfoWindow(title: 'Edifício VII'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio7';
        });
      },
    );
    _markers.add(edificio7);
    
    Marker edificio10 = Marker(
      markerId: MarkerId('edificio10'),
      position: LatLng(38.660782, -9.204847),
      infoWindow: InfoWindow(title: 'Edifício X'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio10';
        });
      },
    );
    _markers.add(edificio10);
    
    Marker edificio6 = Marker(
      markerId: MarkerId('edificio6'),
      position: LatLng(38.660672, -9.203072),
      infoWindow: InfoWindow(title: 'Edifício VI'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio6';
        });
      },
    );
    _markers.add(edificio6);
    
    Marker edificio2 = Marker(
      markerId: MarkerId('edificio2'),
      position: LatLng(38.660816, -9.203644),
      infoWindow: InfoWindow(title: 'Edifício II'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'edificio2';
        });
      },
    );
    _markers.add(edificio2);
    
    Marker biblioteca = Marker(
      markerId: MarkerId('biblioteca'),
      position: LatLng(38.662580, -9.205425),
      infoWindow: InfoWindow(title: 'Biblioteca'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'biblioteca';
        });
      },
    );
    _markers.add(biblioteca);
    
    Marker uninova1 = Marker(
      markerId: MarkerId('uninova1'),
      position: LatLng(38.660046, -9.203937),
      infoWindow: InfoWindow(title: 'Uninova I'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'uninova1';
        });
      },
    );
    _markers.add(uninova1);
    
    Marker uninova2 = Marker(
      markerId: MarkerId('uninova2'),
      position: LatLng(38.659930, -9.203788),
      infoWindow: InfoWindow(title: 'Uninova II'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        setState(() {
          showCaminhoButton = 'uninova2';
        });
      },
    );
    _markers.add(uninova2);
    
  }

  void addPublicTransportationMarkers() {
    Marker metro = Marker(
      markerId: MarkerId('metro'),
      position: LatLng(38.663542, -9.207507),
      infoWindow: InfoWindow(title: 'Metro'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () {
        setState(() {
          showCaminhoButton = 'metro';
        });
      },
    );
    _markers.add(metro);

    Marker autocarro = Marker(
      markerId: MarkerId('autocarro'),
      position: LatLng(38.660485, -9.202677),
      infoWindow: InfoWindow(title: 'Autocarro'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () {
        setState(() {
          showCaminhoButton = 'autocarro';
        });
      },
    );
    _markers.add(autocarro);
  }

  void addRestaurantMarkers() {
    Marker barTia = Marker(
      markerId: MarkerId('barTia'),
      position: LatLng(38.661328, -9.204926),
      infoWindow: InfoWindow(title: 'Bar Tia'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        setState(() {
          showCaminhoButton = 'barTia';
        });
      },
    );
    _markers.add(barTia);

    Marker tantoFaz = Marker(
      markerId: MarkerId('tantoFaz'),
      position: LatLng(38.661559, -9.206795),
      infoWindow: InfoWindow(title: 'Tanto Faz'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        setState(() {
          showCaminhoButton = 'tantoFaz';
        });
      },
    );
    _markers.add(tantoFaz);

    Marker cantina = Marker(
      markerId: MarkerId('cantina'),
      position: LatLng(38.661557, -9.204736),
      infoWindow: InfoWindow(title: 'Cantina'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        setState(() {
          showCaminhoButton = 'cantina';
        });
      },
    );
    _markers.add(cantina);

    Marker casaDoPessoal = Marker(
      markerId: MarkerId('casaDoPessoal'),
      position: LatLng(38.661733, -9.205454),
      infoWindow: InfoWindow(title: 'Casa do Pessoal'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        setState(() {
          showCaminhoButton = 'casaDoPessoal';
        });
      },
    );
    _markers.add(casaDoPessoal);

    Marker mininova = Marker(
      markerId: MarkerId('mininova'),
      position: LatLng(38.661340, -9.205305),
      infoWindow: InfoWindow(title: 'Mininova'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        setState(() {
          showCaminhoButton = 'mininova';
        });
      },
    );
    _markers.add(mininova);

    Marker mySpot = Marker(
      markerId: MarkerId('mySpot'),
      position: LatLng(38.660128, -9205537),
      infoWindow: InfoWindow(title: 'MySpot'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        setState(() {
          showCaminhoButton = 'mySpot';
        });
      },
    );
    _markers.add(mySpot);

    Marker espacoSolucao = Marker(
      markerId: MarkerId('espacoSolucao'),
      position: LatLng(38.661417, -9.205109),
      infoWindow: InfoWindow(title: 'Espaço Solução'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        setState(() {
          showCaminhoButton = 'espacoSolucao';
        });
      },
    );
    _markers.add(espacoSolucao);

    Marker barCampus = Marker(
      markerId: MarkerId('barCampus'),
      position: LatLng(38.662621, -9.205175),
      infoWindow: InfoWindow(title: 'Bar Campus'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        setState(() {
          showCaminhoButton = 'barCampus';
        });
      },
    );
    _markers.add(barCampus);
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _navigateToCaminho(Marker marker) async {
    final directions = await DirectionsRepository().getDirections(
        origin: originMarker.position, destination: marker.position);
    setState(() {
      _info = directions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mapa'),
          actions: [
            if (showCaminhoButton != '')
              IconButton(
                icon: Icon(Icons.directions),
                onPressed: () {
                  _navigateToCaminho(_markers.firstWhere(
                      (marker) => marker.mapsId.value == showCaminhoButton));
                },
              ),
          ],
        ),
        body: FutureBuilder<CameraPosition>(
          future: _initialCameraPositionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              _initialCameraPosition = snapshot.data!;
              return Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: _initialCameraPosition!,
                    markers: _markers,
                    myLocationEnabled: true,
                    polylines: {
                      if (_info != null)
                        Polyline(
                          polylineId: const PolylineId('overview_polyline'),
                          color: Colors.blue,
                          width: 5,
                          points: _info!.polylinePoints
                              .map((e) => LatLng(e.latitude, e.longitude))
                              .toList(),
                        ),
                    },
                  ),
                  Positioned(
                    bottom: 100.0,
                    right: 10.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: Colors.blue,
                                size: 24.0,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'Edifícios',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),

                          Row(
                            children: [
                              Icon(
                                Icons.bus_alert_outlined,
                                color: Color.fromARGB(255, 13, 208, 19),
                                size: 24.0,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'Transporte',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: Color.fromARGB(255, 241, 115, 6),
                                size: 24.0,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'Restauração',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          // Add more rows as needed
                        ],
                      ),
                    ),
                  ),
                  if (_info != null)
                    Positioned(
                      top: 20.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6.0,
                              )
                            ]),
                        child: Text(
                            '${_info!.totalDistance}, ${_info!.totalDuration}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                ],
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          onPressed: () {
            if (_initialCameraPosition != null) {
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(_initialCameraPosition!),
              );
            }
          },
          child: const Icon(Icons.center_focus_strong),
        ),
      ),
    );
  }
}

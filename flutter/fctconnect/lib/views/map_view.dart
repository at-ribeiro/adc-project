import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/models/location_get_data.dart';
import 'package:responsive_login_ui/views/directions_repository.dart';

import '../models/Token.dart';
import '../models/directions_model.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';

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
  ValueNotifier<String> showCaminhoButton = ValueNotifier<String>('');

  late Token _token;
  bool isMapLoading = true;
  bool _isLoadingToken = true;

  Directions? _info;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<CameraPosition> _getInitialCameraPosition(
      List<LocationGetData> restauracao, edificios, transportes) async {
    Position position = await _getCurrentLocation();
    lat = position.latitude;
    long = position.longitude;

    originMarker = Marker(
      markerId: MarkerId('origem'),
      position: LatLng(lat, long),
      infoWindow: InfoWindow(title: 'Origem'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    for (LocationGetData locationR in restauracao) {
      Marker l = Marker(
        markerId: MarkerId(locationR.name),
        position: LatLng(locationR.latitude, locationR.longitude),
        infoWindow: InfoWindow(title: locationR.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () {
          setState(() {
            showCaminhoButton.value = locationR.name;
          });
        },
      );
      _markers.add(l);
    }

    for (LocationGetData locationE in edificios) {
      Marker l = Marker(
        markerId: MarkerId(locationE.name),
        position: LatLng(locationE.latitude, locationE.longitude),
        infoWindow: InfoWindow(title: locationE.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: () {
          setState(() {
            showCaminhoButton.value = locationE.name;
          });
        },
      );
      _markers.add(l);
    }

    for (LocationGetData locationT in transportes) {
      Marker l = Marker(
      markerId: MarkerId(locationT.name),
      position: LatLng(locationT.latitude, locationT.longitude),
      infoWindow: InfoWindow(title: locationT.name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () {
        setState(() {
          showCaminhoButton.value = locationT.name;
        });
      },
    );
    _markers.add(l);
    }
    _markers.add(originMarker);

    return CameraPosition(
      target: LatLng(lat, long),
      zoom: 16,
    );
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
    if (_isLoadingToken) {
      return Container(
        decoration: kGradientDecorationUp,
        child: TokenGetterWidget(onTokenLoaded: (Token token) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _token = token;
              _isLoadingToken = false;
            });
          });
        }),
      );
    } else if (isMapLoading) {
      return loadMap();
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
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
                    if (!kIsWeb)
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
          floatingActionButton: Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 16.0),
                  child: FloatingActionButton(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      if (_initialCameraPosition != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                              _initialCameraPosition!),
                        );
                      }
                    },
                    child: const Icon(Icons.center_focus_strong),
                  ),
                ),
                if(!kIsWeb) ValueListenableBuilder<String>(
                  valueListenable: showCaminhoButton,
                  builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: AnimatedOpacity(
                        opacity: value.isNotEmpty ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: FloatingActionButton(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            child: Icon(Icons.directions),
                            onPressed: () {
                              _navigateToCaminho(_markers.firstWhere((marker) =>
                                  marker.markerId.value ==
                                  showCaminhoButton.value));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget loadMap() {
    return FutureBuilder(
      future: Future.wait([
        _loadMap("RESTAURACAO"),
        _loadMap("EDIFICIO"),
        _loadMap("TRANSPORTE")
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              setState(() {
                _initialCameraPositionFuture = _getInitialCameraPosition(
                    snapshot.data![0], snapshot.data![1], snapshot.data![2]);

                isMapLoading = false;
              });
            });
            return build(context);
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<List<LocationGetData>> _loadMap(String type) async {
    try {
      List<LocationGetData> locations = await BaseClient()
          .getLocations("/location", _token.tokenID, _token.username, type);
      return locations;
    } catch (e) {
      return Future.error(e);
    }
  }
}

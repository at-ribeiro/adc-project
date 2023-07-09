import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:responsive_login_ui/models/route_get_data.dart';

import '../constants.dart';
import '../models/Token.dart';
import '../models/directions_model.dart';
import '../models/location_get_data.dart';
import '../models/paths.dart';
import '../models/route_post_data.dart';
import '../services/base_client.dart';
import '../services/load_token.dart';
import 'directions_repository.dart';

class RouteMapScreen extends StatefulWidget {
  final String routeUser;
  final String routeID;

  const RouteMapScreen({required this.routeID, required this.routeUser});

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late GoogleMapController mapController;
  late Token _token;
  bool _isLoadingToken = true;
  bool isRouteLoading = true;
  late RouteGetData _route;

  List<Marker> markers = [];
  Set<Polyline> polylines = {};
  DirectionsRepository directionsRepository = DirectionsRepository();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {});
  }

  Future<void> setOptimizedRoute() async {
    if (markers.length < 2) return;

    final origin = markers.first.position;
    final destination = markers.last.position;
    final waypoints = markers
        .sublist(1, markers.length - 1)
        .map((marker) => marker.position)
        .toList();

    try {
      final directions = await directionsRepository.getOptimizedDirections(
        origin: origin,
        destination: destination,
        waypoints: waypoints,
      );

      final polyline = Polyline(
        polylineId: PolylineId('optimized_route'),
        color: Colors.blue,
        points: directions.polylinePoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
        width: 5,
      );

      setState(() {
        polylines.clear();
        polylines.add(polyline);
      });
    } catch (e) {
      print('Error getting optimized directions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return TokenGetterWidget(onTokenLoaded: (Token token) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _token = token;
            _isLoadingToken = false;
          });
        });
      });
    } else if (isRouteLoading) {
      return loadRoute();
    } else {
      return Scaffold(
        body: GoogleMap(
          myLocationEnabled: true,
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(38.661029, -9.204454),
            zoom: 17,
          ),
          markers: Set<Marker>.from(markers),
          polylines: polylines,
        ),
        floatingActionButton: kIsWeb ? null : Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 25.0, bottom: 16.0),
                child: FloatingActionButton(
                  backgroundColor: Style.kPrimaryColor,
                  foregroundColor: Colors.white,
                  onPressed: setOptimizedRoute,
                  child: Icon(Icons.directions),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget loadRoute() {
    return FutureBuilder(
      future: _loadRoute(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            String errorText = snapshot.error.toString();
            if (errorText.contains('404'))
              errorText = 'Percurso não encontrado';
            else if (errorText.contains('401'))
              errorText = 'Não tem permissões para aceder a este percurso';
            else if (errorText.contains('500'))
              errorText = 'Erro interno do servidor';
            else
              errorText = 'Algo não correu bem';

            return Container(
              
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: Style.kBorderRadius,
                ),
                backgroundColor: Style.kAccentColor2.withOpacity(0.3),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorText,
                      style: const TextStyle(color: kAccentColor0),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        context.go(Paths.routes);
                      },
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              setState(() {
                _route = snapshot.data;
                isRouteLoading = false;
                int i = 1;
                for (LocationGetData location in _route.locations) {
                  markers.add(Marker(
                    markerId: MarkerId(location.name),
                    position: LatLng(location.latitude, location.longitude),
                    infoWindow: InfoWindow(
                      title: location.name,
                      snippet: i.toString() + "º Ponto",
                    ),
                  ));
                  i++;
                }
              });
            });
            return Container();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<RouteGetData> _loadRoute() async {
    try {
      RouteGetData route = await BaseClient().getRoute(
          "/route",
          widget.routeUser + "-" + widget.routeID,
          _token.tokenID,
          _token.username);
      return route;
    } catch (e) {
      return Future.error(e);
    }
  }
}

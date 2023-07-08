import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../constants.dart';
import '../models/directions_model.dart';
import 'directions_repository.dart';

class RouteMapScreen extends StatefulWidget {
  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late GoogleMapController mapController;
  List<Marker> markers = [];
  Set<Polyline> polylines = {};
  DirectionsRepository directionsRepository = DirectionsRepository();

  @override
  void initState() {
    super.initState();
    // Initialize markers
    markers.add(
      Marker(
        markerId: MarkerId('marker1'),
        position: LatLng(38.659804, -9.205121),
        infoWindow: InfoWindow(title: 'Marker 1'),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('marker2'),
        position: LatLng(38.660980, -9.206393),
        infoWindow: InfoWindow(title: 'Marker 2'),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('marker3'),
        position: LatLng(38.660785, -9.207470),
        infoWindow: InfoWindow(title: 'Marker 3'),
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {});
  }

  Future<void> drawRoute() async {
    if (markers.length >= 2) {
      // Clear existing polylines
      polylines.clear();

      // Calculate the minimum route
      List<LatLng> minimumRoute = await getMinimumRoute(markers);

      // Create polyline options
      Polyline polyline = Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: minimumRoute,
      );

      setState(() {
        polylines.add(polyline);
      });
    }
  }

  Future<List<LatLng>> getMinimumRoute(List<Marker> markers) async {
    List<LatLng> minimumRoute = [];
    List<LatLng> remainingMarkers =
        List.from(markers.map((marker) => marker.position));

    LatLng origin = remainingMarkers.removeAt(0);
    minimumRoute.add(origin);

    while (remainingMarkers.isNotEmpty) {
      LatLng currentMarker = minimumRoute.last;
      LatLng nearestMarker =
          await findNearestMarker(currentMarker, remainingMarkers);
      minimumRoute.add(nearestMarker);
      remainingMarkers.remove(nearestMarker);
    }

    return minimumRoute;
  }

  Future<LatLng> findNearestMarker(LatLng origin, List<LatLng> markers) async {
    double minDistance = double.infinity;
    LatLng nearestMarker = markers[0];

    for (LatLng marker in markers) {
      Directions directions = await directionsRepository.getDirections(
          origin: origin, destination: marker);

      double distance = parseDistance(directions.totalDistance);
      if (distance < minDistance) {
        minDistance = distance;
        nearestMarker = marker;
      }
    }

    return nearestMarker;
  }

  double parseDistance(String distance) {
    // Assuming the distance is in the format "x km" or "x m"
    List<String> parts = distance.split(" ");
    double value = double.parse(parts[0]);
    if (parts[1] == 'km') {
      return value;
    } else {
      return value / 1000; // Convert meters to kilometers
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(38.661029, -9.204454),
          zoom: 17,
        ),
        markers: Set<Marker>.from(markers),
        polylines: polylines,
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 25.0, bottom: 16.0),
              child: FloatingActionButton(
                backgroundColor:
                    Theme.of(context).floatingActionButtonTheme.backgroundColor,
                foregroundColor:
                    Theme.of(context).floatingActionButtonTheme.foregroundColor,
                onPressed: drawRoute,
                child: Icon(Icons.directions),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

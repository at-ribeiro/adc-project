import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 11.5,
  );

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _checkLocationPermission() async {
    final LocationPermission permission = await _getLocationPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  Future<LocationPermission> _getLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();
    return statusToLocationPermission(status);
  }

  LocationPermission statusToLocationPermission(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return LocationPermission.whileInUse;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        return LocationPermission.denied;
      case PermissionStatus.permanentlyDenied:
        return LocationPermission.deniedForever;
      default:
        return LocationPermission.denied;
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 11.5,
      );

      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mapa'),
        ),
        body: GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: _initialCameraPosition,
          markers: _markers,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          onPressed: () => _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(_initialCameraPosition),
          ),
          child: const Icon(Icons.center_focus_strong),
        ),
      ),
    );
  }
}

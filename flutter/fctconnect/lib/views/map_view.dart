import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(38.659784, -9.202765),
    zoom: 11.5,
  );

  GoogleMapController? _mapController;

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('marker1'),
      position: LatLng(38.659784, -9.202765),
      infoWindow: InfoWindow(title: 'Rotunda'),
    ),
    Marker(
      markerId: MarkerId('marker2'),
      position: LatLng(38.662486, -9.207459),
      infoWindow: InfoWindow(title: 'Departamental'),
    ),
  };

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mapa'),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _initialCameraPosition,
          markers: _markers,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreenPC extends StatefulWidget {
  const MapScreenPC({Key? key}) : super(key: key);

  @override
  _MapScreenPCState createState() => _MapScreenPCState();
}

class _MapScreenPCState extends State<MapScreenPC> {
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
